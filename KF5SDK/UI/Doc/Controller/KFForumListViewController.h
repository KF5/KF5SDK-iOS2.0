//
//  KFForumListViewController.h
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFDocBaseViewController.h"

@interface KFForumListViewController : KFDocBaseViewController

///分区id
@property (nullable, nonatomic, strong) KFDocItem *category;

/**
 初始化方法

 @param category 分区id
 */
- (nonnull instancetype)initWithCategory:(nullable KFDocItem *)category;

@end
