//
//  KFTicketListViewController.m
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import "KFTicketListViewController.h"

#import "KFTicketViewController.h"
#import "KFCreateTicketViewController.h"
#import "KFTicketListViewCell.h"

#import "UITableView+KFRefresh.h"
#import "KFProgressHUD.h"
#import "KFHelper.h"

#import "KFUserManager.h"
#import "KFTicket.h"
#import "KFTicketManager.h"

@interface KFTicketListViewController ()

/**下一页*/
@property (nonatomic, assign) NSUInteger nextPage;

@property (nullable, nonatomic, strong) NSMutableArray <KFTicket *>*ticketList;

@end

@implementation KFTicketListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title.length) self.title = KF5Localized(@"kf5_feedback_list");
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    __weak typeof(self)weakSelf = self;
    [self.tableView kf5_headerWithRefreshingBlock:^{
        [weakSelf refreshWithisHeader:YES];
    }];
    [self.tableView kf5_footerWithRefreshingBlock:^{
        [weakSelf refreshWithisHeader:NO];
    }];
    self.tableView.estimatedRowHeight = 64;
    
    [KFProgressHUD showDefaultLoadingTo:self.view];
    [self refreshWithisHeader:YES];

    if (!self.isHideRightButton && !self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:KF5Localized(@"kf5_contact_us") style:UIBarButtonItemStyleDone target:self action:@selector(pushCreateTicket)];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:KKF5NoteNeedLoadTicketListData object:nil];
}

- (void)pushCreateTicket{
    KFCreateTicketViewController *createTicketView = [[KFCreateTicketViewController alloc] init];
    [self.navigationController pushViewController:createTicketView animated:YES];
}

- (void)setNextPage:(NSUInteger)nextPage{
    _nextPage = nextPage;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(nextPage == 0)[self.tableView kf5_endRefreshingWithNoMoreData];
    });
}

- (void)refreshData{
    [self.tableView kf5_beginHeaderRefreshing];
}

- (void)refreshWithisHeader:(BOOL)isHeader{
    if (![KFHelper isNetworkEnable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showErrorTitleToView:self.view title:KF5Localized(@"kf5_no_internet") hideAfter:3];
            if (isHeader) {
                [self.tableView kf5_endHeaderRefreshing];
            }else{
                [self.tableView kf5_endFooterRefreshing];
            }
        });
        return ;
    }
    NSDictionary *params =@{
                            KF5PerPage:@(self.prePage?:30),
                            KF5Page: isHeader?@(1):@(self.nextPage),
                            KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@""
                            };
    __weak typeof(self)weakSelf = self;
    [KFHttpTool getTicketListWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isHeader) {
                [weakSelf.tableView kf5_endHeaderRefreshing];
            }else{
                [weakSelf.tableView kf5_endFooterRefreshing];
            }
        });
        if (!error) {
            weakSelf.nextPage = [result kf5_numberForKeyPath:@"data.next_page"].unsignedIntegerValue;
            NSArray *ticketList = [KFTicket ticketsWithDictArray:[result kf5_arrayForKeyPath:@"data.requests"]];
            
            if (isHeader) {
                weakSelf.ticketList = [NSMutableArray arrayWithArray:ticketList];
            }else{
                [weakSelf.ticketList addObjectsFromArray:ticketList];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [KFProgressHUD hideHUDForView:weakSelf.view];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:error.domain hideAfter:1.f];
            });
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ticketList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"KFTicketListTableViewCellID";
    
    KFTicketListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[KFTicketListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.ticket = self.ticketList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KFTicket *ticket = self.ticketList[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 记录最后一次更新的内容
    [KFTicketManager saveTicketNewDateWithTicket:ticket.ticket_id lastComment:ticket.lastComment_id];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    KFTicketViewController *ticketView = [[KFTicketViewController alloc]initWithTicket_id:ticket.ticket_id isClose:ticket.status == KFTicketStatusClosed];
    [self.navigationController pushViewController:ticketView animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.ticketList && self.ticketList.count == 0){
        return 50;
    }else{
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [KFHelper labelWithFont:[UIFont boldSystemFontOfSize:16] textColor:KF5Helper.KF5NameColor];
    label.text = KF5Localized(@"kf5_no_feedback");
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, tableView.frame.size.width, 50);
    
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
