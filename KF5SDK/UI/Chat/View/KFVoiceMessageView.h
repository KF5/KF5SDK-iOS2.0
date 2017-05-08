//
//  KFVoiceMessageView.h
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import <UIKit/UIKit.h>

#import "KFHelper.h"

@interface KFVoiceMessageView : UIView

- (instancetype)initWithMeTextColor:(UIColor *)meTextColor otherTextColor:(UIColor *)otherTextColor textFont:(UIFont *)textFont;

- (void)setMessageForm:(KFMessageFrom)messageForm;

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
