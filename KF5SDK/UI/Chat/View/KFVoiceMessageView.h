//
//  KFVoiceMessageView.h
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import <UIKit/UIKit.h>
#if __has_include("KFDispatcher.h")
#import "KFDispatcher.h"
#else
#import <KF5SDKCore/KFDispatcher.h>
#endif

@interface KFVoiceMessageView : UIView

- (instancetype)initWithMeTextColor:(UIColor *)meTextColor otherTextColor:(UIColor *)otherTextColor textFont:(UIFont *)textFont;

- (void)setMessageForm:(KFMessageFrom)messageForm;
/**
 是否正在下载
 */
@property (nonatomic, assign) BOOL  isLoading;

/**
 *  设置时长Label
 */
- (void)setDuration:(double)duration;
/**
 *  开始播放语音动画
 */
- (void)startAnimating;
/**
 *  停止播放语音动画
 */
- (void)stopAnimating;


@end
