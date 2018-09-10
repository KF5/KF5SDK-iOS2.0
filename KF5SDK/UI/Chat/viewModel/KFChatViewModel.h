//
//  KFChatViewModel.h
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import <Foundation/Foundation.h>
#if __has_include("KFDispatcher.h")
#import "KFDispatcher.h"
#else
#import <KF5SDKCore/KFDispatcher.h>
#endif
@class KFChatViewModel;
@class KFMessageModel;
@class KFAgent;

typedef NS_ENUM(NSInteger,KFChatRatingScore) {
    KFChatRatingScoreNone = -1, // 未评价
    KFChatRatingScoreBad = 0,    // 不满意
    KFChatRatingScoreSoso = 2,   // 不太满意
    KFChatRatingScoreOk = 3,     // 一般
    KFChatRatingScoreGood = 4,   // 基本满意
    KFChatRatingScoreGreat = 1   // 满意
};

@protocol KFChatViewModelDelegate <NSObject>
/**连接服务器失败*/
- (void)chat:(nonnull KFChatViewModel *)chat connectError:(nullable NSError *)error;
/**排队人数变化*/
- (void)chat:(nonnull KFChatViewModel *)chat queueIndexChange:(NSInteger)queueIndex;
/**排队失败*/
- (void)chat:(nonnull KFChatViewModel *)chat queueError:(nullable NSError *)error;
/** 状态改变*/
- (void)chat:(nonnull KFChatViewModel *)chat statusChange:(KFChatStatus)status;
/** 客服发起满意度评价请求*/
- (void)chatWithAgentRating:(nonnull KFChatViewModel *)chat;
/**对话被客服关闭*/
- (void)chatWithEndChat:(nonnull KFChatViewModel *)chat;
/**刷新数据*/
- (void)chat:(nonnull KFChatViewModel *)chat addMessageModels:(nullable NSArray <KFMessageModel *>*)messageModels;
/**更新数据*/
- (void)chat:(nonnull KFChatViewModel *)chat reloadMessageModels:(nullable NSArray <KFMessageModel *>*)messageModels;

/**获取要选择的客服组模型*/
- (void)chat:(nonnull KFChatViewModel *)chat selectQuestionWithOptions:(nonnull NSArray <NSDictionary*>*)options selectBlock:(void (^_Nullable)(NSArray <NSNumber *>* _Nullable agentIds, BOOL cancel))selectBlock;
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
@property (nonatomic, assign, readonly) KFChatStatus chatStatus;
/**
 当前的客服
 */
@property (nullable, nonatomic, weak, readonly) KFAgent *currentAgent;
/**
 当未开启机器人时,设置是否发送一条消息后,再分配客服(用于过滤无效的空对话),默认NO
 */
@property (nonatomic, assign) BOOL assignAgentWhenSendedMessage;
/**
 是否能发送消息
 */
- (BOOL)canSendMessageWithCompletion:(nullable void (^)(void))completion;

/**
 连接服务器
 */
- (void)configChatWithCompletion:(nullable void (^)(NSError *_Nullable))completion;
/**
 断开连接
 */
- (void)disconnect;
/**
 发送满意度评价

 @param rating     满意度分数
 */
- (void)sendRating:(NSInteger)rating completion:(nullable void (^)(NSError * _Nullable error))completion;
/**
 发送消息

 @param messageType 消息格式,文本,图片,语音
 @param data        NSString,UIImage,NSData
 */
- (void)sendMessageWithMessageType:(KFMessageType)messageType data:(nonnull id)data;
/**
 获取问题的答案

 @param questionId 问题的id
 @param questionTitle 问题的答案
 */
- (void)getAnswerWithQuestionId:(NSInteger)questionId questionTitle:(nonnull NSString *)questionTitle;
/**
 重发消息
 */
- (void)resendMessageModel:(nullable KFMessageModel *)messageModel;
/**
 加入排队
 */
- (void)queueUpWithCompletion:(nullable void (^)(NSError *_Nullable))completion;
/**
 取消排队
 */
- (void)cancleWithCompletion:(nullable void (^)( NSError * _Nullable ))completion;
/**
 从数据库中获取新数据
 */
- (nonnull NSArray<KFMessageModel *> *)queryMessageModelsWithLimit:(NSInteger)limit;

/**
 获取要显示的满意度
 */
- (nonnull NSArray <NSNumber *> *)rateLevelArray;
/**
 满意度字符串
 */
+ (nullable NSString *)stringForRatingScore:(KFChatRatingScore)ratingScore;

/**
 获取聊天消息未读数
 */
+ (void)getUnReadMessageCountWithCompletion:(nullable void (^)(NSInteger unReadMessageCount, NSError * _Nullable error))completion;

@end
