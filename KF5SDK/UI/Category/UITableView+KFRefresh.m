//
//  UITableView+KFRefresh.m
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import "UITableView+KFRefresh.h"
#import "MJRefresh.h"

@implementation UITableView (KFRefresh)

- (void)kf5_headerWithRefreshingBlock:(void (^)())refreshingBlock{
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:refreshingBlock];
}

- (void)kf5_footerWithRefreshingBlock:(void (^)())refreshingBlock{
    self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:refreshingBlock];
}

- (void)kf5_endRefreshingWithNoMoreData{
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)kf5_beginHeaderRefreshing{
    [self.mj_header beginRefreshing];
}

- (void)kf5_endHeaderRefreshing{
    [self.mj_header endRefreshing];
}

- (void)kf5_endFooterRefreshing{
    [self.mj_footer endRefreshing];
}

@end
