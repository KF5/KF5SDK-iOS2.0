//
//  KFFieldView.m
//  SampleSDKApp
//
//  Created by admin on 15/10/23.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "KFFieldView.h"
#import "KFHelper.h"

static CGFloat kKF5ChatToolDefaultTextViewHeight = 36.5;
static const CGFloat kKF5MaxHeight = 130;

@interface KFFieldView()<KFTextViewDelegate>

@property (nonatomic, assign) CGFloat oldHeight;

@end

@implementation KFFieldView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

+ (CGFloat)defaultHeight{
    return kKF5ChatToolDefaultTextViewHeight + KF5Helper.KF5ChatToolTextViewTopSpacing * 2;
}

/**
 *  初始化控件
 */
- (void)setupView{
    // 1.附件按钮
    UIButton *attBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    attBtn.frame = CGRectMake(0, 0, 32, self.kf5_h);
    [attBtn setImage:KF5Helper.ticketTool_openAtt forState:UIControlStateNormal];
    [attBtn addTarget:self action:@selector(att:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:attBtn];
    // 2.文本输入框
    CGFloat textViewX = CGRectGetMaxX(attBtn.frame);
    KFTextView *textView = [[KFTextView alloc]initWithFrame:CGRectMake(textViewX, kKF5FieldTextViewTopSapcing, self.kf5_h - textViewX - KF5Helper.KF5DefaultSpacing, kKF5ChatToolDefaultTextViewHeight)];
    textView.layer.borderColor = KF5Helper.KF5BgColor.CGColor;
    textView.layer.borderWidth = 1.5;
    textView.layer.cornerRadius = 5.0;
    textView.font = KF5Helper.KF5TitleFont;
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;
    textView.bounces = NO;
    textView.textDelegate = self;
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    [self addSubview:textView];
    self.textView = textView;
}

#pragma mark - textViewDelegate

- (void)kf5_textViewDidChange:(KFTextView *)textView{
    if (textView.text.length > 0) {
        // 禁止系统表情的输入
        NSString *text = [KFHelper disable_emoji:[textView text]];
        if (![text isEqualToString:textView.text]) {
            NSRange textRange = [textView selectedRange];
            textView.text = text;
            [textView setSelectedRange:textRange];
        }
    }
    // 计算 text view 的高度
    CGSize newSize = [textView sizeThatFits:CGSizeMake(self.textView.bounds.size.width, kKF5MaxHeight)];
    newSize = CGSizeMake(newSize.width, newSize.height < kKF5MaxHeight ? newSize.height : kKF5MaxHeight);
    
    // 通知父视图
    CGFloat height = newSize.height - _oldHeight;
    
    if ([self.delegate respondsToSelector:@selector(fieldView:changeHeight:)])
        [self.delegate fieldView:self changeHeight:height];
}
- (BOOL)kf5_textView:(KFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        if ([self.delegate respondsToSelector:@selector(fieldViewWithTextViewReturn:)])
            [self.delegate fieldViewWithTextViewReturn:self];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}


#pragma mark - 按钮点击事件
/**添加按钮点击事件*/
- (void)att:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(fieldViewWithAddAttachmentAction:)])
        [self.delegate fieldViewWithAddAttachmentAction:self];
    
    if (self.textView.isFirstResponder)
        [self.textView resignFirstResponder];// 移除第一响应者
}


- (void)layoutSubviews{
    [super layoutSubviews];
    _oldHeight = self.textView.frame.size.height;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
