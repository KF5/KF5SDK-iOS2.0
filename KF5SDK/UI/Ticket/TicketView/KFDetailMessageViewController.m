//
//  KFDetailMessageViewController.m
//  Pods
//
//  Created by admin on 16/9/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "KFDetailMessageViewController.h"

#import "KFDetailMessageViewCell.h"

#import "KFHelper.h"
#import "KFProgressHUD.h"
#import "KFUserManager.h"

@interface KFDetailMessageViewController ()

@property (nonatomic, strong) NSArray <NSDictionary *>*detailMessages;

@property (nonatomic, assign) NSInteger ticket_id;

@end

@implementation KFDetailMessageViewController

- (instancetype)initWithTicket_id:(NSInteger)ticket_id{
    self = [super init];
    if (self) {
        self.ticket_id = ticket_id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title.length) {
        self.title = KF5Localized(@"kf5_message_detail");
    }
    self.tableView.estimatedRowHeight = 44;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self loadData];
}

- (void)loadData{
    if (![KFHelper isNetworkEnable]) {
        [KFHelper alertWithMessage:KF5Localized(@"kf5_no_internet")]; return;
    }
    
    NSDictionary *param = @{
                            KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
                            KF5TicketId:@(self.ticket_id)
                            };
    [KFProgressHUD showDefaultLoadingTo:self.view];
    __weak typeof(self)weakSelf = self;
    [KFHttpTool getTicketDetailMessageWithParams:param completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                weakSelf.detailMessages = [result kf5_arrayForKeyPath:@"data.ticket_field"];

                [weakSelf.tableView reloadData];
                [KFProgressHUD hideHUDForView:weakSelf.view];
            }else{
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:error.domain hideAfter:0.7f];
            }
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.detailMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"detailMessageCell";
    KFDetailMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[KFDetailMessageViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.ticketFieldDict = self.detailMessages[indexPath.row];
    return cell;
}
@end
