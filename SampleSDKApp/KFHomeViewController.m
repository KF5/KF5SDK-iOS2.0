//
//  KFHomeViewController.m
//  KF5SampleApp
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 kf5. All rights reserved.
//

#import "KFHomeViewController.h"
#import "KFPersonTableViewController.h"
#import "KF5SDK.h"

@interface KFHomeViewController ()

@end

@implementation KFHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([KFUserManager shareUserManager].user != nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"kf5_logout", nil) style:UIBarButtonItemStyleDone target:self action:@selector(login:)];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"kf5_login", nil) style:UIBarButtonItemStyleDone target:self action:@selector(login:)];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushTicketList) name:@"homePush" object:nil];
    
    NSString *push = [[NSUserDefaults standardUserDefaults]objectForKey:@"push"];
    
    if (push.length > 0) {
        [self pushTicketList];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"push"];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess) name:@"loginSuccess" object:nil];
    
}

- (void)login:(UIBarButtonItem *)item{
    if ([item.title isEqualToString:NSLocalizedString(@"kf5_login", nil)]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        KFPersonTableViewController *preson = (KFPersonTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"KFPersonTableViewController"];
        [self.navigationController pushViewController:preson animated:YES];
    }else{// 注销方法
        item.title = NSLocalizedString(@"kf5_login", nil);
        [self deleteUser];
    }
}

#pragma mark - delegate
- (void)loginSuccess{
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"kf5_logout", nil);
}
#pragma mark - 注销用户
- (void)deleteUser{
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"deviceToken"];
    if (deviceToken.length > 0) {
        [[KFUserManager shareUserManager]deleteDeviceToken:deviceToken completion:nil];
    }
    
    [KFUserManager deleteUser];
}

#pragma mark - push
- (void)pushTicketList{
    [self.navigationController pushViewController:[[KFTicketListViewController alloc]init] animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
