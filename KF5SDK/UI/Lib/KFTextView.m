//
//  KFTextView.m
//  Pods
//
//  Created by admin on 16/10/21.
//
//

#import "KFTextView.h"
#import "KFHelper.h"

#import "KFAutoLayout.h"

static NSString *KF5AttributedTextKey = @"attributedText";
static NSString *KF5TextKey = @"text";
static NSString *KF5FontKey = @"font";

static CGFloat KF5PlaceHolderLeft = 8.0;

@interface KFTextView()<UITextViewDelegate>

@property (nullable, nonatomic, weak) UILabel *placeholderLabel;

@end

@implementation KFTextView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = KF5Helper.KF5TitleFont;
        self.scrollEnabled = YES;
        self.canEmoji = YES;
        UILabel *placeholderLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5CreateTicketPlaceholderTextColor];
        placeholderLabel.opaque = NO;
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:placeholderLabel];
        _placeholderLabel = placeholderLabel;
        
        [placeholderLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.top.kf_equalTo(self).kf_offset(KF5PlaceHolderLeft);
            make.left.kf_equalTo(self).kf_offset(KF5PlaceHolderLeft);
        }];
        
        // some observations
        [self addObserver:self forKeyPath:KF5AttributedTextKey
                  options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:KF5TextKey
                  options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:KF5FontKey
                  options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.delegate = self;
        self.maxTextHeight = MAXFLOAT;
    }
    return self;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor{
    _placeholderLabel.textColor = placeholderTextColor;
}

- (void)setPlaceholderText:(NSString *)placeholderText{
    _placeholderLabel.text = placeholderText;
}

- (void)cleanText{
    self.attributedText = nil;
    self.text = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:KF5FontKey]) {
        self.placeholderLabel.font = self.font;
    }else if ([keyPath isEqualToString:KF5AttributedTextKey] || [keyPath isEqualToString:KF5TextKey]) {
        [self textViewDidChange:self];
    }
}

#pragma mark - textViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    
    [self reloadPlaceholder];
    
    if (self.text.length > 0 && !self.canEmoji) {
        // 禁止系统表情的输入
        NSString *text = [KFHelper disable_emoji:[self text]];
        if (![text isEqualToString:self.text]) {
            NSRange textRange = [self selectedRange];
            self.text = text;
            [self setSelectedRange:textRange];
            return;
        }
    }
    self.heightLayout.constant = self.textHeight;
    
    if ([self.textDelegate respondsToSelector:@selector(kf5_textViewDidChange:)]) {
        [self.textDelegate kf5_textViewDidChange:self];
    }
}

- (void)insertText:(NSString *)text{
    if ([self textView:self shouldChangeTextInRange:NSMakeRange(0, text.length) replacementText:text]) {
        [super insertText:text];
    }
}

- (BOOL)textView:(KFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if ([self.textDelegate respondsToSelector:@selector(kf5_textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.textDelegate kf5_textView:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

#pragma mark 修复textView换行不居中系统bug
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ( scrollView.contentSize.height <= self.maxTextHeight) {
        scrollView.contentOffset = CGPointZero;
    }else if(!scrollView.tag){
        scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height);
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    scrollView.tag = 1;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    scrollView.tag = 0;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    scrollView.tag = 1;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    scrollView.tag = 0;
}

#pragma mark - 私有方法

- (void)reloadPlaceholder{
    if (self.text.length > 0) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
    [self layoutIfNeeded];
}

- (CGFloat)textHeight{
    CGFloat maxHeight = self.maxTextHeight > 0 ? self.maxTextHeight : MAXFLOAT;
    CGFloat height =  floor([self sizeThatFits:CGSizeMake(self.frame.size.width, maxHeight)].height);
    return height > maxHeight ? maxHeight : height;
}

- (UIResponder *)nextResponder {
    if (_inputNextResponder != nil)
        return _inputNextResponder;
    else
        return [super nextResponder];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (_inputNextResponder) {
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:KF5TextKey];
    [self removeObserver:self forKeyPath:KF5AttributedTextKey];
    [self removeObserver:self forKeyPath:KF5FontKey];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
