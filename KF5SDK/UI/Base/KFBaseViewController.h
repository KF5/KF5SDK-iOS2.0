//
//  KFBaseViewController.h
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import <UIKit/UIKit.h>

@interface KFBaseViewController : UIViewController

@property (nonatomic,weak) UITableView *tempTableView;

- (void)updateFrame;

@end

@interface KFBaseTableViewController : UITableViewController

- (void)updateFrame;

@end
