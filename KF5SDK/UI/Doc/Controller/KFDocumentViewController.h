//
//  KFDocumentViewController.h
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFBaseViewController.h"
#import "KFDocItem.h"

@interface KFDocumentViewController : KFBaseViewController

///文档id
@property (nullable, nonatomic, strong) KFDocItem *post;
/**
 初始化方法

 @param post 文档id
 */
- (nullable instancetype)initWithPost:(nullable KFDocItem *)post;

@end
