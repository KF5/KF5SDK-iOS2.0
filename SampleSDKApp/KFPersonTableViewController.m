//
//  KFPersonTableViewController.m
//  KF5SampleApp
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 kf5. All rights reserved.
//

#import "KFPersonTableViewController.h"
#import "KFUserManager.h"
#import "KFProgressHUD.h"
#import "KFUserManager.h"

@interface KFPersonTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation KFPersonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    KFUser *user = [KFUserManager shareUserManager].user;
    if (user != nil) {
        self.nameTextField.text = user.userName;
        self.emailTextField.text = user.email;
        self.phoneTextField.text = user.phone;
    }else{
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.emailTextField.text = [NSString stringWithFormat:@"%@@qq.com",[idfv substringToIndex:8]];
        self.nameTextField.text = @"IOS用户";
    }
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

- (IBAction)login:(UIBarButtonItem *)sender {
    if (self.emailTextField.text.length == 0 && self.phoneTextField.text.length == 0) {
        [self showAlertWithTitle:NSLocalizedString(@"kf5_notAccount", nil)];
        return;
    }
    if (self.emailTextField.text.length > 0 && ![self validateEmail:self.emailTextField.text]) {
        [self showAlertWithTitle:NSLocalizedString(@"kf5_incorrectEmail", nil)];
        return;
    }
    if (self.phoneTextField.text.length > 0 && ![self validatePhone:self.phoneTextField.text]) {
        [self showAlertWithTitle:NSLocalizedString(@"kf5_incorrectPhone", nil)];
        return;
    }

    
    [KFProgressHUD showDefaultLoadingTo:self.view];
    // 初始化配置信息
    __weak typeof(self)weakSelf = self;
    [[KFUserManager shareUserManager]initializeWithEmail:self.emailTextField.text completion:^(KFUser * _Nullable user, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD hideHUDForView:weakSelf.view];
            if (error) {
                [weakSelf showAlertWithTitle:error.domain];
            }else{
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"loginSuccess" object:nil];
                [weakSelf updateMessage];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}
- (void)updateMessage{
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    if (deviceToken.length > 0) {
        [[KFUserManager shareUserManager]saveDeviceToken:deviceToken completion:nil];
    }
    // 使用邮箱为主的登录方式,可以更新用户的昵称和手机号
    __weak typeof(self)weakSelf = self;
    [[KFUserManager shareUserManager]updateUserWithEmail:nil phone:self.phoneTextField.text name:self.nameTextField.text completion:^(KFUser * _Nullable user, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:error.domain hideAfter:0.7];
            }
        });
    }];
}

- (void)showAlertWithTitle:(NSString *)title{
        [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"kf5_reminder", nil) message:title delegate:nil cancelButtonTitle:NSLocalizedString(@"kf5_confirm", nil) otherButtonTitles:nil, nil]show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = cell.contentView.subviews[0];
    if ([textField isKindOfClass:[UITextField class]])
        [textField becomeFirstResponder];
}

- (BOOL)validateEmail:(NSString *)email{
    if (![email isKindOfClass:[NSString class]]) return NO;
    if (email.length ==0) return NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL b = [emailTest evaluateWithObject:email];
    return b;
}

- (BOOL)validatePhone:(NSString *)phone{
    if (![phone isKindOfClass:[NSString class]]) return NO;
    if (phone.length ==0) return NO;
    NSString *emailRegex = @"^1\\d{10}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL b = [emailTest evaluateWithObject:phone];
    return b;
}

@end
