//
//  KFFieldView.h
//  SampleSDKApp
//
//  Created by admin on 15/10/23.
//  Copyright © 2015年 admin. All rights reserved.
//

// 输入视图+发送按钮+添加图片按钮
#import <UIKit/UIKit.h>
#import "KFTextView.h"

@class KFFieldView;

static const CGFloat kKF5FieldTextViewTopSapcing = 8;

@protocol KFFieldViewDelegate <NSObject>
/**
 *  添加按钮点击事件
 */
- (void)fieldViewWithAddAttachmentAction:(KFFieldView *)fieldView;

/**
 *  textView高度改变
 */
- (void)fieldView:(KFFieldView *)fieldView changeHeight:(CGFloat)height;
/**
 *  textView输入return
 */
- (void)fieldViewWithTextViewReturn:(KFFieldView *)fieldView;

@end

@interface KFFieldView : UIView

@property (nonatomic, weak) id<KFFieldViewDelegate> delegate;

@property (nonatomic, weak) KFTextView *textView;

+ (CGFloat)defaultHeight;

@end
