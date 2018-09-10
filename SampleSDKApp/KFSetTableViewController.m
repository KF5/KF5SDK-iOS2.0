//
//  ViewController.m
//  SampleSDKApp
//
//  Created by admin on 15/2/2.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "KFSetTableViewController.h"
#import "KFSetTableViewCell.h"
#import "KFPersonTableViewController.h"

#import "KF5SDK.h"

#define KFColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface KFCellData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;

+(instancetype)cellDataWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end

@implementation KFCellData
+ (instancetype)cellDataWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    KFCellData *data = [[KFCellData alloc]init];
    data.title = title;
    data.imageName = imageName;
    return data;
}
@end

@interface KFSetTableViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *cellDataList;

@end

@implementation KFSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.tableView setSeparatorColor:KFColorFromRGB(0xdddddd)];
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 116)];
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topView.backgroundColor = KFColorFromRGB(0xf2f5f9);
    [headerView addSubview:topView];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(64, 41, 200, 19)];
    label1.font = [UIFont systemFontOfSize:14.f];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = NSLocalizedString(@"kf5_welcomeText", nil);
    label1.textColor = KFColorFromRGB(0x3e4245);
    [topView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(64, 60, 250, 19)];
    label2.textColor = KFColorFromRGB(0x45d8d0);
    label2.font = [UIFont systemFontOfSize:11.f];
    label2.text = NSLocalizedString(@"kf5_descriptionText", nil);
    [topView addSubview:label2];
    
    self.cellDataList = @[
                          [KFCellData cellDataWithTitle:NSLocalizedString(@"kf5_helpCenter", nil) imageName:@"icon_document"],
                          [KFCellData cellDataWithTitle:NSLocalizedString(@"kf5_set_feedback", nil) imageName:@"icon_request"],
                          [KFCellData cellDataWithTitle:NSLocalizedString(@"kf5_set_feedback_list", nil) imageName:@"icon_ticketList"],
                          [KFCellData cellDataWithTitle:NSLocalizedString(@"kf5_chating", nil) imageName:@"icon_chat"]
                          ];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  [[UIScreen mainScreen] bounds].size.height > 1136 ? 106 : 72;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    KFSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[KFSetTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    KFCellData *data = self.cellDataList[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:data.imageName];
    cell.textLabel.text = data.title;
    cell.textLabel.font = [UIFont systemFontOfSize:18.f];
    cell.textLabel.textColor = KFColorFromRGB(0x424345);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self checkLogin]) return;
    
    switch (indexPath.row) {
        case 0:
            [self helpCenter];
            break;
        case 1:
            [self request];
            break;
        case 2:
            [self requestList];
            break;
        case 3:
            [self chat];
            break;
        default:
            break;
    }
}

- (BOOL)checkLogin
{
    BOOL isLogin = [KFUserManager shareUserManager].user != nil;
    if (!isLogin) {
        [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"kf5_reminder", nil) message:NSLocalizedString(@"kf5_notLogin", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"kf5_cancel", nil) otherButtonTitles:NSLocalizedString(@"kf5_confirm", nil), nil]show];
    }
    return isLogin;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        KFPersonTableViewController *preson = (KFPersonTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"KFPersonTableViewController"];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:preson animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}

// 帮助中心
- (void)helpCenter {
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:[[KFCategorieListViewController alloc] init] animated:YES];
    
    self.hidesBottomBarWhenPushed = NO;
}
// 反馈问题
- (void)request {
    
    self.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[KFCreateTicketViewController alloc] init]];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    self.hidesBottomBarWhenPushed = NO;

}

// 反馈列表
- (void)requestList {
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:[[KFTicketListViewController alloc] init] animated:YES];
    
    self.hidesBottomBarWhenPushed = NO;

}
// 聊天
- (void)chat{
    self.hidesBottomBarWhenPushed = YES;
    
    KFChatViewController *chat = [[KFChatViewController alloc]initWithMetadata:@[@{@"name":@"系统",@"value":@"iOS"},@{@"name":@"SDK版本",@"value":[KFUserManager version]}]];
//    [chat setCardDict:@{@"img_url":@"https://www.kf5.com/image.png", @"title":@"标题",@"price":@"¥200",@"link_title":@"发送链接",@"link_url":@"https://www.kf5.com"}];
    [self.navigationController pushViewController:chat animated:YES];
    
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark 用于将cell分割线补全
-(void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 88, 0, 30)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 54, 0, 30)];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 88, 0, 30)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 54, 0, 30)];
    }
}

@end
