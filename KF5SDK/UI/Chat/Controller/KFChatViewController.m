//
//  KFChatViewController.m
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import "KFChatViewController.h"
#import "KFChatTableView.h"
#import "KFChatToolView.h"
#import "KFChatViewModel.h"
#import "KFCategory.h"
#import "KFAlertMessage.h"
#import "KFRecordView.h"
#import "KFChatVoiceManager.h"
#import "KFPreviewController.h"
#import "KFContentLabelHelp.h"
#import "KFSelectQuestionController.h"
#import "KFPreViewController.h"

#if __has_include("KFDocumentViewController.h")
#import "KFDocumentViewController.h"
#import "KFDocItem.h"
#define KFHasDoc 1
#else
#define KFHasDoc 0
#endif

#if __has_include("KF5SDKTicket.h")
#import "KF5SDKTicket.h"
#define KFHasTicket 1
#else
#define KFHasTicket 0
#endif

@interface KFChatViewController () <KFChatTooViewDelegate,KFChatViewModelDelegate,KFChatVoiceManagerDelegate,KFChatTableViewDelegate,KFChatViewCellDelegate,UIWebViewDelegate>{
    dispatch_once_t _scrollBTMOnce;
}

@property (nonatomic, weak) KFChatTableView *tableView;
@property (nonatomic, weak) KFChatToolView *chatToolView;
@property (nonatomic, strong) KFChatViewModel *viewModel;
@property (nonatomic, weak) KFRecordView *recordView;

@property (nonnull, nonatomic, strong) KFMessageModel *queueMessageModel;
// 用于拨打电话
@property (nullable, nonatomic, weak) UIWebView *webView;

@property (nullable, nonatomic, strong) NSArray <NSDictionary *>*metadata;
/**
 卡片消息
 */
@property (nullable, nonatomic,strong) NSDictionary *cardDict;

@property (nonatomic,weak) NSLayoutConstraint *toolBottomLayout;

@end

@implementation KFChatViewController

- (instancetype)initWithMetadata:(NSArray<NSDictionary *> *)metadata{
    self = [super init];
    if (self) {
        _metadata = metadata;
        _limit = 30;
        _showAlertWhenNoAgent = YES;
        _isHideRightButton = NO;
        _assignAgentWhenSendedMessage = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self layoutView];
    
    self.viewModel = [[KFChatViewModel alloc]init];
    self.viewModel.metadata = self.metadata;
    self.viewModel.assignAgentWhenSendedMessage = self.assignAgentWhenSendedMessage;
    self.viewModel.delegate = self;
    [KFChatVoiceManager sharedChatVoiceManager].delegate = self;
    
    // 解决speakBtn的UIControlEventTouchDown响应延迟的问题
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 进入后台断开与服务器的连接
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 进入前台连接服务器
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 连接服务器
    [self connectServer];

    NSMutableArray <KFMessageModel *>*newDatas = [NSMutableArray arrayWithArray:[self.viewModel queryMessageModelsWithLimit:self.limit]];
    self.tableView.canRefresh = newDatas.count >= self.limit;
    self.tableView.messageModels = newDatas;
    [self.tableView reloadData];
}

#pragma mark 连接服务器
- (void)connectServer{
    self.title = KF5Localized(@"kf5_connecting");
    [KFProgressHUD showLoadingTo:self.view title:nil];
    __weak typeof(self)weakSelf = self;
    [self.viewModel configChatWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD hideHUDForView:weakSelf.view];
            if (weakSelf.cardDict && !error && weakSelf.view.tag == 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    KFMessageModel *model = [[KFMessageModel alloc] initWithMessage:[KFChatManager createMessageWithType:KFMessageTypeCard data:[KFHelper JSONStringWithObject:weakSelf.cardDict]]];
                    [weakSelf chat:weakSelf.viewModel addMessageModels:@[model]];
                });
                weakSelf.view.tag = 1;
            }
        });
    }];
}

#pragma mark 初始化subView
- (void)setupView{
    
    KFChatTableView *tableView = [[KFChatTableView alloc]init];
    tableView.tableDelegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 添加输入框视图
    KFChatToolView *chatToolView = [[KFChatToolView alloc]init];
    chatToolView.tag = kKF5ChatToolViewTag;
    chatToolView.assignAgentWhenSendedMessage = self.assignAgentWhenSendedMessage;
    chatToolView.delegate = self;
    chatToolView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:chatToolView];
    self.chatToolView = chatToolView;
    
    // 录音视图
    KFRecordView *recordView = [[KFRecordView alloc]init];
    recordView.tag = kKF5RecordViewTag;
    recordView.hidden = YES;
    self.recordView = recordView;
    [self.view addSubview:recordView];
    
    // 用于打电话
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
#if KFHasTicket
    if (!self.isHideRightButton && !self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:KF5Localized(@"kf5_ticket") style:UIBarButtonItemStyleDone target:self action:@selector(pushTicket)];
    }
#endif
}

- (void)layoutView {
    [self.tableView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self.view.kf5_safeAreaLayoutGuideLeft);
        make.right.kf_equalTo(self.view.kf5_safeAreaLayoutGuideRight);
        make.top.kf_equalTo(self.view);
        make.bottom.kf_equalTo(self.chatToolView.kf5_top);
    }];
    
    [self.chatToolView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self.view.kf5_safeAreaLayoutGuideLeft);
        make.right.kf_equalTo(self.view.kf5_safeAreaLayoutGuideRight);
        self.toolBottomLayout = make.bottom.kf_equalTo(self.view.kf5_safeAreaLayoutGuideBottom).active;
    }];
    
    [self.recordView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.width.kf_equal(150);
        make.height.kf_equal(132);
        make.centerX.kf_equalTo(self.view);
        make.centerY.kf_equalTo(self.view);
    }];
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = self.chatToolView.backgroundColor;
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = KF5Helper.KF5ChatToolViewLineColor;
    [bottomView addSubview:lineView];
    [self.view insertSubview:bottomView belowSubview:self.chatToolView];
    [lineView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(bottomView);
        make.left.kf_equalTo(bottomView);
        make.right.kf_equalTo(bottomView);
        make.height.kf_equal(0.5);
    }];
    [bottomView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self.chatToolView).kf_offset(-0.5);
        make.left.kf_equalTo(self.view);
        make.right.kf_equalTo(self.view);
        make.bottom.kf_equalTo(self.view);
    }];
}

#if KFHasTicket
- (void)pushTicket{
    [self.navigationController pushViewController:[[KFTicketListViewController alloc] init] animated:YES];
}
#endif

#pragma mark - KFChatViewModelDelegate
#pragma mark 连接服务器失败
- (void)chat:(KFChatViewModel *)chat connectError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = KF5Localized(@"kf5_not_connected");
        [self showMessageWithText:error.domain];
    });
}
#pragma mark 状态变化
- (void)chat:(KFChatViewModel *)chat statusChange:(KFChatStatus)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatToolView.chatToolViewType = status;
        switch (status) {
            case KFChatStatusNone:
                self.title = KF5Localized(@"kf5_chat");
                break;
            case KFChatStatusQueue:
                self.title = KF5Localized(@"kf5_queue_waiting");
                break;
            case KFChatStatusAIAgent:
            case KFChatStatusChatting:{
                [self removeQueueMessage];
                self.title = self.viewModel.currentAgent.displayName;
            }
                break;
            default:
                break;
        }
    });
}
#pragma mark 排队失败
- (void)chat:(KFChatViewModel *)chat queueError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self removeQueueMessage];
        
        NSString *message = nil;
        if (error.code == KFErrorCodeAgentOffline) {
            message = KF5Localized(@"kf5_no_agent_online");
        }else if (error.code == KFErrorCodeNotInServiceTime){
            message = KF5Localized(@"kf5_not_in_service_time");
        }else if (error.code == KFErrorCodeQueueTooLong){
            message = KF5Localized(@"kf5_queue_too_long");
        }else{
            message = KF5Localized(@"kf5_queue_error");
        }
        
        [self showMessageWithText:message];
        
        if (self.isShowAlertWhenNoAgent) {
            __weak typeof(self)weakSelf = self;
            [[KFHelper alertWithMessage:[NSString stringWithFormat:@"%@,%@",message,KF5Localized(@"kf5_leaving_message")] confirmHandler:^(UIAlertAction *action) {
                if (weakSelf.noAgentAlertActionBlock) {
                    weakSelf.noAgentAlertActionBlock();
                }else{
#if KFHasTicket
                    [weakSelf presentViewController:[[UINavigationController alloc] initWithRootViewController:[KFCreateTicketViewController new]] animated:YES completion:nil];
#else
#warning 没有添加KF5SDKUI/Ticket
#endif
                }
            }]showToVC:self];
        }
    });
}

#pragma mark 排队变化
- (void)chat:(KFChatViewModel *)chat queueIndexChange:(NSInteger)queueIndex{
    KFMessage *message = [[KFMessage alloc] init];
    message.messageType = KFMessageTypeSystem;
    message.created = [NSDate date].timeIntervalSince1970;
    message.content = queueIndex == -1? KF5Localized(@"kf5_update_queue") : [NSString stringWithFormat:KF5Localized(@"kf5_update_queue_%ld"),queueIndex + 1];
    message.timestamp = message.created * 1000;
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        [self.tableView reloadData:KFScrollTypeBottom handleModelBlock:^NSDictionary<NSString *,NSArray<NSIndexPath *> *> *(NSMutableArray<KFMessageModel *> *messageModels) {
            NSIndexPath *deleteIndexPath = nil;
            if (weakSelf.queueMessageModel) {
                NSInteger index = [messageModels indexOfObject:weakSelf.queueMessageModel];
                if (index != NSNotFound) {
                    deleteIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [messageModels removeObject:weakSelf.queueMessageModel];
                }
            }
            weakSelf.queueMessageModel = [[KFMessageModel alloc] initWithMessage:message];
            [messageModels addObject:weakSelf.queueMessageModel];
            NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:messageModels.count - 1 inSection:0];
            if (deleteIndexPath && deleteIndexPath.row == insertIndexPath.row) {
                return @{@"reload":@[insertIndexPath]};
            }else{
                return @{@"insert":@[insertIndexPath],@"delete":deleteIndexPath? @[deleteIndexPath] : @[]};
            }
        }];
    });
}

#pragma mark 客服发起满意度评价请求
- (void)chatWithAgentRating:(KFChatViewModel *)chat{
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self)weakSelf = self;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:KF5Localized(@"kf5_reminder") message:KF5Localized(@"kf5_rating_content") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:KF5Localized(@"kf5_cancel") style:UIAlertActionStyleCancel handler:nil]];
        for (NSNumber *ratingNum in self.viewModel.rateLevelArray) {
            NSString *title = [KFChatViewModel stringForRatingScore:ratingNum.integerValue];
            if (title.length > 0) {
                [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf sendRating:ratingNum.integerValue];
                }]];
            }
        }
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark 对话被客服关闭
- (void)chatWithEndChat:(KFChatViewModel *)chat{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessageWithText:KF5Localized(@"kf5_chat_ended")];
    });
}
#pragma mark 添加数据
- (void)chat:(KFChatViewModel *)chat addMessageModels:(NSArray <KFMessageModel *>*)addMessageModels{
    if (addMessageModels.count == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData:KFScrollTypeBottom handleModelBlock:^NSDictionary<NSString *,NSArray<NSIndexPath *> *> *(NSMutableArray<KFMessageModel *> *messageModels) {
            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:addMessageModels.count];
            for (NSInteger index = 0; index < addMessageModels.count; index++) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:messageModels.count + index inSection:0]];
            }
            [messageModels addObjectsFromArray:addMessageModels];
            return @{@"insert":insertIndexPaths};
        }];
    });
}
#pragma mark 更新数据
- (void)chat:(KFChatViewModel *)chat reloadMessageModels:(NSArray<KFMessageModel *> *)reloadMessageModels{
    if (reloadMessageModels.count == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData:KFScrollTypeHold handleModelBlock:^NSDictionary<NSString *,NSArray<NSIndexPath *> *> *(NSMutableArray<KFMessageModel *> *messageModels) {
            NSMutableArray *reloadIndexPaths = [NSMutableArray arrayWithCapacity:messageModels.count];
            for (KFMessageModel *model in reloadMessageModels) {
                NSInteger index = [messageModels indexOfObject:model];
                if (index != NSNotFound) {
                    [reloadIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                    if (model.message.local_path.length == 0) {
                        model.message.local_path = messageModels[index].message.local_path;
                    }
                    messageModels[index] = model;
                }
            }
            return @{@"reload":reloadIndexPaths};
        }];
    });

}
#pragma mark 删除排队消息
- (void)removeQueueMessage{
    if (self.queueMessageModel == nil) { return; }

    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        [self.tableView reloadData:KFScrollTypeBottom handleModelBlock:^NSDictionary<NSString *,NSArray<NSIndexPath *> *> *(NSMutableArray<KFMessageModel *> *messageModels) {
            NSInteger index = [messageModels indexOfObject:weakSelf.queueMessageModel];
            if (index == NSNotFound) { return @{}; }
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [messageModels removeObjectAtIndex:index];
            return @{@"delete":@[deleteIndexPath]};
        }];
    });
}
#pragma mark 获取分配的问题
- (void)chat:(KFChatViewModel *)chat selectQuestionWithOptions:(nonnull NSArray<NSDictionary *> *)options selectBlock:(void (^ _Nullable)(NSNumber * _Nullable, BOOL))selectBlock{
    [KFSelectQuestionController selectQuestionWithViewController:self questions:options selectBlock:selectBlock];
}

#pragma mark - KFChatVoiceManagerDelegate
- (void)chatVoiceManager:(KFChatVoiceManager *)voiceManager voiceFileURL:(NSURL *)voiceFileURL error:(NSError *)error{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showTitleToView:self.view title:error.domain hideAfter:0.7f];
        });
    }else{
        [self.viewModel sendMessageWithMessageType:KFMessageTypeVoice data:voiceFileURL];
    }
}
- (void)chatVoiceManager:(KFChatVoiceManager *)chatManager recordingAmplitude:(CGFloat)amplitude{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordView.amplitude = amplitude;
    });
}
#pragma mark - KFChatToolViewDelegate
#pragma mark textView需要发送信息
- (void)chatToolView:(KFChatToolView *)chatToolView shouldSendContent:(NSString  *)content{
    NSString *text = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) return;
    [self.viewModel sendMessageWithMessageType:KFMessageTypeText data:text];
}
#pragma mark 添加图片按钮点击事件
- (void)chatToolViewWithAddPictureAction:(KFChatToolView *)chatToolView{
    if (![self canSendMessage]) return;
    
    __weak typeof(self)weakSelf = self;
    UIViewController *imagePickerVC = [KFHelper imagePickerControllerWithImageHandle:^(NSArray<UIImage *> *photos, NSArray *assets) {
        if (photos.count > 0){
            UIImage *newImage = [UIImage imageWithData:UIImageJPEGRepresentation(photos.firstObject, 1)];
            [weakSelf.viewModel sendMessageWithMessageType:KFMessageTypeImage data:newImage];
        }
    } videoHandle:^(UIImage *coverImage, NSURL *videoURL, NSString *videoName, NSError *error, UIViewController *vc) {
        if (error) {
            [vc presentViewController:[KFHelper alertWithMessage:error.domain] animated:YES completion:nil];
        }else if (videoURL != nil && videoName != nil){
            [weakSelf.viewModel sendMessageWithMessageType:KFMessageTypeVideo data:videoURL];
        }
    }];
    if (imagePickerVC) {
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }else{
        [KFLogger log:@"请添加自己的图片选择器"];
    }
}
#pragma mark 转接人工客服点击事件
- (void)chatToolViewWithTransferAction:(KFChatToolView *)chatToolView{
    
    if (self.viewModel.chatStatus == KFChatStatusChatting) {
        [KFProgressHUD showTitleToView:self.view title:KF5Localized(@"kf5_chat_manual") hideAfter:0.7];
    }else if (self.viewModel.chatStatus == KFChatStatusQueue){
        [KFProgressHUD showTitleToView:self.view title:KF5Localized(@"kf5_chat_queued") hideAfter:0.7];
    }else{
        [KFProgressHUD showLoadingTo:self.view title:@""];
        __weak typeof(self)weakSelf = self;
        [self.viewModel queueUpWithCompletion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD hideHUDForView:weakSelf.view];
            });
        }];
    }
}
#pragma mark 开始录音
- (void)chatToolViewStartVoice:(KFChatToolView *)chatToolView{
    [[KFChatVoiceManager sharedChatVoiceManager]startVoiceRecord];
}

#pragma mark 取消录音
- (void)chatToolViewCancelVoice:(KFChatToolView *)chatToolView{
    [[KFChatVoiceManager sharedChatVoiceManager]cancleVoiveRecord];
}
#pragma mark 完成录音
- (void)chatToolViewCompleteVoice:(KFChatToolView *)chatToolView{
    [[KFChatVoiceManager sharedChatVoiceManager]stopVoiceRecord];
}
#pragma mark 点击语音图标按钮点击事件
- (BOOL)chatToolViewWithClickVoiceAction:(KFChatToolView *)chatToolView{
    return [self canSendMessage];
}
#pragma mark textView输入监听
- (BOOL)chatToolView:(KFChatToolView *)chatToolView didChangeReplacementText:(NSString *)text{
    // 如果当前输入的字符大于0 ,则是正在输出内容,等于0,则为在删除数据
    BOOL canSend = text.length > 0 ? [self canSendMessage] : YES;
    if (canSend && ![text isEqualToString:@"\n"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (self.tableView.contentOffset.y + self.tableView.frame.size.height != self.tableView.contentSize.height) {
                [self.tableView scrollViewBottomWithAnimated:NO];
            }
        });
    }
    return canSend;
}

#pragma mark - KFChatTableViewDelegate
- (void)tableViewWithRefreshData:(KFChatTableView *)tableView{
    NSArray *newDatas = [self.viewModel queryMessageModelsWithLimit:self.limit];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.messageModels.count > 0 && newDatas.count > 0) {
            [self.tableView reloadData:KFScrollTypeBottom handleModelBlock:^NSDictionary<NSString *,NSArray<NSIndexPath *> *> *(NSMutableArray<KFMessageModel *> *messageModels) {
                [messageModels insertObjects:newDatas atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newDatas.count)]];
                
                NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:newDatas.count];
                for (NSInteger index = 0; index < newDatas.count; index++) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                }
                return @{@"insert":insertIndexPaths};
            }];
        }
        self.tableView.canRefresh = newDatas.count >= self.limit;
        self.tableView.refreshing = NO;
    });
}
#pragma mark - KFChatViewCellDelegate
#pragma mark - 失败消息重发
- (void)cell:(KFChatViewCell *)cell reSendMessageWithMessageModel:(KFMessageModel *)model{
    if (self.viewModel.chatStatus != KFChatStatusChatting) return;
    __weak typeof(self)weakSelf = self;
    [[KFHelper alertWithMessage:KF5Localized(@"kf5_resend_message") confirmHandler:^(UIAlertAction * _Nonnull action) {
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        if (!indexPath || indexPath.row > weakSelf.tableView.messageModels.count - 1) return;
        
        [weakSelf.viewModel resendMessageModel:model];
        [weakSelf.tableView.messageModels removeObject:model];
        [weakSelf.tableView.messageModels addObject:model];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger rowCount = [weakSelf.tableView numberOfRowsInSection:0];
            @try {
                [weakSelf.tableView beginUpdates];
                if (rowCount > 1) {
                    [weakSelf.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:rowCount-1 inSection:0]];
                }else{
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                [weakSelf.tableView endUpdates];
            } @catch (NSException *exception) {
            }
        });
    }]showToVC:self];
}

- (void)cell:(KFChatViewCell *)cell clickImageWithMessageModel:(KFMessageModel *)model{
    
    KFImageMessageCell *imageCell = (KFImageMessageCell *)cell;
    NSURL *largeImageURL = nil;
    if (model.message.local_path.length > 0) {
        largeImageURL = [NSURL fileURLWithPath:model.message.local_path];
    }else{
        largeImageURL = [NSURL URLWithString:model.message.url];
    }
    [KFPreviewController setPlaceholderErrorImage:KF5Helper.placeholderImageFailed];
    [KFPreviewController presentForViewController:self models:@[[[KFPreviewModel alloc] initWithValue:largeImageURL placeholder:imageCell.messageImageView.image]] selectIndex:0];
}

- (void)cell:(KFChatViewCell *)cell clickVideoWithMessageModel:(KFMessageModel *)messageModel image:(UIImage *)image{
    [self.view endEditing:NO];
    
    BOOL hasLocal = messageModel.message.local_path.length > 0 ? [[NSFileManager defaultManager]fileExistsAtPath:messageModel.message.local_path] : NO;
    KFPlayerController *player = [[KFPlayerController alloc] init];
    [player assetWithModel:[[KFPreviewModel alloc] initWithValue:hasLocal ? [NSURL fileURLWithPath:messageModel.message.local_path] : [NSURL URLWithString:messageModel.message.url] placeholder:image isVideo:YES]];
    [self presentViewController:player animated:YES completion:nil];
}

- (void)cell:(KFChatViewCell *)cell clickCardLinkWithUrl:(NSString *)linkUrl{
    if (linkUrl.length == 0) {
        return;
    }
    [self.viewModel sendMessageWithMessageType:KFMessageTypeText data:linkUrl];
}

- (void)cell:(KFChatViewCell *)cell clickLabelWithInfo:(NSDictionary *)info{
    
    kKFLinkType type = [info kf5_numberForKeyPath:KF5LinkType].unsignedIntegerValue;
    
    switch (type) {
        case kKFLinkTypePhone:{
            NSString *phone = [NSString stringWithFormat:@"tel://%@",info[KF5LinkKey]];
            NSURL *url = [NSURL URLWithString:phone];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
            });
        }
            break;
        case kKFLinkTypeURL:{
            NSURL *url = [NSURL URLWithString:[KFHelper fullURL:info[KF5LinkKey]] ?: @""];
            if (url) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[KF5LinkKey]]];
            }
        }
            break;
        case kKFLinkTypeImg:{
            [self.view endEditing:YES];
            NSURL *url = [NSURL URLWithString:[KFHelper fullURL:info[KF5LinkKey]] ?: @""];
            if (url) {
                [KFPreviewController setPlaceholderErrorImage:KF5Helper.placeholderImageFailed];
                [KFPreviewController presentForViewController:self models:@[[[KFPreviewModel alloc]initWithValue:url placeholder:KF5Helper.placeholderImage]] selectIndex:0];
            }
        }
            break;
        case kKFLinkTypeVideo:{// 可对接瞩目SDK实现应用内支持视频功能
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[KF5LinkKey]]];
        }
            break;
        case kKFLinkTypeDucument:{
#if KFHasDoc
            KFDocItem *item = [[KFDocItem alloc] init];
            item.title = info[KF5LinkTitle];
            item.Id = ((NSString *)info[KF5LinkKey]).integerValue;
            [self.navigationController pushViewController:[[KFDocumentViewController alloc] initWithPost:item] animated:YES];
#else
#warning 没有添加KF5SDKUI/Doc
            NSString *url = info[KF5LinkURL];
            if (url.length > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
#endif
        }
            break;
        case kKFLinkTypeQuestion:{
            NSString *title = info[KF5LinkTitle];
            NSInteger questionId = ((NSString *)info[KF5LinkKey]).integerValue;
            [self.viewModel getAnswerWithQuestionId:questionId questionTitle:title];
        }
            break;
        case kKFLinkTypeBracket:
            if (cell.messageModel.message.messageType == KFMessageTypeSystem) {// 去留言
                __weak typeof(self)weakSelf = self;
                [[KFHelper alertWithMessage:KF5Localized(@"kf5_cancel_queue_to_feedback") confirmHandler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.viewModel cancleWithCompletion:^(NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!error) {
                                [weakSelf removeQueueMessage];
                                [weakSelf showMessageWithText:KF5Localized(@"kf5_cancel_queued")];
                            }else{
                                [weakSelf showMessageWithText:KF5Localized(@"kf5_cancel_queue_failed")];
                            }
                        });
                    }];
                    [weakSelf.view endEditing:YES];
                    
                    if (weakSelf.noAgentAlertActionBlock) {
                        weakSelf.noAgentAlertActionBlock();
                    }else{
#if KFHasTicket
                        [weakSelf presentViewController:[[UINavigationController alloc] initWithRootViewController:[KFCreateTicketViewController new]] animated:YES completion:nil];
#else
#warning 没有添加KF5SDKUI/Ticket
#endif
                    }
                }]showToVC:self];
            }else{// 转人工
                [self chatToolViewWithTransferAction:self.chatToolView];
            }
            break;
        default:
            break;
    }
}

#pragma mark - webView的代理方法,用于拨打电话
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [[KFHelper alertWithMessage:KF5Localized(@"kf5_phone_error")]showToVC:self];
}
#pragma mark 收到键盘弹出通知后的响应
- (void)keyboardWillShow:(NSNotification *)info {
    //得到键盘的高度，即输入框需要移动的距离
    self.toolBottomLayout.constant = -([info.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height  - self.view.kf5_safeAreaInsets.bottom);
    [UIView animateWithDuration:[info.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[info.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 animations:^{
        [self.view layoutIfNeeded];
        if (self.tableView.contentSize.height > self.tableView.frame.size.height){
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height) animated:NO];
        }
    } completion:nil];
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
    self.toolBottomLayout.constant = 0;
    [UIView animateWithDuration:[info.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[info.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - 其他
- (void)didEnterBackground:(NSNotification *)note{
    [self.viewModel disconnect];
}
- (void)willEnterForeground:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f) {
            [self.view endEditing:NO];
        }
        [self connectServer];
    });
}
- (void)showMessageWithText:(NSString *)text{
    if (text.length == 0) return;
    KFAlertMessage *alert = [[KFAlertMessage alloc]initWithViewController:self title:text duration:4 showType:KF5AlertTypeWarning];
    [alert showAlert];
}
- (BOOL)canSendMessage{
    __weak typeof(self)weakSelf = self;
    BOOL canSend = [self.viewModel canSendMessageWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD hideHUDForView:weakSelf.view];
        });
    }];
    if (!canSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showDefaultLoadingTo:self.view];
        });
    }
    return canSend;
}
- (void)sendRating:(NSInteger)rating{
    
    __weak typeof(self)weakSelf = self;
    [self.viewModel sendRating:rating completion:^(NSError *error) {
        KFMessage *message = [[KFMessage alloc] init];
        message.content = error ? KF5Localized(@"kf5_rating_failure") : KF5Localized(@"kf5_rating_successfully");
        message.messageType = KFMessageTypeSystem;
        message.created = [NSDate date].timeIntervalSince1970;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf chat:weakSelf.viewModel addMessageModels:@[[[KFMessageModel alloc] initWithMessage:message]]];
        });
    }];
}

+ (void)getUnReadMessageCountWithCompletion:(void (^)(NSInteger, NSError * _Nullable))completion{
    [KFChatViewModel getUnReadMessageCountWithCompletion:completion];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
