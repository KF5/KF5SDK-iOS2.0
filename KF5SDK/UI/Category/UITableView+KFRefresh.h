//
//  UITableView+KFRefresh.h
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import <UIKit/UIKit.h>

@interface UITableView (KFRefresh)

- (void)kf5_headerWithRefreshingBlock:(void (^)())refreshingBlock;
- (void)kf5_footerWithRefreshingBlock:(void (^)())refreshingBlock;

- (void)kf5_endRefreshingWithNoMoreData;

- (void)kf5_endHeaderRefreshing;
- (void)kf5_endFooterRefreshing;


@end
