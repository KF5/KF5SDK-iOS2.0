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
#import "KFTicketModel.h"
#import "KFTicket.h"
#import "KFTicketManager.h"


@interface KFTicketListViewController ()

/**下一页*/
@property (nonatomic, assign) NSUInteger nextPage;

@property (nullable, nonatomic, strong) NSMutableArray <KFTicketModel *>*ticketModelArray;

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

- (void)updateFrame{
    for (KFTicketModel *model in self.ticketModelArray) {
        [model updateFrame];
    }
    [self.tableView reloadData];
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
            NSMutableArray *ticketArray = [weakSelf ticketModelsWithTickets:[KFTicket ticketsWithDictArray:[result kf5_arrayForKeyPath:@"data.requests"]]];
            
            if (isHeader) {
                weakSelf.ticketModelArray = ticketArray;
            }else{
                [weakSelf.ticketModelArray addObjectsFromArray:ticketArray];
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
    return self.ticketModelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ceilf(self.ticketModelArray[indexPath.row].cellHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"KFTicketListTableViewCellID";
    
    KFTicketListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[KFTicketListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.ticketModel = self.ticketModelArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KFTicketModel *ticketModel = self.ticketModelArray[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 记录最后一次更新的内容
    [KFTicketManager saveTicketNewDateWithTicket:ticketModel.ticket.ticket_id lastComment:ticketModel.ticket.lastComment_id];
    
    [ticketModel updateFrame];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    KFTicketViewController *ticketView = [[KFTicketViewController alloc]initWithTicket_id:ticketModel.ticket.ticket_id isClose:ticketModel.ticket.status == KFTicketStatusClosed];
    [self.navigationController pushViewController:ticketView animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.ticketModelArray && self.ticketModelArray.count == 0){
        return 50;
    }else{
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc]init];
    label.text = KF5Localized(@"kf5_no_feedback");
    label.textColor = KF5Helper.KF5NameColor;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, tableView.frame.size.width, 50);
    
    return label;
}

- (NSMutableArray <KFTicketModel *>*)ticketModelsWithTickets:(NSArray <KFTicket *>*)tickets{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:tickets.count];
    for (KFTicket *ticket in tickets) {
        [array addObject:[[KFTicketModel alloc]initWithTicket:ticket]];
    }
    return array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
