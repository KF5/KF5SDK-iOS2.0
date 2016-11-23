//
//  KFTicketViewController.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFTicketViewController.h"

#import "KFDetailMessageViewController.h"

#import "TZImagePickerController.h"

#import "UITableView+KFRefresh.h"
#import "KFTicketTableView.h"
#import "KFTicketToolView.h"
#import "KFHelper.h"
#import "KFUserManager.h"
#import  <KF5SDK/KFHttpTool.h>
#import "KFProgressHUD.h"
#import "JKAlert.h"
#import "KFTicketManager.h"

#import "SDImageCache.h"
#import "KFPhotoGroupView.h"
#import "KFContentLabelHelp.h"

@interface KFTicketViewController ()<KFTicketViewCellDelegate,UIWebViewDelegate,KFTicketToolViewDelegate>

@property (nullable, nonatomic, weak) KFTicketTableView *tableView;
@property (nullable, nonatomic, weak) KFTicketToolView *toolView;

@property (nullable, nonatomic, weak) KFPhotoGroupView *photoGroupView;
// 用于拨打电话
@property (nullable, nonatomic, weak) UIWebView *webView;

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
            NSArray *comments = [KFComment commentWithDict:result];
            self.tableView.commentModelArray = [NSMutableArray arrayWithArray:[weakSelf commentModelsWithComments:comments]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD hideHUDForView:weakSelf.view];
                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollViewBottomHasMainQueue:NO];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:error.domain hideAfter:1.f];
            });
        }
    }];
}

- (void)setupView{
    KFTicketTableView *tableView = [[KFTicketTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - KFTicketToolView.defaultHeight) style:UITableViewStylePlain];
    tableView.cellDelegate = self;
    tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 添加输入框视图
    KFTicketToolView *toolView = [[KFTicketToolView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tableView.frame), self.view.frame.size.width, KFTicketToolView.defaultHeight)];
    toolView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
    
    [self addObserver:self forKeyPath:@"toolView.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)updateFrame{
    [self.photoGroupView dismissAnimated:NO completion:nil];
    self.toolView.kf5_y = self.view.kf5_h - self.toolView.kf5_h;
    [self.toolView updateFrame];
    
    for (KFCommentModel *model in self.tableView.commentModelArray) {
        [model updateFrame];
    }
    [self.tableView reloadData];
    [self.tableView scrollViewBottomHasMainQueue:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"toolView.frame"]) {
        self.tableView.kf5_h = CGRectGetMinY(self.toolView.frame);
        [self.tableView scrollViewBottomHasMainQueue:NO];
    }
}
#pragma mark - webView的代理方法,用于拨打电话
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [JKAlert showMessage:KF5Localized(@"kf5_phone_error")];
}
#pragma mark - cellDelegate
- (void)ticketCell:(KFTicketViewCell *)cell clickImageWithIndex:(NSInteger)index{
    [self.view endEditing:YES];
    UIView *fromView = nil;
    NSMutableArray *items = [NSMutableArray new];
    NSArray <KFAttachment *>*pics = cell.commentModel.attachments;
    for (NSUInteger i = 0, max = pics.count; i < max; i++) {
        UIView *imgView = cell.photoImageView.subviews[i];
        KFAttachment *pic = pics[i];
        KFPhotoGroupItem *item = [KFPhotoGroupItem new];
        item.thumbView = imgView;
        item.largeImageURL = pic.url;
        [items addObject:item];
        if (i == index) {
            fromView = imgView;
        }
    }
    KFPhotoGroupView *v = [[KFPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:nil];
    self.photoGroupView = v;
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
            NSString *formatName = info[KF5LinkTitle];
            
            if ([formatName isEqualToString:@"[图片]"]) {
                [self.view endEditing:YES];
                KFPhotoGroupItem *item = [KFPhotoGroupItem new];
                item.largeImageURL = info[KF5LinkKey];
                KFPhotoGroupView *v = [[KFPhotoGroupView alloc] initWithGroupItems:@[item]];
                [v presentFromImageView:cell.commentLabel toContainer:self.navigationController.view animated:YES completion:nil];
                self.photoGroupView = v;

            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[KF5LinkKey]]];
            }
        }
            break;
        default:
            break;
    }

}

#pragma mark - TicketToolViewDelegate
/** 发送消息*/
- (void)toolView:(KFTicketToolView *)toolView senderMessage:(NSString *)message{
    
    NSString *text = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [KFProgressHUD showTitleToView:self.view title:KF5Localized(@"kf5_content_not_null") hideAfter:0.7f];
        return;
    };
    
    if (![KFHelper isNetworkEnable]) {
        [JKAlert showMessage:KF5Localized(@"kf5_no_internet")];
        return ;
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
            [attachments addObject:attachment];
        }
        comment.attachments = attachments;
    }
    [self.tableView.commentModelArray addObjectsFromArray:[self commentModelsWithComments:@[comment]]];
    [self.tableView reloadData];
    [self.tableView scrollViewBottomHasMainQueue:YES];
    
    
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
                    [[SDImageCache sharedImageCache] storeImage:image forKey:url];
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
                    [JKAlert showMessage:error.localizedDescription];
                }
                [weakSelf.tableView reloadData];
            });
        }];
    });
}

/** 添加图片*/
- (void)toolViewAddAttachment:(KFTicketToolView *)toolView{
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:nil];
    imagePickerVc.selectedAssets = [self.toolView.attView.images valueForKeyPath:@"asset"];
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.barItemTextFont = [UIFont boldSystemFontOfSize:17];
    
    __weak typeof(self)weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.toolView.attView.images = [KFAssetImage assetImagesWithImages:photos assets:assets];
        });
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
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
        self.toolView.kf5_y = self.view.kf5_h - offsetY - self.toolView.kf5_h;
    } completion:nil];
    
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
    
    if (self.toolView.type == KFTicketToolTypeAddImage)return;
    
    //输入框回去的时候就不需要高度了，直接取动画时间和曲线还原回去
    NSDictionary *dict = info.userInfo;
    double duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.toolView.kf5_y = self.view.kf5_h - self.toolView.kf5_h;
    } completion:nil];
}

- (void)pushDetailMessageViewController{
    KFDetailMessageViewController *detailMessageController = [[KFDetailMessageViewController alloc]initWithTicket_id:self.ticket_id];
    [self.navigationController pushViewController:detailMessageController animated:YES];
}

/**
 KFComment转KFCommentModel
 */
- (NSArray <KFCommentModel *>*)commentModelsWithComments:(NSArray <KFComment *>*)comments{
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:comments.count];
    for (KFComment *comment in comments) {
        KFCommentModel *model = [[KFCommentModel alloc] initWithComment:comment];
        [modelArray addObject:model];
    }
    return modelArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"toolView.frame"];
}

@end
