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

@property (nonatomic, strong) NSMutableArray *docArray;

///每页的数量
@property (nonatomic, assign) NSUInteger prePage;
///下一页
@property (nonatomic, assign) NSUInteger nextPage;

- (void)refreshData:(BOOL)isHeader resultBlock:(void (^)(NSArray <NSDictionary *>*dictArray,NSInteger nextPage,NSError *error))resultBlock;

@end
