//
//  KFChatViewModel.h
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import <Foundation/Foundation.h>
#import <KF5SDK/KFAgent.h>
#import  <KF5SDK/KFDispatcher.h>

@class KFChatViewModel;
@class KFMessageModel;

@protocol KFChatViewModelDelegate <NSObject>
/**连接服务器失败*/
- (void)chat:(nonnull KFChatViewModel *)chat connectError:(nullable NSError *)error;
/**排队中*/
- (void)chatWithQueueing:(nonnull KFChatViewModel *)chat;
/**排队人数变化*/
- (void)chat:(nonnull KFChatViewModel *)chat queueIndexChange:(NSInteger)queueIndex;
/**排队失败*/
- (void)chat:(nonnull KFChatViewModel *)chat queueError:(nullable NSError *)error;
/** 获取到客服*/
- (void)chat:(nonnull KFChatViewModel *)chat agentChange:(nullable KFAgent *)agent;
/** 状态改变*/
- (void)chat:(nonnull KFChatViewModel *)chat statusChange:(KFChatStatus)status;
/** 客服发起满意度评价请求*/
- (void)chatWithAgentRating:(nonnull KFChatViewModel *)chat;
/**对话被客服关闭*/
- (void)chatWithEndChat:(nonnull KFChatViewModel *)chat;
/**刷新数据*/
- (void)chat:(nonnull KFChatViewModel *)chat addMessageModels:(nullable NSArray <KFMessageModel *>*)messageModels;
@end

@interface KFChatViewModel : NSObject

@property (nullable, nonatomic, weak) id<KFChatViewModelDelegate> delegate;

/**
 IM自定义字段
 */
@property (nullable, nonatomic, strong) NSArray <NSDictionary *>*metadata;
/**
 聊天状态
 */
@property (nonatomic, assign) KFChatStatus chatStatus;
/**
 是否能发送消息
 */
- (BOOL)canSendMessageWithCompletion:(nullable void (^)())completion;

/**
 连接服务器
 */
- (void)configChatWithCompletion:(nullable void (^)())completion;
/**
 断开连接
 */
- (void)disconnect;
/**
 发送满意度评价

 @param rating     是否满意
 */
- (void)sendRating:(BOOL)rating completion:(nullable void (^)(NSError * _Nullable error))completion;
/**
 发送消息

 @param messageType 消息格式,文本,图片,语音
 @param data        NSString,UIImage,NSData
 */
- (void)sendMessageWithMessageType:(KFMessageType)messageType data:(nonnull id)data;
/**
 重发消息
 */
- (void)resendMessageModel:(nullable KFMessageModel *)messageModel;
/**
 加入排队
 */
- (void)queueUpWithCompletion:(nullable void (^)())completion;
- (void)cancleWithCompletion:(nullable void (^)( NSError * _Nullable ))completion;
/**
 从数据库中获取新数据
 */
- (nonnull NSArray<KFMessageModel *> *)queryMessageModelsWithLimit:(NSInteger)limit;

@end
