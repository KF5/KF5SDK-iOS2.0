//
//  KFDocBaseViewController.m
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import "KFDocBaseViewController.h"

#import "KFDocumentViewController.h"

#import "JKAlert.h"
#import "UITableView+KFRefresh.h"
#import "KFHelper.h"
#import "KFProgressHUD.h"
#import "KFUserManager.h"

static BOOL isHeaderRefresh = YES;

@interface KFDocBaseViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *searchArray;

@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@end

@implementation KFDocBaseViewController

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
    
    // 搜索框
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = KF5Localized(@"kf5_search");
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    // SearchDisplayController
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController = searchDisplayController;
    
    [KFProgressHUD showDefaultLoadingTo:self.view];
    [self refreshWithisHeader:YES];
}


- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray<NSDictionary *> *, NSInteger, NSError *))resultBlock{
    NSAssert(NO, @"子类必须覆盖此方法");
}

- (void)refreshWithisHeader:(BOOL)isHeader{
    if (![KFHelper isNetworkEnable]) {
        [JKAlert showMessage:KF5Localized(@"kf5_no_internet")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD hideHUDForView:self.view];
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
        if(nextPage == 0)[self.tableView kf5_endRefreshingWithNoMoreData];
    });
}

- (NSUInteger)prePage{
    return _prePage == 0 ? 30 : _prePage;
}

#pragma mark - tableView DataSource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchArray.count;
    }else{
        return self.docArray.count;
    }
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        KFDocItem *post = self.searchArray[indexPath.row];
        cell.textLabel.text = post.title;
    }else{
        KFDocItem *docList = self.docArray[indexPath.row];
        cell.textLabel.text = docList.title;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat  height =  KF5Helper.KF5VerticalSpacing * 2 + ceilf(KF5Helper.KF5TitleFont.lineHeight);
    return height;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [KFProgressHUD showDefaultLoadingTo:self.view];
    __weak typeof(self)weakSelf = self;
    NSDictionary *params =
    @{
      KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
      KF5Query:searchBar.text?:@""
      };
    [KFHttpTool searchDocumentWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        weakSelf.searchArray = [KFDocItem docItemsWithDictArray:[result kf5_arrayForKeyPath:@"data.posts"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showSearchNoResult:YES];
            [weakSelf.searchDisplayController.searchResultsTableView reloadData];
            [KFProgressHUD hideHUDForView:weakSelf.view];
        });
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        self.searchArray = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    [self showSearchNoResult:NO];
    return YES;
}

- (void)showSearchNoResult:(BOOL)isShow{
    self.searchDisplayController.searchResultsTableView.backgroundColor = isShow ? [UIColor whiteColor] : [UIColor colorWithWhite:0 alpha:0.4];
    for( UIView *subview in self.searchDisplayController.searchResultsTableView.subviews ) {
        if( [subview class] == [UILabel class] ) {
            UILabel *lbl = (UILabel*)subview;
            lbl.text = isShow ? KF5Localized(@"kf5_search_noResult") : @"";
        }
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    self.searchArray = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        KFDocItem *post = self.searchArray[indexPath.row];
        KFDocumentViewController *viewController = [[KFDocumentViewController alloc]initWithPost:post];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
