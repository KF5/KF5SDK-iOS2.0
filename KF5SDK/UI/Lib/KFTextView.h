//
//  KFTextView.h
//  Pods
//
//  Created by admin on 16/10/21.
//
//

#import <UIKit/UIKit.h>

@class KFTextView;

@protocol KFTextViewDelegate <NSObject>

@optional

- (void)kf5_textViewDidChange:(nonnull KFTextView *)textView;
- (BOOL)kf5_textView:(nonnull KFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nullable NSString *)text;

@end

@interface KFTextView : UITextView

/**
 placeholderText的内容
 */
@property (nullable, nonatomic, copy) NSString *placeholderText;
/**
 placeholderText的颜色
 */
@property (nullable, nonatomic, strong) UIColor *placeholderTextColor;
/**
 代理
 */
@property (nullable, nonatomic, weak) id<KFTextViewDelegate> textDelegate;

@property (nullable, nonatomic, weak) UIResponder *inputNextResponder;

/**
 是否能输入emoji,默认为YES
 */
@property (nonatomic,assign) BOOL canEmoji;


/**
 限制的最大高度,用于计算textHeight,如果没有设置默认MAXFLOAT
 */
@property (nonatomic, assign) CGFloat maxTextHeight;

@property (nonatomic,strong) NSLayoutConstraint * _Nullable heightLayout;

- (CGFloat)textHeight;
/**
 清空内容
 */
- (void)cleanText;

@end
