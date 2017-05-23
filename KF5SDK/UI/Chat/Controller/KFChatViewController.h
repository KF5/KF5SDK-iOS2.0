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

 @param metadata IM自定义字段,格式如:@[@{@"name":@"姓名",@"value":@"小明"},@{@"name":@"性别",@"value":@"男"}]
 */
-(nonnull instancetype)initWithMetadata:(nullable NSArray <NSDictionary *>*)metadata;
/**
 *  当没有客服在线时是否弹出alertView,默认为YES
 *
 *  注:当设置为NO时,noAgentAlertShowTitle,agentBusyAlertShowTitle和noAgentAlertActionBlock将失效
 */
@property (nonatomic, assign,getter=isShowAlertWhenNoAgent) BOOL showAlertWhenNoAgent;
/**
 是否隐藏右侧按钮,默认NO
 */
@property (nonatomic, assign) BOOL isHideRightButton;
/**
 *  当没有客服在线或取消排队留言时,弹出alertView,点击"确定"按钮的事件处理,默认跳转到反馈工单界面
 */
@property (nullable, nonatomic, copy) void (^noAgentAlertActionBlock)();
/**
 每次拉取的历史数量,默认20
 */
@property (nonatomic, assign) NSInteger limit;

/**
 当未开启机器人时,设置是否发送一条消息后,再分配客服(用于过滤无效的空对话),默认NO
 */
@property (nonatomic, assign) BOOL assignAgentWhenSendedMessage;

@end
