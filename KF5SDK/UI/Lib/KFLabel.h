//
//  KFLabel.h
//  KFLabel
//
//  Created by admin on 2017/11/29.
//  Copyright © 2017年 ma. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const KFLinkAttributeName;

typedef NS_ENUM(NSUInteger, KFLinkGestureRecognizerResult) {
    KFLinkGestureRecognizerResultUnknown,
    KFLinkGestureRecognizerResultTap,
    KFLinkGestureRecognizerResultLongPress,
    KFLinkGestureRecognizerResultFailed,
};

@class KFLinkGestureRecognizer;
@interface KFLabel : UITextView

@property (nonatomic, copy) NSDictionary<NSString *, id> *linkTextTouchAttributes;

@property (nonatomic, assign) CFTimeInterval minimumPressDuration;

@property (nonatomic, assign) CGFloat allowableMovement;
// 点击高亮扩大的范围 默认:{-5, -5, -5, -5}
@property (nonatomic) UIEdgeInsets tapAreaInsets;

@property (nonatomic, readonly) KFLinkGestureRecognizer *linkGestureRecognizer;

@property (nonatomic, assign) CGFloat linkCornerRadius;

@property (nonatomic,copy) void (^linkLongPressBlock)(KFLabel *label, id value);
@property (nonatomic,copy) void (^linkTapBlock)(KFLabel *label, id value);

@property (nonatomic,copy) void (^commonTapBlock)(KFLabel *label);
@property (nonatomic,copy) void (^commonLongPressBlock)(KFLabel *label);

- (void)enumerateViewRectsForRanges:(NSArray *)ranges usingBlock:(void (^)(CGRect rect, NSRange range, BOOL *stop))block;

- (BOOL)enumerateLinkRangesContainingLocation:(CGPoint)location usingBlock:(void (^)(NSRange range))block;

@end


@interface KFLinkGestureRecognizer : UIGestureRecognizer

@property (nonatomic) CFTimeInterval minimumPressDuration;

@property (nonatomic) CGFloat allowableMovement;

@property (nonatomic, readonly) KFLinkGestureRecognizerResult result;

@end

@interface KFTextAttachment : NSTextAttachment

@end
