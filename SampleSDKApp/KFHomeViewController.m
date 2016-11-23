//
//  KFHomeViewController.m
//  KF5SampleApp
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 kf5. All rights reserved.
//

#import "KFHomeViewController.h"
#import "KFPersonTableViewController.h"
#import <KF5SDK/KF5SDK.h>
#import "KFUserManager.h"
#import "KF5SDKTicket.h"

@interface KFHomeViewController ()

@end

@implementation KFHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([KFUserManager shareUserManager].user != nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStyleDone target:self action:@selector(login:)];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"登录" style:UIBarButtonItemStyleDone target:self action:@selector(login:)];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushTicketList) name:@"homePush" object:nil];
    
    NSString *push = [[NSUserDefaults standardUserDefaults]objectForKey:@"push"];
    
    if (push.length > 0) {
        [self pushTicketList];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"push"];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess) name:@"loginSuccess" object:nil];
    
}

- (void)login:(UIBarButtonItem *)item
{
    if ([item.title isEqualToString:@"登录"]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        KFPersonTableViewController *preson = (KFPersonTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"KFPersonTableViewController"];
        [self.navigationController pushViewController:preson animated:YES];
    }else{// 注销方法
        item.title = @"登录";
        // 注销用户
        [KFUserManager deleteUser];
    }
}

#pragma mark - delegate
- (void)loginSuccess
{
    self.navigationItem.rightBarButtonItem.title = @"注销";
}

#pragma mark - push
- (void)pushTicketList
{
    [self.navigationController pushViewController:[[KFTicketListViewController alloc]init] animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
