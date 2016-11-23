//
//  KFCategorieListViewController.m
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import "KFCategorieListViewController.h"

#import "KFForumListViewController.h"
#import  <KF5SDK/KFHttpTool.h>
#import "KFHelper.h"
#import "KFUserManager.h"

@interface KFCategorieListViewController ()

@end

@implementation KFCategorieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    if (!self.title.length) self.title = KF5Localized(@"kf5_category_list");
}

- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray<NSDictionary *> *, NSInteger, NSError *))resultBlock{
    NSDictionary *params =
                @{
                  KF5PerPage:@(self.prePage),
                  KF5Page: isHeader?@(1):@(self.nextPage),
                KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@""
                };
    [KFHttpTool getDocCategoriesListWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        resultBlock([result kf5_arrayForKeyPath:@"data.categories"],[result kf5_numberForKeyPath:@"data.next_page"].unsignedIntegerValue,error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        KFDocItem *category = self.docArray[indexPath.row];
        KFForumListViewController *viewController = [[KFForumListViewController alloc]initWithCategory:category];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
