//
//  KFChatViewController.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import "KFBaseViewController.h"

@interface KFChatViewController : KFBaseViewController

/**
 初始化方法

 @param metadata IM自定义字段
 */
-(nonnull instancetype)initWithMetadata:(nullable NSArray <NSDictionary *>*)metadata;
/**
 *  当没有客服在线时是否弹出alertView,默认为YES
 *
 *  注:当设置为NO时,noAgentAlertShowTitle,agentBusyAlertShowTitle和noAgentAlertActionBlock将失效
 */
@property (nonatomic, assign,getter=isShowAlertWhenNoAgent) BOOL showAlertWhenNoAgent;
/**
 *  当没有客服在线或取消排队留言时,弹出alertView,点击"确定"按钮的事件处理,默认跳转到反馈工单界面
 */
@property (nullable, nonatomic, copy) void (^noAgentAlertActionBlock)();
/**
 每次拉取的历史数量,默认20
 */
@property (nonatomic, assign) NSInteger limit;

@end
