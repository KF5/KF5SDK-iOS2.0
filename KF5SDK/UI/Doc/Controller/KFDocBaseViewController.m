//
//  KFDocBaseViewController.m
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import "KFDocBaseViewController.h"
#import "KFDocumentViewController.h"
#import "KFCategory.h"
#import "KFUserManager.h"

#if __has_include("KF5SDKTicket.h")
#import "KF5SDKTicket.h"
#define KFHasTicket 1
#else
#define KFHasTicket 0
#endif

static BOOL isHeaderRefresh = YES;

@interface KFDocBaseViewController ()<UISearchBarDelegate,UISearchControllerDelegate>

@property (nonatomic, strong) NSArray <KFDocItem *>*searchArray;

@property (nonatomic, strong) UISearchController *searchController;

@end

static BOOL HideRightButton = NO;

@implementation KFDocBaseViewController

+ (void)setIsHideRightButton:(BOOL)isHideRightButton {
    HideRightButton = isHideRightButton;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    __weak typeof(self)weakSelf = self;
    if (isHeaderRefresh) {
        [self.tableView kf5_headerWithRefreshingBlock:^{
            [weakSelf refreshWithisHeader:YES];
        }];
    }
    [self.tableView kf5_footerWithRefreshingBlock:^{
        [weakSelf refreshWithisHeader:NO];
    }];

    self.definesPresentationContext = YES;
    KFBaseTableViewController *searchTV = [[KFBaseTableViewController alloc] init];
    searchTV.tableView.delegate = self;
    searchTV.tableView.dataSource = self;
    searchTV.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchTableView = searchTV.tableView;
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:searchTV];
    self.searchController = searchController;
    searchController.searchBar.delegate = self;
    searchController.delegate = self;
    [searchController.searchBar sizeToFit];
    searchController.searchBar.placeholder = KF5Localized(@"kf5_search");
    self.tableView.tableHeaderView = searchController.searchBar;

#if KFHasTicket
    if (!HideRightButton && !self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:KF5Localized(@"kf5_contact_us") style:UIBarButtonItemStyleDone target:self action:@selector(pushTicket)];
    }
#endif
    
    [KFProgressHUD showDefaultLoadingTo:self.view];
    [self refreshWithisHeader:YES];
}

#if KFHasTicket
- (void)pushTicket{
    [self.navigationController pushViewController:[[KFTicketListViewController alloc] init] animated:YES];
}
#endif

- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray<NSDictionary *> *, NSInteger, NSError *))resultBlock{
    NSAssert(NO, @"子类必须覆盖此方法");
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
    __weak typeof(self)weakSelf = self;
    [self refreshData:isHeader resultBlock:^(NSArray<NSDictionary *> *dictArray, NSInteger nextPage, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isHeader) {
                [self.tableView kf5_endHeaderRefreshing];
            }else{
                [self.tableView kf5_endFooterRefreshing];
            }
        });
        
        if (!error) {
            weakSelf.nextPage = nextPage;
            NSArray *docArray = [KFDocItem docItemsWithDictArray:dictArray];
            if (isHeader) {
                weakSelf.docArray = [NSMutableArray arrayWithArray:docArray];
            }else{
                [weakSelf.docArray addObjectsFromArray:docArray];
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

- (void)setNextPage:(NSUInteger)nextPage{
    _nextPage = nextPage;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(nextPage == 0){
            [self.tableView kf5_endRefreshingWithNoMoreData];
        }else {
            [self.tableView kf5_resetNoMoreData];
        }
    });
}

- (NSUInteger)prePage{
    return _prePage == 0 ? 30 : _prePage;
}

#pragma mark - tableView DataSource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return tableView == self.searchTableView ? self.searchArray.count : self.docArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat  height =  KF5Helper.KF5VerticalSpacing * 2 + ceilf(KF5Helper.KF5TitleFont.lineHeight);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"KFDocTableViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = KF5Helper.KF5TitleFont;
        cell.textLabel.textColor = KF5Helper.KF5TitleColor;
    }
    cell.textLabel.text = tableView == self.searchTableView ? self.searchArray[indexPath.row].title : self.docArray[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.searchTableView) {
        KFDocItem *post = self.searchArray[indexPath.row];
        KFDocumentViewController *viewController = [[KFDocumentViewController alloc]initWithPost:post];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [KFProgressHUD showDefaultLoadingTo:self.searchTableView];
    __weak typeof(self)weakSelf = self;
    NSDictionary *params =@{
                            KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
                            KF5Query:searchBar.text?:@""
                          };
    [KFHttpTool searchDocumentWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        weakSelf.searchArray = [KFDocItem docItemsWithDictArray:[result kf5_arrayForKeyPath:@"data.posts"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSearchResult:YES];
            [weakSelf.searchTableView reloadData];
            [KFProgressHUD hideHUDForView:weakSelf.searchTableView];
        });
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        self.searchArray = nil;
        [self reloadSearchResult:NO];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController{
    self.searchArray = nil;
    [self reloadSearchResult:NO];
}

- (void)reloadSearchResult:(BOOL)showNoResult{
    if (self.searchArray.count == 0 && showNoResult) {
        UILabel *noResultLabel = [KFHelper labelWithFont:[UIFont boldSystemFontOfSize:15] textColor:KF5Helper.KF5NameColor];
        noResultLabel.frame = CGRectMake(0, 0, 100, 60);
        noResultLabel.text = KF5Localized(@"kf5_search_noResult");
        noResultLabel.textAlignment = NSTextAlignmentCenter;
        self.searchTableView.tableHeaderView = noResultLabel;
    }else{
        self.searchTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    [self.searchTableView reloadData];
}



@end
