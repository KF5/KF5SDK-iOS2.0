//
//  KFChatViewModel.m
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import "KFChatViewModel.h"
#import "KFHelper.h"
#import <KF5SDK/KFChatManager.h>
#import "KFUserManager.h"
#import "KFHelper.h"
#import "KFMessageModel.h"

@interface KFChatViewModel()<KFChatManagerDelegate>

@property (nonatomic, assign) NSInteger sqlOffSet;

@property (nonatomic, copy) void (^recordCompletion)(NSData *recordData ,NSError *error);
@property (nonatomic, copy) void (^amplitudeChange)(double amplitude);

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

- (void)disconnect{
    [[KFChatManager sharedChatManager]setUserOffline];
}
#pragma mark - 连接请求
- (void)configChatWithCompletion:(void (^)())completion{
    
    // 没有网络,直接结束
    if (![KFHelper isNetworkEnable]){
        NSError *error = [NSError errorWithDomain:KF5Localized(@"kf5_no_internet") code:KFErrorCodeNetWorkOff userInfo:nil];
        [self delegateWithConnectError:error];
        if (completion)completion();
        
        return;
    }
    // 服务器已经连接
    if ([KFChatManager sharedChatManager].isConnectSuccess) {
        [self delegateWithStatusChanage];
        [self getAgentWithCompletion:completion];
        [self updateMetadata];
        return;
    }
    
    // 连接服务器
    __weak typeof(self)weakSelf = self;
    [[KFChatManager sharedChatManager]connectWithCompletion:^(NSError *error) {
        if (error) {
            [weakSelf delegateWithConnectError:error];
            if(completion)completion();
        }else{
            [weakSelf syncMessage];
            [weakSelf getAgentWithCompletion:completion];
            [weakSelf updateMetadata];
        }
    }];
}

#pragma mark 判断是否有正在进行的对话
- (void)getAgentWithCompletion:(void (^)())completion{
    switch ([KFChatManager sharedChatManager].chatStatus) {
        case KFChatStatusChatting:{ // 正在进行聊天
            [self delegateWithAgentChange:[KFChatManager sharedChatManager].currentAgent];
            if(completion)completion();
        }
            break;
        case KFChatStatusQueue:{ // 排队
            [self delegateWithQueueing];
            if(completion)completion();
        }
            break;
        case KFChatStatusAIAgent:{ // 没有状态,且开启机器人,则机器人
            [self delegateWithAgentChange:[KFChatManager sharedChatManager].AIAgent];
            if (completion) completion();
        }
            break;
        default:{// KFChatStatusNone或其他值
            [self queueUpWithCompletion:completion];
        }
            break;
    }
}

#pragma mark 用户排队
- (void)queueUpWithCompletion:(void (^)())completion{
    
    [self delegateWithQueueing];
    
    __weak typeof(self)weakSelf = self;
    [[KFChatManager sharedChatManager]queueUpWithCompletion:^(NSError *error) {
        if (error) {
            [weakSelf delegateWithQueueError:error];
        }
        if (completion)completion();
    }];
}

- (void)cancleWithCompletion:(void (^)(NSError *))completion{
    [[KFChatManager sharedChatManager]queueCancelWithCompletion:^(NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - KFChatManager主动请求
- (void)syncMessage{
    __weak KFChatViewModel *weakSelf = self;
    [[KFChatManager sharedChatManager]syncMessageWithCompletion:^(NSArray<KFMessage *> *history, NSError *error) {
        if (history.count > 0) {
            [weakSelf delegateWithaddMessageModels:history];
        }
    }];
}
#pragma mark 发送消息
- (void)sendMessageWithMessageType:(KFMessageType)messageType data:(id)data{
    
    __weak typeof(self)weakSelf = self;
    KFMessage *message = nil;
    KFChatStatus chatStatus = self.chatStatus;
    switch (messageType) {
        case KFMessageTypeText:{
            if (chatStatus == KFChatStatusAIAgent) {
                message = [[KFChatManager sharedChatManager] sendAIText:data completion:^(KFMessage * _Nonnull me_message, KFMessage * _Nullable ai_message, NSError * _Nullable error) {
                    if (ai_message && [weakSelf.delegate respondsToSelector:@selector(chat:addMessageModels:)]) {
                            [weakSelf.delegate chat:weakSelf addMessageModels:[weakSelf messageModelsWithMessages:@[ai_message]]];
                    }
                }];
            }else{
                message = [[KFChatManager sharedChatManager] sendText:data completion:^(KFMessage * _Nonnull message, NSError * _Nullable error) {
                    if (!error && chatStatus == KFChatStatusQueue) {
                        [KFHelper setHasChatQueueMessage:YES];
                        // 排队期间发送一条消息用于提问,之后就不能发送消息了
                        // 为了方式在发送消息过程中,状态已经发生变化,则先判断消息成功之后的状态
                        [weakSelf delegateWithStatusChanage];
                    }
                }];
            }
        }
            break;
        case KFMessageTypeImage:{
            message = [[KFChatManager sharedChatManager] sendImage:data completion:^(KFMessage * _Nonnull message, NSError * _Nullable error) {
                
            }];
        }
            break;
        case KFMessageTypeVoice:{
            message = [[KFChatManager sharedChatManager] sendVoice:data completion:^(KFMessage * _Nonnull message, NSError * _Nullable error) {
                
            }];
        }
            break;
        default:
            break;
    }
    
    if (message) {
        [self delegateWithaddMessageModels:@[message]];
    }
}
- (void)resendMessageModel:(KFMessageModel *)messageModel{
    [[KFChatManager sharedChatManager]resendMessage:messageModel.message completion:^(KFMessage * _Nonnull message, NSError * _Nullable error) {
    }];
}

#pragma mark 发送满意度
- (void)sendRating:(BOOL)rating completion:(void (^)(NSError * _Nullable))completion{
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

- (BOOL)canSendMessageWithCompletion:(void (^)())completion{
    if (isCanSendChecking) return NO;
    // 如果socket未连接,则直接上ChatManager管理消息的处理,无需判断客服有无
    if (![KFChatManager sharedChatManager].isConnectSuccess) return YES;
    // 如果是机器人客服,则设置为YES
    if ([KFChatManager sharedChatManager].chatStatus != KFChatStatusNone) return YES;
    
    if (![KFChatManager sharedChatManager].currentAgent) {
        isCanSendChecking = YES;
        [self queueUpWithCompletion:^() {
            if(completion)completion();
            isCanSendChecking = NO;
        }];
        return NO;
    }
    return YES;
}

#pragma mark - KFChatManagerDelegate
// 接受聊天消息通知
- (void)chatManager:(KFChatManager *)chatManager receiveMessage:(KFMessage *)chatMessage{
    [self delegateWithaddMessageModels:@[chatMessage]];
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
    [self delegateWithAgentChange:agent];
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
/**排队中*/
- (void)delegateWithQueueing{
    if ([self.delegate respondsToSelector:@selector(chatWithQueueing:)]) {
        [self.delegate chatWithQueueing:self];
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
/** 获取到客服*/
- (void)delegateWithAgentChange:(KFAgent *)agent{
    
    if ([self.delegate respondsToSelector:@selector(chat:agentChange:)]) {
        [self.delegate chat:self agentChange:agent];
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
/**刷新数据*/
- (void)delegateWithaddMessageModels:(NSArray <KFMessage *>*)history{
    if ([self.delegate respondsToSelector:@selector(chat:addMessageModels:)]) {
        [self.delegate chat:self addMessageModels:[self messageModelsWithMessages:history]];
    }
}

- (void)dealloc{
    [[KFChatManager sharedChatManager]removeObserver:self forKeyPath:@"chatStatus"];
    [[KFChatManager sharedChatManager]setUserOffline];
}

@end
