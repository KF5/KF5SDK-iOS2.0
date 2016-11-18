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
#import "KFHelper.h"
#import "KFAlertMessage.h"
#import "JKAlert.h"
#import "KFProgressHUD.h"
#import "KFRecordView.h"
#import "KFChatVoiceManager.h"
#import "KFPhotoGroupView.h"
#import "KFContentLabelHelp.h"
#import "TZImagePickerController.h"

#if __has_include("KFDocumentViewController.h")
#import "KFDocumentViewController.h"
#import "KFDocItem.h"
#define KFHasDoc 1
#else
#define KFHasDoc 0
#endif

#if __has_include("KFCreateTicketViewController.h")
#import "KFCreateTicketViewController.h"
#define KFHasTicket 1
#else
#define KFHasTicket 0
#endif


@interface KFChatViewController () <KFChatTooViewDelegate,KFChatViewModelDelegate,KFChatVoiceManagerDelegate,KFChatTableViewDelegate,KFChatViewCellDelegate,UIWebViewDelegate>{
    dispatch_once_t scrollBTMOnce;
}

@property (nonatomic, weak) KFChatTableView *tableView;
@property (nonatomic, weak) KFChatToolView *chatToolView;
@property (nonatomic, strong) KFChatViewModel *viewModel;
@property (nonatomic, weak) KFRecordView *recordView;

@property (nullable, nonatomic, weak) KFPhotoGroupView *photoGroupView;

@property (nonnull, nonatomic, strong) KFMessageModel *queueMessageModel;
// 用于拨打电话
@property (nullable, nonatomic, weak) UIWebView *webView;

@end

@implementation KFChatViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    dispatch_once(&scrollBTMOnce , ^{
        if (self.tableView) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
                if (rowCount > 1) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
            });
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    self.viewModel = [[KFChatViewModel alloc]init];
    self.viewModel.delegate = self;
    [KFChatVoiceManager sharedChatVoiceManager].delegate = self;
    
    // 解决speakBtn的UIControlEventTouchDown响应延迟的问题
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.title = KF5Localized(@"kf5_connecting");
    [KFProgressHUD showLoadingTo:self.view title:@""];
    __weak typeof(self)weakSelf = self;
    [self.viewModel configChatWithCompletion:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD hideHUDForView:weakSelf.view];
        });
    }];

    NSMutableArray <KFMessageModel *>*newDatas = [NSMutableArray arrayWithArray:[self.viewModel queryMessageModelsWithLimit:self.limit]];
    if (newDatas.count < self.limit) {
        [self.tableView endRefreshingWithNoMoreData];
    }
    self.tableView.messageModelArray = newDatas;
    [self.tableView reloadData];
} 
#pragma mark 初始化subView
- (void)setupView{
    
    KFChatTableView *tableView = [[KFChatTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - KFChatToolView.defaultHeight) style:UITableViewStylePlain];
    tableView.tableDelegate = self;
    tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 添加输入框视图
    KFChatToolView *chatToolView = [[KFChatToolView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tableView.frame), self.view.frame.size.width, KFChatToolView.defaultHeight)];
    chatToolView.tag = kKF5ChatToolViewTag;
    chatToolView.delegate = self;
    chatToolView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:chatToolView];
    self.chatToolView = chatToolView;
    
    // 录音视图
    KFRecordView *recordView = [[KFRecordView alloc]initWithFrame:CGRectMake(0, 0, 150, 132)];
    recordView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    recordView.center = self.view.center;
    recordView.tag = kKF5RecordViewTag;
    recordView.hidden = YES;
    self.recordView = recordView;
    [self.view addSubview:recordView];
    
    // 用于打电话
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.frame = CGRectZero;
    [self.view addSubview:webView];
    self.webView = webView;
    
    [self addObserver:self forKeyPath:@"chatToolView.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)updateFrame{
    [self.photoGroupView dismissAnimated:NO completion:nil];
    self.chatToolView.kf5_y = self.view.kf5_h - self.chatToolView.kf5_h;
    [self.tableView updateFrame];
    [self.chatToolView updateFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"chatToolView.frame"]) {
        self.tableView.kf5_h = CGRectGetMinY(self.chatToolView.frame);
        [self.tableView scrollViewBottomHasMainQueue:NO];
    }
}

#pragma mark - KFChatViewModelDelegate
#pragma mark 连接服务器失败
- (void)chat:(KFChatViewModel *)chat connectError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = KF5Localized(@"kf5_not_connected");
        [self showMessageWithText:error.domain];
    });
}
#pragma mark 排队中
- (void)chatWithQueueing:(KFChatViewModel *)chat{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = KF5Localized(@"kf5_queue_waiting");
    });
}
#pragma mark 当前没有客服在线
- (void)chatWithNoAgent:(KFChatViewModel *)chat{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = KF5Localized(@"kf5_no_agent_online");
        if (self.isShowAlertWhenNoAgent) {
            __weak typeof(self)weakSelf = self;
            [JKAlert showMessage:KF5Localized(@"kf5_no_agent_online_leaving_message") OKHandler:^(JKAlertItem *item) {
                if (weakSelf.noAgentAlertActionBlock) {
                    weakSelf.noAgentAlertActionBlock();
                }else{
#if KFHasTicket
                    [weakSelf presentViewController:[[UINavigationController alloc] initWithRootViewController:[KFCreateTicketViewController new]] animated:YES completion:nil];
#else
#warning 没有添加KF5SDKUI/Ticket
#endif
                }
            }];
        }
    });
}
- (void)chat:(KFChatViewModel *)chat statusChange:(KFChatStatus)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatToolView.chatToolViewType = status;
    });
}
#pragma mark 排队失败
- (void)chat:(KFChatViewModel *)chat queueError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessageWithText:error.domain];
    });
}
#pragma mark 获取到客服
- (void)chat:(KFChatViewModel *)chat agentChange:(KFAgent *)agent{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.queueMessageModel) {
            [self.tableView.messageModelArray removeObject:self.queueMessageModel];
            [self.tableView reloadData];
            [self.tableView scrollViewBottomHasMainQueue:NO];
        }
        self.title = agent.displayName;
    });
}
#pragma mark 排队变化
- (void)chat:(KFChatViewModel *)chat queueIndexChange:(NSInteger)queueIndex{
    
    if (self.queueMessageModel)
        [self.tableView.messageModelArray removeObject:self.queueMessageModel];
    
    KFMessage *message = [[KFMessage alloc] init];
    message.content = [NSString stringWithFormat:KF5Localized(@"kf5_update_queue_%ld"),queueIndex + 1];
    message.messageType = KFMessageTypeSystem;
    message.created = [NSDate date].timeIntervalSince1970;
    self.queueMessageModel = [[KFMessageModel alloc] initWithMessage:message];
        
    [self.tableView.messageModelArray addObject:self.queueMessageModel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView scrollViewBottomHasMainQueue:NO];
    });
}

#pragma mark 客服发起满意度评价请求
- (void)chatWithAgentRating:(KFChatViewModel *)chat{
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self)weakSelf = self;
        
        JKAlert *alert = [JKAlert alertWithTitle:KF5Localized(@"kf5_reminder") andMessage:KF5Localized(@"kf5_rating_content")];
        [alert addCancleButtonWithTitle:KF5Localized(@"kf5_cancel") handler:nil];
        [alert addCommonButtonWithTitle:KF5Localized(@"kf5_satisfied") handler:^(JKAlertItem *item) {
            [weakSelf sendRating:NO];
        }];
        [alert addCommonButtonWithTitle:KF5Localized(@"kf5_unsatisfied") handler:^(JKAlertItem *item) {
            [weakSelf sendRating:NO];
        }];
        [alert show];
    });
}

#pragma mark 对话被客服关闭
- (void)chatWithEndChat:(KFChatViewModel *)chat{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = KF5Localized(@"kf5_chat_ended");
        [self showMessageWithText:KF5Localized(@"kf5_chat_agent_leave")];
    });
}
#pragma mark 刷新数据
- (void)chat:(KFChatViewModel *)chat addMessageModels:(NSArray <KFMessageModel *>*)messageModels{
    if (messageModels.count == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messageModels.count];
            for (int i = 0; i< messageModels.count; i++) {
                NSInteger row = self.tableView.messageModelArray.count + i;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [indexPaths addObject:indexPath];
            }
            [self.tableView.messageModelArray addObjectsFromArray:messageModels];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        } @catch (NSException *exception) {
        }
    });
    [self.tableView scrollViewBottomWithAfterTime:600];
}
    
#pragma mark - KFChatVoiceManagerDelegate
- (void)chatVoiceManager:(KFChatVoiceManager *)chatManager recordVoice:(NSData *)data error:(NSError *)error{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showTitleToView:self.view title:error.domain hideAfter:0.7f];
        });
    }else{
        [self.viewModel sendMessageWithMessageType:KFMessageTypeVoice data:data];
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
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.barItemTextFont = [UIFont boldSystemFontOfSize:17];
    
    __weak typeof(self)weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0){
            UIImage *newImage = [UIImage imageWithData:UIImageJPEGRepresentation(photos.firstObject, 1)];
            [weakSelf.viewModel sendMessageWithMessageType:KFMessageTypeImage data:newImage];
        }
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
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
        [self.viewModel queueUpWithCompletion:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD hideHUDForView:weakSelf.view];
            });
        }];
    }
}
#pragma mark 开始录音
- (BOOL)chatToolViewStartVoice:(KFChatToolView *)chatToolView{
    [[KFChatVoiceManager sharedChatVoiceManager]startVoiceRecord];
    return YES;
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
    return text.length > 0 ? [self canSendMessage] : YES;
}

#pragma mark - KFChatTableViewDelegate
- (void)tableViewWithRefreshData:(KFChatTableView *)tableView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *newDatas = [self.viewModel queryMessageModelsWithLimit:self.limit];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(800 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (self.tableView.messageModelArray.count > 0 && newDatas.count > 0) {
                [self.tableView.messageModelArray insertObjects:newDatas atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newDatas.count)]];
                    CGFloat offsetOfButtom = self.tableView.contentSize.height-self.tableView.contentOffset.y;
                    [self.tableView reloadData];
                    self.tableView.contentOffset = CGPointMake(0.0f, self.tableView.contentSize.height-offsetOfButtom);
            }
            
            if (newDatas.count < self.limit) {
                [tableView endRefreshingWithNoMoreData];
            }else{
                [tableView endRefreshing];
            }
        });
    });
}
- (CGFloat)tableViewWithOffsetTop:(KFChatTableView *)tableView{
    return self.navigationController.navigationBar.kf5_h + [UIApplication sharedApplication].statusBarFrame.size.height;
}
#pragma mark - KFChatViewCellDelegate
#pragma mark - 失败消息重发
- (void)cell:(KFChatViewCell *)cell reSendMessageWithMessageModel:(KFMessageModel *)model{
    if (self.viewModel.chatStatus != KFChatStatusChatting) return;
    __weak typeof(self)weakSelf = self;
    [JKAlert showMessage:KF5Localized(@"kf5_resend_message") OKHandler:^(JKAlertItem *item) {
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        if (!indexPath || indexPath.row > weakSelf.tableView.messageModelArray.count - 1) return;
        [weakSelf.viewModel resendMessageModel:weakSelf.tableView.messageModelArray[indexPath.row]];
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
    }];
}

- (void)cell:(KFChatViewCell *)cell clickImageWithMessageModel:(KFMessageModel *)model{
    
    [self.view endEditing:YES];
    KFImageMessageCell *imageCell = (KFImageMessageCell *)cell;
    KFPhotoGroupItem *item = [KFPhotoGroupItem new];
    item.thumbView = imageCell.messageImageView;
    item.largeImageURL = model.message.url;
    
    KFPhotoGroupView *v = [[KFPhotoGroupView alloc] initWithGroupItems:@[item]];
    [v presentFromImageView:imageCell.messageImageView toContainer:self.navigationController.view animated:YES completion:nil];
    self.photoGroupView = v;
}
- (void)cell:(KFChatViewCell *)cell clickVoiceWithMessageModel:(KFMessageModel *)model{
    model.isPlaying = YES;
    __weak typeof(self)weakSelf = self;
    [[KFChatVoiceManager sharedChatVoiceManager]playVoiceWithLocalPath:model.message.local_path completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            model.isPlaying = NO;
            if (error) {
                [KFProgressHUD showLoadingTo:weakSelf.view title:KF5Localized(@"kf5_play_error") hideAfter:0.7f];
            }
        });
    }];
}
- (void)cell:(KFChatViewCell *)cell clickLabelWithInfo:(NSDictionary *)info{
    
    KFTextMessageCell *textCell = (KFTextMessageCell *)cell;
    
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
        case kKFLinkTypeURL:{// 聊天和工单都使用
            NSString *formatName = info[KF5LinkTitle];

            if ([formatName isEqualToString:@"[图片]"]) {
                [self.view endEditing:YES];
                KFPhotoGroupItem *item = [KFPhotoGroupItem new];
                item.thumbView = textCell.messageLabel;
                item.largeImageURL = info[KF5LinkKey];
                
                KFPhotoGroupView *v = [[KFPhotoGroupView alloc] initWithGroupItems:@[item]];
                [v presentFromImageView:textCell.messageLabel toContainer:self.navigationController.view animated:YES completion:nil];
                self.photoGroupView = v;
                
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[KF5LinkKey]]];
            }
        }
            break;
        case kKFLinkTypeForum:{
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
        case kKFLinkTypeBracket:
            [self chatToolViewWithTransferAction:self.chatToolView];
            break;
        case kKFLinkTypeLeaveMessage:{
            __weak typeof(self)weakSelf = self;
            [JKAlert showMessage:KF5Localized(@"kf5_cancel_queue_to_feedback") OKHandler:^(JKAlertItem *item) {
                [weakSelf.viewModel cancleWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            weakSelf.title = KF5Localized(@"kf5_cancel_queued");
                            [KFProgressHUD showTitleToView:weakSelf.view title:KF5Localized(@"kf5_cancel_queue_successfully") hideAfter:0.7f];
                        }else{
                            [KFProgressHUD showTitleToView:weakSelf.view title:KF5Localized(@"kf5_cancel_queue_failed") hideAfter:0.7f];
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
            }];
        }
            break;
        default:
            break;
    }
}

- (void)reloadCell:(KFChatViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
        if (indexPath.row == self.tableView.messageModelArray.count - 1) {
            [self.tableView scrollViewBottomWithAfterTime:600];
        }
    }
}

#pragma mark - webView的代理方法,用于拨打电话
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [JKAlert showMessage:KF5Localized(@"kf5_phone_error")];
}
#pragma mark 收到键盘弹出通知后的响应
- (void)keyboardWillShow:(NSNotification *)info {
    //保存info
    NSDictionary *dict = info.userInfo;
    //得到键盘的显示完成后的frame
    CGRect keyboardBounds = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //得到键盘弹出动画的时间
    double duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //坐标系转换
    CGRect keyboardBoundsRect = [self.view convertRect:keyboardBounds toView:nil];
    //得到键盘的高度，即输入框需要移动的距离
    double offsetY = keyboardBoundsRect.size.height;
    
    UIViewAnimationOptions options = [dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    //添加动画
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.chatToolView.kf5_y = self.view.kf5_h - offsetY - self.chatToolView.kf5_h;
    } completion:nil];
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
    //输入框回去的时候就不需要高度了，直接取动画时间和曲线还原回去
    NSDictionary *dict = info.userInfo;
    double duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.chatToolView.kf5_y = self.view.kf5_h - self.chatToolView.kf5_h;
    } completion:nil];
}

#pragma mark - 其他
- (void)showMessageWithText:(NSString *)text alerType:(KF5AlertType)type{
    if (text.length == 0) return;
    KFAlertMessage *alert = [[KFAlertMessage alloc]initWithViewController:self title:text duration:4 showType:type];
    [alert showAlert];
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
- (void)sendRating:(BOOL)rating{
    
    [self.viewModel sendRating:rating completion:^(NSError *error) {
    }];
    KFMessage *message = [[KFMessage alloc] init];
    message.content = KF5Localized(@"kf5_rating_successfully") ;
    message.messageType = KFMessageTypeSystem;
    message.created = [NSDate date].timeIntervalSince1970;
    KFMessageModel *model = [[KFMessageModel alloc] initWithMessage:message];
    [self chat:self.viewModel addMessageModels:@[model]];
}
- (NSInteger)limit{
    if (_limit == 0)_limit = 30;
    return _limit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"chatToolView.frame"];
}

@end
