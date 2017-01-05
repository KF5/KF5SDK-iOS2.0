//
//  KFCreateTicketViewController.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFCreateTicketViewController.h"
#import "KFHelper.h"
#import "JKAlert.h"
#import "KFProgressHUD.h"
#import  <KF5SDK/KFHttpTool.h>
#import "KFUserManager.h"
#import  <KF5SDK/KFConfig.h>
#import "KFTicketManager.h"
#import "SDImageCache.h"
#import "TZImagePickerController.h"

@interface KFCreateTicketViewController ()<KFCreateTicketViewDelegate>

@end

@implementation KFCreateTicketViewController

- (void)loadView{
    KFCreateTicketView *createView = [[KFCreateTicketView alloc] initWithFrame:CGRectMake(0, 0, KF5SCREEN_WIDTH, KF5SCREEN_HEIGHT) viewDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeWithNote:)  name:UITextViewTextDidChangeNotification object:createView.textView];
    self.createView = createView;
    self.view = createView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title.length) self.title =  KF5Localized(@"kf5_feedback");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:KF5Localized(@"kf5_submit") style:UIBarButtonItemStyleDone target:self action:@selector(createTicket:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.navigationController.viewControllers.count == 1 && !self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:KF5Localized(@"kf5_cancel") style:UIBarButtonItemStyleDone target:self action:@selector(cancelView)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)updateFrame{
    [self.createView updateFrame];
}

- (void)createTicket:(UIBarButtonItem *)btnItem{
    
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.createView.textView resignFirstResponder];
    
    if (![KFHelper isNetworkEnable]) {
        [JKAlert showMessage:KF5Localized(@"kf5_no_internet")];
        return ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [KFProgressHUD showLoadingTo:self.view title:KF5Localized(@"kf5_submitting")];
    });
    
    dispatch_group_t group = dispatch_group_create();
    
    __block NSArray *imageTokens = nil;
    __block NSError *failure = nil;
    
    __weak typeof(self)weakSelf = self;
    if (self.createView.photoImageView.images.count > 0) {
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.createView.photoImageView.images.count];
        for (KFAssetImage *assetImage in self.createView.photoImageView.images) {
            KFFileModel *model = [[KFFileModel alloc] init];
            model.fileData = UIImageJPEGRepresentation(assetImage.image, 1.0);
            [array addObject:model];
        }
        dispatch_group_enter(group);
        [KFHttpTool uploadWithUserToken:[KFUserManager shareUserManager].user.userToken?:@"" fileModels:array uploadProgress:nil completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            if (!error) {
                imageTokens = [result kf5_arrayForKeyPath:@"data.attachments.token"];
                NSArray *urls = [result kf5_arrayForKeyPath:@"data.attachments.content_url"];
                for (NSInteger i = 0; i < urls.count; i++) {
                    NSString *url = urls[i];
                    if ([url isKindOfClass:[NSString class]]) {
                        [[SDImageCache sharedImageCache] storeImage:weakSelf.createView.photoImageView.images[i].image forKey:url];
                    }
                }
            }else{
                failure = error;
            }
            dispatch_group_leave(group);
        }];
    }
    
   
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (failure) {
            [KFProgressHUD hideHUDForView:weakSelf.view];
            [JKAlert showMessage:KF5Localized(@"kf5_image_upload_error")];
            return;
        }
        
        NSString *title = [NSString stringWithFormat:@"来自%@的工单请求",[KFConfig shareConfig].appName];
        NSString *content = weakSelf.createView.textView.text;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                        @{
                                          KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
                                          KF5Title:title?:@"",
                                          KF5Content:content,
                                          KF5Uploads:imageTokens?:@[]
                                        }];
        if (weakSelf.custom_fields) {
            [params setObject:[KFHelper JSONStringWithObject:weakSelf.custom_fields] forKey:KF5CustomFields];
        }
        
        [KFHttpTool createTicketWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD hideHUDForView:weakSelf.view];
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                if (!error) {
                    [weakSelf cancelView];
                    [KFTicketManager saveTicketNewDateWithTicket:[result kf5_numberForKeyPath:@"data.request.id"].integerValue lastComment:[result kf5_numberForKeyPath:@"data.request.last_comment_id"].integerValue];
                    // 同时工单列表更新
                    [[NSNotificationCenter defaultCenter]postNotificationName:KKF5NoteNeedLoadTicketListData object:nil];
                }else{
                    [JKAlert showMessage:error.localizedDescription];
                }
            });
        }];
    });
}
#pragma mark - KFCreateTicketView代理方法
- (CGFloat)createTicketViewWithOffsetTop:(KFCreateTicketView *)view{
    return self.navigationController.navigationBar.kf5_h + [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (void)createTicketViewWithAddAttachmentAction:(KFCreateTicketView *)view{
    [self.createView.textView resignFirstResponder];
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:nil];
    imagePickerVc.selectedAssets = [self.createView.photoImageView.images valueForKeyPath:@"asset"];
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.barItemTextFont = [UIFont boldSystemFontOfSize:17];
    
    __weak typeof(self)weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.createView.photoImageView.images = [KFAssetImage assetImagesWithImages:photos assets:assets];
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
        CGFloat h = KF5SCREEN_HEIGHT - offsetY;
        self.createView.kf5_h = h;
        [self.createView updateFrame];
    } completion:nil];
    
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
    //输入框回去的时候就不需要高度了，直接取动画时间和曲线还原回去
    NSDictionary *dict = info.userInfo;
    double duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.createView.kf5_h = KF5SCREEN_HEIGHT;
        [self.createView updateFrame];
    } completion:nil];
}


- (void)cancelView{
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 监听textView的内容变化
- (void)textDidChangeWithNote:(NSNotification *)note{
    if ([self.createView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
