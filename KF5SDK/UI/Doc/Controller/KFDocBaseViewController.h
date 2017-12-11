//
//  KFDocBaseViewController.h
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import "KFBaseViewController.h"
#import "KFDocItem.h"

@interface KFDocBaseViewController : KFBaseTableViewController

@property (nonatomic,strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray <KFDocItem *>*docArray;

///每页的数量
@property (nonatomic, assign) NSUInteger prePage;
///下一页
@property (nonatomic, assign) NSUInteger nextPage;

///是否显示右侧按钮
+ (void)setIsHideRightButton:(BOOL)isHideRightButton;

- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray <NSDictionary *>*dictArray,NSInteger nextPage,NSError *error))resultBlock;

@end
