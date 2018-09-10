//
//  KFTicketViewController.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFTicketViewController.h"
#import "KFDetailMessageViewController.h"
#import "KFTicketTableView.h"
#import "KFTicketToolView.h"
#import "KFCategory.h"
#import "KFUserManager.h"
#import "KFTicketManager.h"
#import "SDImageCache.h"
#import "KFPreviewController.h"
#import "KFContentLabelHelp.h"
#import "KFRatingViewController.h"

@interface KFTicketViewController ()<KFTicketViewCellDelegate,UIWebViewDelegate,KFTicketToolViewDelegate,KFTicketTableViewDelegate>

@property (nullable, nonatomic, weak) KFTicketTableView *tableView;
@property (nullable, nonatomic, weak) KFTicketToolView *toolView;
// 用于拨打电话
@property (nullable, nonatomic, weak) UIWebView *webView;

@property (nonatomic,strong) NSLayoutConstraint *toolBottomLayout;

@end

@implementation KFTicketViewController

- (instancetype)initWithTicket_id:(NSInteger)ticket_id isClose:(BOOL)isClose{
    self = [super init];
    if (self) {
        self.ticket_id = ticket_id;
        self.isClose = isClose;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:KF5Localized(@"kf5_message_detail") style:UIBarButtonItemStyleDone target:self action:@selector(pushDetailMessageViewController)];
    
    [self setupView];
    [self layoutView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    __weak typeof(self)weakSelf = self;
    [self.tableView kf5_headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    [KFProgressHUD showDefaultLoadingTo:self.view];
    [self refreshData];
}

- (void)refreshData{
    if (![KFHelper isNetworkEnable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showErrorTitleToView:self.view title:KF5Localized(@"kf5_no_internet") hideAfter:3];
            [self.tableView kf5_endHeaderRefreshing];
        });
        return ;
    }
    NSDictionary *params = @{
                             KF5UserToken:[KFUserManager shareUserManager].user.userToken,
                             KF5TicketId:@(self.ticket_id),
                             KF5PerPage:@"200"
                             };
    __weak typeof(self)weakSelf = self;
    [KFHttpTool getTicketWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView kf5_endHeaderRefreshing];
        });
        if (!error) {
            weakSelf.tableView.commentList = [NSMutableArray arrayWithArray:[KFComment commentWithDict:result]];
            
            KFRatingModel *ratingModel = nil;
            if ([result kf5_numberForKeyPath:@"data.request.rating_flag"].boolValue) {
                ratingModel = [[KFRatingModel alloc] init];
                ratingModel.ratingScore = [result kf5_numberForKeyPath:@"data.request.rating"].integerValue;
                ratingModel.rateLevelCount = [result kf5_numberForKeyPath:@"data.request.rate_level_count"].integerValue;
                ratingModel.ratingContent = [result kf5_stringForKeyPath:@"data.request.rating_content"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD hideHUDForView:weakSelf.view];
                weakSelf.tableView.ratingModel = ratingModel;
                [weakSelf.tableView reloadData];
                if (weakSelf.view.tag == 0) {
                    [weakSelf.tableView scrollViewBottomWithAnimated:YES];
                    weakSelf.view.tag = 1;
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:error.domain hideAfter:1.f];
            });
        }
    }];
}

- (void)setupView{
    KFTicketTableView *tableView = [[KFTicketTableView alloc]init];
    tableView.cellDelegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 添加输入框视图
    KFTicketToolView *toolView = [[KFTicketToolView alloc]init];
    toolView.tag = kKF5TicketToolViewTag;
    toolView.delegate = self;
    toolView.type = _isClose?KFTicketToolTypeClose:KFTicketToolTypeInputText;
    [self.view addSubview:toolView];
    self.toolView = toolView;
    
    // 用于打电话
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.frame = CGRectZero;
    [self.view addSubview:webView];
    self.webView = webView;
}

- (void)layoutView{
    [self.tableView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self.view.kf5_safeAreaLayoutGuideTop);
        make.left.kf_equalTo(self.view);
        make.right.kf_equalTo(self.view);
        make.bottom.kf_equalTo(self.toolView.kf5_top);
    }];
    
    [self.toolView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self.view.kf5_safeAreaLayoutGuideLeft);
        make.right.kf_equalTo(self.view.kf5_safeAreaLayoutGuideRight);
        self.toolBottomLayout = make.bottom.kf_equalTo(self.view.kf5_safeAreaLayoutGuideBottom).active;
    }];
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = self.toolView.backgroundColor;
    [self.view insertSubview:bottomView belowSubview:self.toolView];
    [bottomView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self.toolView);
        make.left.kf_equalTo(self.view);
        make.right.kf_equalTo(self.view);
        make.bottom.kf_equalTo(self.view);
    }];
}

#pragma mark - webView的代理方法,用于拨打电话
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [[KFHelper alertWithMessage:KF5Localized(@"kf5_phone_error")] showToVC:self];
}
#pragma mark - TicketTableViewDelegate
- (void)ticketTableView:(KFTicketTableView *)tableView clickHeaderViewWithRatingModel:(KFRatingModel *)ratingModel{
    KFRatingViewController *ratingVC = [[KFRatingViewController alloc] initWithTicket_id:self.ticket_id ratingModel:ratingModel];
    __weak typeof(self)weakSelf = self;
    [ratingVC setCompletionBlock:^(KFRatingModel *ratingModel) {
        weakSelf.tableView.ratingModel = ratingModel;
    }];
    [self.navigationController pushViewController:ratingVC animated:YES];
}

#pragma mark - cellDelegate
- (void)ticketCell:(KFTicketViewCell *)cell clickImageWithIndex:(NSInteger)index{
    [self.view endEditing:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath || self.tableView.commentList.count <= indexPath.row) return;
    KFComment *comment = self.tableView.commentList[indexPath.row];
    if (index >= comment.attachments.count) return;

    KFAttachment *selectAttachment = comment.attachments[index];
    
    if (selectAttachment.isImage) {
        NSInteger selectIndex = 0;
        NSMutableArray *models = [NSMutableArray new];
        for (NSUInteger i = 0; i < comment.attachments.count; i++) {
            KFAttachment *attachment = comment.attachments[i];
            if (!attachment.isImage)continue;
            KFSudokuViewCell *imgView = cell.photoImageView.subviews[i];
            if ([attachment.url isKindOfClass:[UIImage class]]) {
                [models addObject:[[KFPreviewModel alloc] initWithValue:attachment.url placeholder:imgView.imageView.image]];
            }else if ([attachment.url isKindOfClass:[NSString class]]){
                [models addObject:[[KFPreviewModel alloc] initWithValue:[NSURL URLWithString:attachment.url] placeholder:imgView.imageView.image]];
            }
            if (i == index)selectIndex = models.count-1;
        }
        if (models.count == 0) return;
        [KFPreviewController setPlaceholderErrorImage:KF5Helper.placeholderImageFailed];
        [KFPreviewController presentForViewController:self models:models selectIndex:selectIndex];
    }else{
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:selectAttachment.url]];
    }
    
}

- (void)ticketCell:(KFTicketViewCell *)cell clickLabelWithInfo:(NSDictionary *)info{
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[KF5LinkKey]]];
        }
            break;
        case kKFLinkTypeImg:{
            [self.view endEditing:YES];
            [KFPreviewController setPlaceholderErrorImage:KF5Helper.placeholderImageFailed];
            [KFPreviewController presentForViewController:self models:@[[[KFPreviewModel alloc] initWithValue:[NSURL URLWithString:info[KF5LinkKey]] placeholder:KF5Helper.placeholderImage]] selectIndex:0];
        }
            break;
        default:
            break;
    }
}

#pragma mark - TicketToolViewDelegate
- (void)toolViewWithTextDidChange:(KFTicketToolView *)toolView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.contentOffset.y + self.tableView.frame.size.height != self.tableView.contentSize.height) {
            [self.tableView scrollViewBottomWithAnimated:NO];
        }
    });
}
/** 发送消息*/
- (void)toolView:(KFTicketToolView *)toolView senderMessage:(NSString *)message{
    
    NSString *text = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [KFProgressHUD showTitleToView:self.view title:KF5Localized(@"kf5_content_not_null") hideAfter:0.7f];
        return;
    };
    
    if (![KFHelper isNetworkEnable]) {
        [KFHelper alertWithMessage:KF5Localized(@"kf5_no_internet")]; return;
    }

    __block KFComment *comment = [[KFComment alloc]init];
    comment.created = [NSDate date].timeIntervalSince1970;
    comment.messageFrom = KFMessageFromMe;
    comment.author_id = [KFUserManager shareUserManager].user.user_id;
    comment.author_name = [KFUserManager shareUserManager].user.userName;
    comment.content = text;
    comment.messageStatus = KFMessageStatusSending;
    if (self.toolView.attView.images > 0) {
        NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:self.toolView.attView.images.count];
        for (KFAssetImage *assetImage in self.toolView.attView.images) {
            KFAttachment *attachment = [[KFAttachment alloc] init];
            attachment.url = (NSString *)assetImage.image;
            attachment.isImage = YES;
            [attachments addObject:attachment];
        }
        comment.attachments = attachments;
    }
    [self.tableView.commentList addObject:comment];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.tableView.commentList indexOfObject:comment] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollViewBottomWithAfterTime:600];
    
    
    dispatch_group_t group = dispatch_group_create();
    
    __block NSError *failure = nil;
    
    if (comment.attachments.count > 0) {
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:comment.attachments.count];
        for (KFAttachment *attachment in comment.attachments) {
            KFFileModel *fileModel = [[KFFileModel alloc] init];
            fileModel.fileData = UIImageJPEGRepresentation((UIImage *)attachment.url, 1.0);
            [array addObject:fileModel];
        }
         dispatch_group_enter(group);
        [KFHttpTool uploadWithUserToken:[KFUserManager shareUserManager].user.userToken?:@"" fileModels:array uploadProgress:nil completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            if (!error) {
                
                NSArray *urls = [result kf5_arrayForKeyPath:@"data.attachments.content_url"];
                for (NSInteger i = 0; i < urls.count; i++) {
                    NSString *url = urls[i];
                    UIImage *image = (UIImage *)comment.attachments[i].url;
                    [[SDImageCache sharedImageCache] storeImage:image forKey:url completion:nil];
                }
                
                comment.attachments = [KFAttachment attachmentsWithDict:[result kf5_arrayForKeyPath:@"data.attachments"]];
                
            }else{
                failure = error;
            }
            dispatch_group_leave(group);
        }];
    }
    
    
    __weak typeof(self)weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (failure) {
            [KFProgressHUD showErrorTitleToView:weakSelf.view title:KF5Localized(@"kf5_image_upload_error") hideAfter:0.7];
            comment.messageStatus = KFMessageStatusFailure;
            [weakSelf.tableView reloadData];
            return;
        }
        
        NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:comment.attachments.count];
        for (KFAttachment *attachment in comment.attachments) {
            if (attachment.token.length > 0)
                [tokens addObject:attachment.token];
        }
        
        NSDictionary *params = @{
                                 KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
                                 KF5TicketId:@(weakSelf.ticket_id),
                                 KF5Content:text,
                                 KF5Uploads:tokens
                                 };
        [KFHttpTool updateTicketWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD hideHUDForView:weakSelf.view];
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                if (!error) {
                    comment.messageStatus = KFMessageStatusSuccess;
                    [KFTicketManager saveTicketNewDateWithTicket:[result kf5_numberForKeyPath:@"data.request.id"].integerValue lastComment:[result kf5_numberForKeyPath:@"data.request.last_comment_id"].integerValue];
                }else{
                    comment.messageStatus = KFMessageStatusFailure;
                    [[KFHelper alertWithMessage:error.localizedDescription]showToVC:weakSelf];
                }
                NSInteger row = [weakSelf.tableView.commentList indexOfObject:comment];
                if (row != NSNotFound) {
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                 }else{
                     [weakSelf.tableView reloadData];
                 }
            });
        }];
    });
}

/** 添加图片*/
- (void)toolViewAddAttachment:(KFTicketToolView *)toolView{
    __weak typeof(self)weakSelf = self;
    UIViewController *imagePickerVC = [KFHelper imagePickerControllerWithMaxCount:6 selectedAssets:[self.toolView.attView.images valueForKeyPath:@"asset"] didFinishedHandle:^(NSArray<UIImage *> *photos, NSArray *assets) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.toolView.attView.images = [KFAssetImage assetImagesWithImages:photos assets:assets];
        });
    }];
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

#pragma mark 收到键盘弹出通知后的响应
- (void)keyboardWillShow:(NSNotification *)info {

    NSDictionary *dict = info.userInfo;
    //得到键盘的高度，即输入框需要移动的距离
    self.toolBottomLayout.constant = -([dict[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height  - self.view.kf5_safeAreaInsets.bottom);
    
    [UIView animateWithDuration:[dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 animations:^{
        [self.view layoutIfNeeded];
        [self.tableView scrollViewBottomWithAnimated:YES];
    } completion:nil];
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
        
    NSDictionary *dict = info.userInfo;
    self.toolBottomLayout.constant = 0;
    [UIView animateWithDuration:[dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)pushDetailMessageViewController{
    KFDetailMessageViewController *detailMessageController = [[KFDetailMessageViewController alloc]initWithTicket_id:self.ticket_id];
    [self.navigationController pushViewController:detailMessageController animated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
