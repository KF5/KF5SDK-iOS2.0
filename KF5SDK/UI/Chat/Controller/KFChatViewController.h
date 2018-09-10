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
@property (nullable, nonatomic, copy) void (^noAgentAlertActionBlock)(void);
/**
 每次拉取的历史数量,默认30
 */
@property (nonatomic, assign) NSInteger limit;
/**
 当未开启机器人时,设置是否发送一条消息后,再分配客服(用于过滤无效的空对话),默认NO
 */
@property (nonatomic, assign) BOOL assignAgentWhenSendedMessage;

/**
 初始化方法
 
 @param metadata IM自定义字段,格式如:@[@{@"name":@"姓名",@"value":@"小明"},@{@"name":@"性别",@"value":@"男"}]
 */
-(nonnull instancetype)initWithMetadata:(nullable NSArray <NSDictionary *>*)metadata;
/**
 设置卡片展示的信息
 
 @param cardDict 卡片信息,格式如:@{@"img_url":@"https://www.kf5.com/image.png", @"title":@"标题",@"price":@"¥200",@"link_title":@"发送链接",@"link_url":@"https://www.kf5.com"}
 @warning 需要在跳转到聊天界面前设置
 */
- (void)setCardDict:(nonnull NSDictionary *)cardDict;
/**
 获取聊天消息未读数
 
 @warning 未读消息数不是很精确,不建议直接使用其数量提示用户;最好的方式是用此接口获取是否有未读消息(HTTP请求)
 */
+ (void)getUnReadMessageCountWithCompletion:(nullable void (^)(NSInteger unReadMessageCount, NSError * _Nullable error))completion;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)new NS_UNAVAILABLE;

@end
