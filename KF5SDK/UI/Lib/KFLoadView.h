//
//  KFLoadView.h
//  Pods
//
//  Created by admin on 16/11/1.
//
//

#import <UIKit/UIKit.h>
#if __has_include("KFDispatcher.h")
#import "KFDispatcher.h"
#else
#import <KF5SDKCore/KFDispatcher.h>
#endif

@interface KFLoadView : UIView
/**
 失败按钮的点击事件
 */
@property (nullable, nonatomic, copy) void (^clickFailureBtnBlock)(void);
/**
 设置状态
 */
@property (nonatomic, assign) KFMessageStatus status;

@end
