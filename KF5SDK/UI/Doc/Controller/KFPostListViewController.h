//
//  KFPostListViewController.h
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFDocBaseViewController.h"

@interface KFPostListViewController : KFDocBaseViewController


///分类id
@property (nullable, nonatomic, strong) KFDocItem *forum;

/**
 初始化方法

 @param forum 分类id
 */
- (nonnull instancetype)initWithForum:(nullable KFDocItem *)forum;

@end
