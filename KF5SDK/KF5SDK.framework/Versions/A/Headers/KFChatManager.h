//
//  KFChatManager.h
//  Pods
//
//  Created by admin on 16/10/19.
//
//

#import <UIKit/UIKit.h>

#import "KFDispatcher.h"
#import "KFAgent.h"
#import "KFMessage.h"

@class KFChatManager;

///接受聊天消息通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatReceiveMessageNotification;
///用户排队的当前位置通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatQueueNotification;
///用户排队失败的通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatQueueErrorNotification;
///分配到客服/转接客服通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatReceiveAgentNotification;
///客服关闭对话通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatEndChatNotification;
///客服发起满意度评价通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatRatingNotification;
///socket连接成功通知
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatConnectSuccessNotification;

@protocol KFChatManagerDelegate <NSObject>

@optional
/**
 接受聊天消息通知

 @param chatManager  聊天管理对象
 @param chatMessage  消息
 */
- (void)chatManager:(nonnull KFChatManager *)chatManager receiveMessage:(nonnull KFMessage *)chatMessage;
/**
 用户排队的当前位置通知

 @param chatManager 聊天管理对象
 @param queueIndex  当前位置
 */
- (void)chatManager:(nonnull KFChatManager *)chatManager queueIndex:(NSInteger)queueIndex;
/**
 用户排队失败

 @param chatManager 聊天管理对象
 @param error 失败的error,当前只有可能是客服不在线而造成的失败
 */
- (void)chatManager:(nonnull KFChatManager *)chatManager queueError:(nonnull NSError *)error;
/**
 分配到客服/转接客服通知

 @param chatManager 聊天管理对象
 @param agent       当前客服
 */
- (void)chatManager:(nonnull KFChatManager *)chatManager currectAgent:(nonnull KFAgent *)agent;
/**
 客服关闭对话通知

 @param chatManager 聊天管理对象
 */
- (void)chatManagerEndChat:(nonnull KFChatManager *)chatManager;
/**
 客服发起满意度评价通知

 @param chatManager 聊天管理对象
 */
- (void)chatManagerRating:(nonnull KFChatManager *)chatManager;

@end

@interface KFChatManager : NSObject
/**
 代理
 */
@property (nullable, nonatomic, weak) id<KFChatManagerDelegate> delegate;
/**
 请求超时时间,默认15秒
 */
@property (nonatomic, assign) NSTimeInterval timeout;
/**
 当前人工客服
 */
@property (nullable, nonatomic, strong,readonly) KFAgent *currentAgent;
/**
 是否开启机器人
 */
@property (nonatomic, assign, readonly, getter=isOpenRobot) BOOL openRobot;
/**
 socket是否连接成功
 */
@property (nonatomic, assign,readonly) BOOL isConnectSuccess;
/**
 当前对话状态
 
 @warning socket连接成功后有效
 */
@property (nonatomic, assign,readonly) KFChatStatus chatStatus;

#pragma mark 方法
/**
 单例
 */
+ (nonnull instancetype)sharedChatManager;
/**
 初始化聊天系统的UserToken,在使用KFChatManager其他接口前,必须先调用此接口
 */
- (void)initializeWithUserToken:(nonnull NSString *)userToken;
/**
 连接服务器
 */
- (void)connectWithCompletion:(nullable void (^)(NSError * _Nullable error))completion;
/**
 更新自定义信息

 @param metadata   格式如:@[@{@"name":@"姓名",@"value":@"小明"},@{@"name":@"性别",@"value":@"男"}]
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (void)uploadMetadata:(nullable NSArray <NSDictionary *>*)metadata completion:(nullable void (^)(NSError * _Nullable error))completion;
/**
 同步离线消息

 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (void)syncMessageWithCompletion:(nullable void (^)(NSArray <KFMessage *> * _Nonnull history, NSError * _Nullable error))completion;
/**
 给机器人发送文本消息

 @param text       文本
 @return  消息实体
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (nonnull KFMessage *)sendAIText:(nonnull NSString *)text completion:(nullable void (^)(KFMessage * _Nonnull me_message,KFMessage * _Nullable ai_message, NSError * _Nullable error))completion;
/**
 发送问题id获取机器人的回答

 @param question_id     问题的id
 @param questionTitle   问题的标题
 @return  消息实体
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (nonnull KFMessage *)sendAIQuestionId:(NSInteger)question_id questionTitle:(nonnull NSString *)questionTitle completion:(nullable void (^)(KFMessage * _Nonnull me_message,KFMessage * _Nullable ai_message, NSError * _Nullable error))completion;
/**
 用户加入排队
 
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
          completion中的error用于判断排队请求是否成功,排队结果会调用chatManager:queueIndex:和chatManager:queueError:代理方法
 */
- (void)queueUpWithCompletion:(nullable void (^)(NSError * _Nullable error))completion;
/**
 用户取消排队

 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (void)queueCancelWithCompletion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 发送文本消息

 @param text       文本

 @return  消息实体
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (nonnull KFMessage *)sendText:(nonnull NSString *)text completion:(nullable void (^)(KFMessage * _Nonnull message, NSError * _Nullable error))completion;
/**
 发送图片消息
 
 @param image       图片
 
 @return  消息实体
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 @warning SDK不会压缩图片,如果需发送压缩图片,请先压缩后在调用此接口
 */
- (nonnull KFMessage *)sendImage:(nonnull UIImage *)image completion:(nullable void (^)(KFMessage * _Nonnull message, NSError * _Nullable error))completion;
/**
 发送语音消息
 
 @param voice       语音
 
 @return  消息实体
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (nonnull KFMessage *)sendVoice:(nonnull NSData *)voice completion:(nullable void (^)(KFMessage * _Nonnull message, NSError * _Nullable error))completion;
/**
 重新发送消息

 @param message    消息实体
 
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (nonnull KFMessage *)resendMessage:(nonnull KFMessage *)message completion:(nullable void (^)(KFMessage *_Nonnull message, NSError * _Nullable error))completion;
/**
 发送满意度

 @param rating     是否满意
 
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (void)sendRating:(BOOL)rating completion:(nullable void (^)(NSError * _Nullable error))completion;
/**
 获取历史记录

 @param from_id    消息的id,从哪条消息开始
 @param count      要获取的数量
 
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (void)getHistoryWithFrom_id:(nonnull NSString *)from_id count:(int)count completion:(nullable void (^)( NSArray<KFMessage *> * _Nonnull history, NSError * _Nullable error))completion;
/**
 设置用户离线,KF5服务器回向推送url发送推送,建议在应用进入后台时调用
 
 @warning 需要先调用connectWithCompletion:连接服务器(socket请求).
 */
- (void)setUserOffline;


#pragma mark 数据库操作
/**
 取出Message数组

 @param lastCount 剩余数量
 @param limit     取出的数量

 @return message数组
 */
- (nonnull NSArray <KFMessage *>*)queryMessagesWithLastCount:(NSInteger)lastCount limit:(NSInteger)limit;
/**
 获取数据库中message的数量
 */
- (NSInteger)queryMessagesCount;
/**
 数据库路径
 
 @warning 需先初始化initializeWithUserToken
 */
- (nonnull NSString *)dbPath;

/**
 根据id查询数据库中的agent

 @param agentId 客服id
 */
- (nullable KFAgent *)agentWithId:(NSInteger)agentId;

#pragma mark 其他
/**
 获取聊天消息未读数

 @warning 未读消息数不是很精确,不建议直接使用其数量提示用户;最好的方式是用此接口获取是否有未读消息(HTTP请求)
 */
- (void)getUnReadMessageCountWithCompletion:(nullable void (^)(NSInteger unReadMessageCount, NSError * _Nullable error))completion;

@end
