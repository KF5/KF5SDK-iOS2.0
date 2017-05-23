//
//  KFTicketListViewController.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import "KFBaseViewController.h"

@interface KFTicketListViewController : KFBaseTableViewController

/**每页的数量*/
@property (nonatomic, assign) NSUInteger prePage;
/**
 是否隐藏右侧按钮,默认NO
 */
@property (nonatomic, assign) BOOL isHideRightButton;

@end
