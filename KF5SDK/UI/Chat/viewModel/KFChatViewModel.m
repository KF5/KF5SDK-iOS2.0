//
//  KFChatViewModel.m
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import "KFChatViewModel.h"
#import "KFUserManager.h"
#import "KFCategory.h"
#import "KFMessageModel.h"

@interface KFChatViewModel()<KFChatManagerDelegate>

@property (nonatomic, assign) NSInteger sqlOffSet;

@property (nonatomic, copy) void (^recordCompletion)(NSData *recordData ,NSError *error);
@property (nonatomic, copy) void (^amplitudeChange)(double amplitude);

/// 是否开启问题分配
@property (nonatomic, assign, ) BOOL selectQuestionEnabled;
/// 是否强制分配
@property (nonatomic, assign) BOOL selectQuestionisForce;
/// 问题分配选项
@property (nonatomic, strong) NSArray <NSDictionary *>* selectQuestionOption;

@end

@implementation KFChatViewModel

- (instancetype)init{
    self = [super init];
    if (self) {
        [[KFChatManager sharedChatManager]initializeWithUserToken:[KFUserManager shareUserManager].user.userToken];
        [KFChatManager sharedChatManager].delegate = self;
        _sqlOffSet = -1;
        
        [[KFChatManager sharedChatManager] addObserver:self forKeyPath:@"chatStatus" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"chatStatus"]) {
        [self delegateWithStatusChanage];
    }
}

- (KFChatStatus)chatStatus{
    return [KFChatManager sharedChatManager].chatStatus;
}
- (KFAgent *)currentAgent{
    return [KFChatManager sharedChatManager].currentAgent;
}

- (void)disconnect{
    [[KFChatManager sharedChatManager]setUserOffline];
}
#pragma mark - 连接请求
- (void)configChatWithCompletion:(void (^)(NSError *))completion{
    
    // 没有网络,直接结束
    if (![KFHelper isNetworkEnable]){
        if (completion) completion(nil);
        NSError *error = [NSError errorWithDomain:KF5Localized(@"kf5_no_internet") code:KFErrorCodeNetWorkOff userInfo:nil];
        [self delegateWithConnectError:error];
        
        return;
    }
    // 服务器已经连接
    if ([KFChatManager sharedChatManager].isConnectSuccess) {
        if (self.shouldQueueUp){
            [self queueUpWithCompletion:completion];
        }else{
            if (completion) completion(nil);
        }
        [self updateMetadata];
        [self delegateWithStatusChanage];
        return;
    }
    
    // 连接服务器
    __weak typeof(self)weakSelf = self;
    [[KFChatManager sharedChatManager]connectWithCompletion:^(NSError *error) {
        if (error) {
            if(completion) completion(error);
            [weakSelf delegateWithConnectError:error];
        }else{
            NSDictionary *dict = [KFChatManager sharedChatManager].selectQuestionDictionary;
            if (dict) {
                weakSelf.selectQuestionEnabled = [dict kf5_numberForKeyPath:@"enabled"].boolValue;
                weakSelf.selectQuestionisForce = [dict kf5_numberForKeyPath:@"force"].boolValue;
                weakSelf.selectQuestionOption = [dict kf5_arrayForKeyPath:@"options"];
            }
            if (weakSelf.shouldQueueUp) {
                [weakSelf queueUpWithCompletion:completion];
            }else{
                if(completion) completion(nil);
            }
            [weakSelf updateMetadata];
        }
    }];
}
// 连接socket时使用
- (BOOL)shouldQueueUp{
    KFChatStatus status = [KFChatManager sharedChatManager].chatStatus;
    return !(status == KFChatStatusChatting || status == KFChatStatusQueue || status == KFChatStatusAIAgent || self.assignAgentWhenSendedMessage);
}

#pragma mark 用户排队
- (void)queueUpWithCompletion:(void (^)(NSError *))completion{
    
    __weak typeof(self)weakSelf = self;
    void(^queueUpCompletion)(NSError *error) = ^(NSError *error){
        if (completion)completion(error);
        if (error) {
            [weakSelf delegateWithQueueError:error];
        }else{
            [weakSelf delegateWithQueueIndexChange:-1];
        }
    };
    // 如果该访客有受理客服则使用默认的受理客服,不弹出问题分配
    if ([KFChatManager sharedChatManager].assignAgentIds.count == 0 && self.selectQuestionEnabled && self.selectQuestionOption.count > 0 && [self.delegate respondsToSelector:@selector(chat:selectQuestionWithOptions:selectBlock:)]) {
        [self.delegate chat:self selectQuestionWithOptions:self.selectQuestionOption selectBlock:^(NSArray<NSNumber *> * _Nullable agentIds, BOOL cancel) {
            if (cancel) {
                if (completion) completion(nil);
            }else{
                [[KFChatManager sharedChatManager]queueUpWithAgentIds:agentIds isForce:weakSelf.selectQuestionisForce completion:queueUpCompletion];
            }
        }];
    }else{
        [[KFChatManager sharedChatManager]queueUpWithAgentIds:[KFChatManager sharedChatManager].assignAgentIds isForce:[KFChatManager sharedChatManager].isForceAssignAgent completion:queueUpCompletion];
    }
}
#pragma mark 取消排队
- (void)cancleWithCompletion:(void (^)(NSError *))completion{
    [[KFChatManager sharedChatManager]queueCancelWithCompletion:^(NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark 发送消息
- (void)sendMessageWithMessageType:(KFMessageType)messageType data:(id)data{
    
    KFMessage *message = nil;

    __weak typeof(self)weakSelf = self;
    if (self.chatStatus == KFChatStatusAIAgent && messageType == KFMessageTypeText) {
        message = [[KFChatManager sharedChatManager] sendAIText:data completion:^(KFMessage * _Nonnull me_message, KFMessage * _Nullable ai_message, NSError * _Nullable error) {
            if (ai_message)
                [weakSelf delegateWithAddMessages:@[ai_message]];
        }];
    }else{
        switch (messageType) {
            case KFMessageTypeText:{
                message = [[KFChatManager sharedChatManager] sendText:data completion:^(KFMessage * _Nonnull message, NSError * _Nullable error) {
                    if (error) return ;
                    
                    if (weakSelf.assignAgentWhenSendedMessage && [KFChatManager sharedChatManager].chatStatus == KFChatStatusNone) {
                        [weakSelf queueUpWithCompletion:^(NSError *error) {
                            [weakSelf delegateWithStatusChanage];
                        }];
                    }else{
                        [weakSelf delegateWithStatusChanage];
                    }
                }];
            }
                break;
            case KFMessageTypeImage:{
                message = [[KFChatManager sharedChatManager] sendImage:data completion:nil];
            }
                break;
            case KFMessageTypeVoice:{
                message = [[KFChatManager sharedChatManager] sendVoice:data completion:nil];
            }
                break;
            default:
                break;
        }
    }
    if (message) {
        [self delegateWithAddMessages:@[message]];
    }
}
#pragma mark 获取问题的答案
- (void)getAnswerWithQuestionId:(NSInteger)questionId questionTitle:(NSString *)questionTitle{
    if (self.chatStatus == KFChatStatusAIAgent) {
        __weak typeof(self)weakSelf = self;
        KFMessage *message = [[KFChatManager sharedChatManager]sendAIQuestionId:questionId questionTitle:questionTitle completion:^(KFMessage * _Nonnull me_message, KFMessage * _Nullable ai_message, NSError * _Nullable error) {
            if (ai_message)
                [weakSelf delegateWithAddMessages:@[ai_message]];
            
        }];
        [self delegateWithAddMessages:@[message]];
    }else{
        [self sendMessageWithMessageType:KFMessageTypeText data:questionTitle];
    }

}

- (void)resendMessageModel:(KFMessageModel *)messageModel{
    [[KFChatManager sharedChatManager]resendMessage:messageModel.message completion:^(KFMessage * _Nonnull message, NSError * _Nullable error) {
    }];
}

#pragma mark 发送满意度
- (void)sendRating:(NSInteger)rating completion:(void (^)(NSError * _Nullable))completion{
    [[KFChatManager sharedChatManager]sendRating:rating completion:completion];
}
#pragma mark 更新IM自定义信息
- (void)updateMetadata{
    if (self.metadata.count > 0) {
        [[KFChatManager sharedChatManager]uploadMetadata:self.metadata completion:^(NSError * _Nullable error) {
        }];
    }
}
#pragma mark 监测是否可以发送信息
static BOOL isCanSendChecking = NO;

- (void)setAssignAgentWhenSendedMessage:(BOOL)assignAgentWhenSendedMessage{
    _assignAgentWhenSendedMessage = assignAgentWhenSendedMessage;
    isCanSendChecking = NO;
}

- (BOOL)canSendMessageWithCompletion:(void (^)(void))completion{
    if (isCanSendChecking) return NO;
    // 如果socket未连接,则直接上ChatManager管理消息的处理,无需判断客服有无
    if (![KFChatManager sharedChatManager].isConnectSuccess) return YES;
    // 如果是机器人客服,则设置为YES
    if ([KFChatManager sharedChatManager].chatStatus != KFChatStatusNone) return YES;
    
    if (![KFChatManager sharedChatManager].currentAgent && !self.assignAgentWhenSendedMessage) {
        isCanSendChecking = YES;
        [self queueUpWithCompletion:^(NSError *error) {
            if(completion)completion();
            isCanSendChecking = NO;
        }];
        return NO;
    }
    return YES;
}
#pragma mark 满意度评价显示数组
- (NSArray <NSNumber *> *)rateLevelArray{
    if ([KFChatManager sharedChatManager].rateLevelCount == 5){
        return @[@(KFChatRatingScoreGreat),@(KFChatRatingScoreGood),@(KFChatRatingScoreOk),@(KFChatRatingScoreSoso),@(KFChatRatingScoreBad)];
    }else if ([KFChatManager sharedChatManager].rateLevelCount == 3){
        return @[@(KFChatRatingScoreGreat), @(KFChatRatingScoreOk),@(KFChatRatingScoreBad)];
    } else{
        return @[@(KFChatRatingScoreGreat), @(KFChatRatingScoreBad)];
    }
}
#pragma mark 满意度对应的内容
+ (NSString *)stringForRatingScore:(KFChatRatingScore)ratingScore{
    switch (ratingScore) {
        case KFChatRatingScoreBad:
            return KF5Localized(@"kf5_bad");
            break;
        case KFChatRatingScoreSoso:
            return KF5Localized(@"kf5_soso");
            break;
        case KFChatRatingScoreOk:
            return KF5Localized(@"kf5_ok");
            break;
        case KFChatRatingScoreGood:
            return KF5Localized(@"kf5_good");
            break;
        case KFChatRatingScoreGreat:
            return KF5Localized(@"kf5_great");
            break;
        default:
            return nil;
            break;
    }
}
#pragma mark 获取聊天消息未读数
+ (void)getUnReadMessageCountWithCompletion:(void (^)(NSInteger, NSError * _Nullable))completion{
    [[KFChatManager sharedChatManager]initializeWithUserToken:[KFUserManager shareUserManager].user.userToken];
    [[KFChatManager sharedChatManager]getUnReadMessageCountWithCompletion:completion];
}

#pragma mark - KFChatManagerDelegate
// 接受聊天消息通知
- (void)chatManager:(KFChatManager *)chatManager receiveMessages:(nonnull NSArray<KFMessage *> *)chatMessages{
    [self delegateWithAddMessages:chatMessages];
}
// 接收聊天消息撤回通知
- (void)chatManager:(KFChatManager *)chatManager receiveRecallMessages:(nonnull NSArray<KFMessage *> *)chatMessages{
    [self delegateWithReloadMessages:chatMessages];
}
// 用户排队的当前位置通知
- (void)chatManager:(KFChatManager *)chatManager queueIndex:(NSInteger)queueIndex{
    [self delegateWithQueueIndexChange:queueIndex];
}
// 用户排队失败的通知
- (void)chatManager:(KFChatManager *)chatManager queueError:(NSError *)error{
    [self delegateWithQueueError:error];
}
// 分配到客服/转接客服通知
- (void)chatManager:(KFChatManager *)chatManager currectAgent:(KFAgent *)agent{
    [self delegateWithStatusChanage];
}
// 客服关闭对话通知
- (void)chatManagerEndChat:(KFChatManager *)chatManager{
    [self delegateWithEndChat];
}
// 客服发起满意度评价通知
- (void)chatManagerRating:(KFChatManager *)chatManager{
    [self delegateWithAgentRating];
}

#pragma mark - 获取数据
- (NSArray<KFMessageModel *> *)queryMessageModelsWithLimit:(NSInteger)limit{
    
    if (self.sqlOffSet == -1)
        self.sqlOffSet = [[KFChatManager sharedChatManager]queryMessagesCount];
    
    NSArray *array = [[KFChatManager sharedChatManager]queryMessagesWithLastCount:self.sqlOffSet limit:limit];
    self.sqlOffSet -= array.count;
    
    return [self messageModelsWithMessages:array];
}

#pragma mark  KFMessage转成KFMessageModel
- (NSArray <KFMessageModel *>*)messageModelsWithMessages:(NSArray <KFMessage *>*)messages{
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:messages.count];
    for (KFMessage *message in messages) {
        KFMessageModel *model = [[KFMessageModel alloc] initWithMessage:message];
        [modelArray addObject:model];
    }
    return modelArray;
}

#pragma mark - 调用代理
/**连接服务器失败*/
- (void)delegateWithConnectError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(chat:connectError:)]) {
        [self.delegate chat:self connectError:error];
    }
}

/**排队人数变化*/
- (void)delegateWithQueueIndexChange:(NSInteger)queueIndex{
    if ([self.delegate respondsToSelector:@selector(chat:queueIndexChange:)]) {
        [self.delegate chat:self queueIndexChange:queueIndex];
    }
}
/**排队失败*/
- (void)delegateWithQueueError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(chat:queueError:)]) {
        [self.delegate chat:self queueError:error];
    }
}

///状态改变
- (void)delegateWithStatusChanage{
    if ([self.delegate respondsToSelector:@selector(chat:statusChange:)]) {
        [self.delegate chat:self statusChange:self.chatStatus];
    }
}
/** 客服发起满意度评价请求*/
- (void)delegateWithAgentRating{
    if ([self.delegate respondsToSelector:@selector(chatWithAgentRating:)]) {
        [self.delegate chatWithAgentRating:self];
    }
}
/**对话被客服关闭*/
- (void)delegateWithEndChat{
    if ([self.delegate respondsToSelector:@selector(chatWithEndChat:)]) {
        [self.delegate chatWithEndChat:self];
    }
}
/**添加数据*/
- (void)delegateWithAddMessages:(NSArray <KFMessage *>*)messages{
    if ([self.delegate respondsToSelector:@selector(chat:addMessageModels:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate chat:self addMessageModels:[self messageModelsWithMessages:messages]];
        });
    }
}
/**更新数据**/
- (void)delegateWithReloadMessages:(NSArray <KFMessage *>*)messages{
    if ([self.delegate respondsToSelector:@selector(chat:reloadMessageModels:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate chat:self reloadMessageModels:[self messageModelsWithMessages:messages]];
            });
    }
}

- (void)dealloc{
    [[KFChatManager sharedChatManager]removeObserver:self forKeyPath:@"chatStatus"];
    [[KFChatManager sharedChatManager]setUserOffline];
}

@end
