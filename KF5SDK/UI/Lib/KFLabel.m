//
//  KFLabel.m
//  KFLabel
//
//  Created by admin on 2017/11/29.
//  Copyright © 2017年 ma. All rights reserved.
//

#import "KFLabel.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

NSString *const KFLinkAttributeName = @"KFLinkAttributeName";

@interface KFLabel()<UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray *rangeValuesForTouchDown;
@property (nonatomic) KFLinkGestureRecognizer *linkGestureRecognizer;

@end

@implementation KFLabel

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    self.linkTextTouchAttributes = @{NSBackgroundColorAttributeName : UIColor.lightGrayColor};
    self.backgroundColor = [UIColor clearColor];
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    self.tapAreaInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    self.scrollEnabled = NO;
    self.editable = NO;
}

- (void)drawRoundedCornerForRange:(NSRange)range{
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = self.bounds;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, layer.bounds); // Unmask the whole text area
    
    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    [self.layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainer usingBlock:^(CGRect rect, BOOL *stop) {
        rect.origin.x += self.textContainerInset.left - self.contentOffset.x;
        rect.origin.y += self.textContainerInset.top - self.contentOffset.y;
        
        CGContextClearRect(context, CGRectInset(rect, -1, -1)); // Mask the rectangle of the range
        
        CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.linkCornerRadius].CGPath);
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);  // Unmask the rounded area inside the rectangle
        CGContextFillPath(context);
    }];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [layer setContents:(id)[image CGImage]];
    self.layer.mask = layer;
}

#pragma mark 遍历方法
- (void)enumerateViewRectsForRanges:(NSArray *)ranges usingBlock:(void (^)(CGRect rect, NSRange range, BOOL *stop))block{
    if (!block) return;
    
    for (NSValue *rangeAsValue in ranges) {
        NSRange range = rangeAsValue.rangeValue;
        NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
        [self.layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainer usingBlock:^(CGRect rect, BOOL *stop) {
            rect.origin.x += self.textContainerInset.left;
            rect.origin.y += self.textContainerInset.top;
            rect = UIEdgeInsetsInsetRect(rect, self.tapAreaInsets);
            
            block(rect, range, stop);
        }];
    }
}

- (BOOL)enumerateLinkRangesContainingLocation:(CGPoint)location usingBlock:(void (^)(NSRange range))block{
    __block BOOL found = NO;
    
    NSAttributedString *attributedString = self.attributedText;
    [attributedString enumerateAttribute:KFLinkAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (found) {
            *stop = YES;
            return;
        }
        if (value) {
            [self enumerateViewRectsForRanges:@[[NSValue valueWithRange:range]] usingBlock:^(CGRect rect, NSRange range, BOOL *stop) {
                if (found) {
                    *stop = YES;
                    return;
                }
                if (CGRectContainsPoint(rect, location)) {
                    found = YES;
                    *stop = YES;
                    if (block) {
                        block(range);
                    }
                }
            }];
        }
    }];
    
    return found;
}

#pragma mark Gesture recognition

- (void)linkAction:(KFLinkGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSAssert(self.rangeValuesForTouchDown == nil, @"Invalid touch down ranges");
        
        CGPoint location = [recognizer locationInView:self];
        self.rangeValuesForTouchDown = [self didTouchDownAtLocation:location];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSAssert(self.rangeValuesForTouchDown != nil, @"Invalid touch down ranges");
        
        if (recognizer.result == KFLinkGestureRecognizerResultTap) {
            [self didTapAtRangeValues:self.rangeValuesForTouchDown];
        } else if (recognizer.result == KFLinkGestureRecognizerResultLongPress) {
            [self didLongPressAtRangeValues:self.rangeValuesForTouchDown];
        }
        
        [self didCancelTouchDownAtRangeValues:self.rangeValuesForTouchDown];
        self.rangeValuesForTouchDown = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark Gesture handling

- (NSArray *)didTouchDownAtLocation:(CGPoint)location{
    NSMutableArray *rangeValuesForTouchDown = [NSMutableArray array];
    [self enumerateLinkRangesContainingLocation:location usingBlock:^(NSRange range) {
        [rangeValuesForTouchDown addObject:[NSValue valueWithRange:range]];
        
        NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
        for (NSString *attribute in self.linkTextAttributes) {
            [attributedText removeAttribute:attribute range:range];
        }
        [attributedText addAttributes:self.linkTextTouchAttributes range:range];
        [super setAttributedText:attributedText];
        
        if (self.linkCornerRadius > 0) {
            [self drawRoundedCornerForRange:range];
        }
    }];
    
    return rangeValuesForTouchDown;
}

- (void)didCancelTouchDownAtRangeValues:(NSArray *)rangeValues{
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    for (NSValue *rangeValue in rangeValues) {
        NSRange range = rangeValue.rangeValue;
        
        for (NSString *attribute in self.linkTextTouchAttributes) {
            [attributedText removeAttribute:attribute range:range];
        }
        [attributedText addAttributes:self.linkTextAttributes range:range];
    }
    [super setAttributedText:attributedText];
    self.layer.mask = nil;
}

- (void)didTapAtRangeValues:(NSArray *)rangeValues{
    if (rangeValues.count > 0 && self.linkTapBlock) {
        for (NSValue *rangeValue in rangeValues) {
            NSRange range = rangeValue.rangeValue;
            id value = [self.attributedText attribute:KFLinkAttributeName atIndex:range.location effectiveRange:NULL];
            self.linkTapBlock(self, value);
        }
    }else if (rangeValues.count == 0 && self.commonTapBlock){
        self.commonTapBlock(self);
    }
}

- (void)didLongPressAtRangeValues:(NSArray *)rangeValues{
    if (rangeValues.count > 0 && self.linkLongPressBlock) {
        for (NSValue *rangeValue in rangeValues) {
            NSRange range = rangeValue.rangeValue;
            id value = [self.attributedText attribute:KFLinkAttributeName atIndex:range.location effectiveRange:NULL];
            self.linkLongPressBlock(self, value);
        }
    }else if (rangeValues.count == 0 && self.commonLongPressBlock){
        self.commonLongPressBlock(self);
    }
}

#pragma mark - 属性处理
- (void)setEditable:(BOOL)editable{
    super.editable = editable;
    if (editable) {
        self.selectable = YES;
        [self removeGestureRecognizer:self.linkGestureRecognizer];
    } else {
        self.selectable = NO;
        if (![self.gestureRecognizers containsObject:self.linkGestureRecognizer]) {
            self.linkGestureRecognizer = [[KFLinkGestureRecognizer alloc] initWithTarget:self action:@selector(linkAction:)];
            self.linkGestureRecognizer.delegate = self;
            [self addGestureRecognizer:self.linkGestureRecognizer];
        }
    }
}

- (void)setLinkTextAttributes:(NSDictionary *)linkTextAttributes{
    [super setLinkTextAttributes:linkTextAttributes];
    [self setAttributedText:self.attributedText];
}

- (void)setLinkTextTouchAttributes:(NSDictionary *)linkTextTouchAttributes{
    _linkTextTouchAttributes = linkTextTouchAttributes;
    [self setAttributedText:self.attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    NSMutableAttributedString *mutableAttributedText = [attributedText mutableCopy];
    [mutableAttributedText enumerateAttribute:KFLinkAttributeName inRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            [mutableAttributedText addAttributes:self.linkTextAttributes range:range];
        }
    }];
    [super setAttributedText:mutableAttributedText];
}

- (void)setMinimumPressDuration:(CFTimeInterval)minimumPressDuration{
    self.linkGestureRecognizer.minimumPressDuration = minimumPressDuration;
}

- (CFTimeInterval)minimumPressDuration{
    return self.linkGestureRecognizer.minimumPressDuration;
}

- (void)setAllowableMovement:(CGFloat)allowableMovement{
    self.linkGestureRecognizer.allowableMovement = allowableMovement;
}

- (CGFloat)allowableMovement{
    return self.linkGestureRecognizer.allowableMovement;
}

@end





@interface KFLinkGestureRecognizer ()

@property (nonatomic) KFLinkGestureRecognizerResult result;
@property (nonatomic) CGPoint initialPoint;
@property (nonatomic) NSTimer *timer;

@end

@implementation KFLinkGestureRecognizer

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    // Same defaults as UILongPressGestureRecognizer
    self.minimumPressDuration = 0.5;
    self.allowableMovement = 10;
    
    self.result = KFLinkGestureRecognizerResultUnknown;
    self.initialPoint = CGPointZero;
}

- (void)reset{
    [super reset];
    
    self.result = KFLinkGestureRecognizerResultUnknown;
    self.initialPoint = CGPointZero;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)longPressed:(NSTimer *)timer{
    [timer invalidate];
    
    self.result = KFLinkGestureRecognizerResultLongPress;
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    NSAssert(self.result == KFLinkGestureRecognizerResultUnknown, @"Invalid result state");
    
    UITouch *touch = touches.anyObject;
    self.initialPoint = [touch locationInView:self.view];
    self.state = UIGestureRecognizerStateBegan;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.minimumPressDuration target:self selector:@selector(longPressed:) userInfo:nil repeats:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if (![self touchIsCloseToInitialPoint:touches.anyObject]) {
        self.result = KFLinkGestureRecognizerResultFailed;
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if ([self touchIsCloseToInitialPoint:touches.anyObject]) {
        self.result = KFLinkGestureRecognizerResultTap;
        self.state = UIGestureRecognizerStateRecognized;
    } else {
        self.result = KFLinkGestureRecognizerResultFailed;
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (BOOL)touchIsCloseToInitialPoint:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.view];
    CGFloat xDistance = (self.initialPoint.x - point.x);
    CGFloat yDistance = (self.initialPoint.y - point.y);
    CGFloat squaredDistance = (xDistance * xDistance) + (yDistance * yDistance);
    
    BOOL isClose = (squaredDistance <= (self.allowableMovement * self.allowableMovement));
    return isClose;
}

@end


@implementation KFTextAttachment

//重载此方法 使得图片的大小和行高是一样的。
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex{
    return CGRectMake(0, 0, lineFrag.size.height, lineFrag.size.height);
}

@end

