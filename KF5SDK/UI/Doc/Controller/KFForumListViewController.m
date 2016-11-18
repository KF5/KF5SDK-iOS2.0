//
//  KFForumListViewController.m
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFForumListViewController.h"

#import "KFPostListViewController.h"
#import  <KF5SDK/KFHttpTool.h>
#import "KFHelper.h"
#import "KFUserManager.h"

@interface KFForumListViewController ()

@end

@implementation KFForumListViewController

- (instancetype)initWithCategory:(KFDocItem *)category{
    self = [super init];
    if (self) {
        _category = category;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.title.length == 0) {
        if (self.category.title.length == 0)
            self.title = KF5Localized(@"kf5_section_list");
        else
            self.title = self.category.title;
    }
}

- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray<NSDictionary *> *, NSInteger, NSError *))resultBlock{
    NSDictionary *params =
    @{
      @"per_page":@(self.prePage),
      @"page": isHeader?@(1):@(self.nextPage),
      @"userToken":[KFUserManager shareUserManager].user.userToken?:@"",
      @"category_id":@(self.category.Id)
      };
    [KFHttpTool getDocForumListWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        resultBlock([result kf5_arrayForKeyPath:@"data.forums"],[result kf5_numberForKeyPath:@"data.next_page"].unsignedIntegerValue,error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        KFDocItem *forum = self.docArray[indexPath.row];

        KFPostListViewController *viewController = [[KFPostListViewController alloc]initWithForum:forum];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
