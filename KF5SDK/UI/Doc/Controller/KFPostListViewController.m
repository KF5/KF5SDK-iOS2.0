//
//  KFPostListViewController.m
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFPostListViewController.h"

#import "KFDocumentViewController.h"

#import  <KF5SDK/KFHttpTool.h>
#import "KFHelper.h"
#import "KFUserManager.h"

@interface KFPostListViewController ()

@end

@implementation KFPostListViewController

- (instancetype)initWithForum:(KFDocItem *)forum{
    self = [super init];
    if (self) {
        _forum = forum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.title.length == 0) {
        if (self.forum.title.length == 0)
            self.title = KF5Localized(@"kf5_article_list");
        else
            self.title = self.forum.title;
    }
}

- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray<NSDictionary *> *, NSInteger, NSError *))resultBlock{
    NSDictionary *params =
    @{
      @"per_page":@(self.prePage),
      @"page": isHeader?@(1):@(self.nextPage),
      @"userToken":[KFUserManager shareUserManager].user.userToken?:@"",
      @"forum_id":@(self.forum.Id)
      };
    [KFHttpTool getDocPostListWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        resultBlock([result kf5_arrayForKeyPath:@"data.posts"],[result kf5_numberForKeyPath:@"data.next_page"].unsignedIntegerValue,error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        KFDocItem *post = self.docArray[indexPath.row];
        KFDocumentViewController *viewController = [[KFDocumentViewController alloc]initWithPost:post];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
