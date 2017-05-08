//
//  KFLoadView.h
//  Pods
//
//  Created by admin on 16/11/1.
//
//

#import <UIKit/UIKit.h>

#import "KFHelper.h"

@interface KFLoadView : UIView
/**
 失败按钮的点击事件
 */
@property (nullable, nonatomic, copy) void (^clickFailureBtnBlock)();
/**
 设置状态
 */
@property (nonatomic, assign) KFMessageStatus status;

@end
