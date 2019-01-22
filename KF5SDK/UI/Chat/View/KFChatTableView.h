//
//  KFChatTableView.h
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import <UIKit/UIKit.h>
#import "KFTextMessageCell.h"
#import "KFImageMessageCell.h"
#import "KFVoiceMessageCell.h"
#import "KFSystemMessageCell.h"
#import "KFCardMessageCell.h"
#import "KFVideoMessageCell.h"

typedef NS_ENUM(NSInteger, KFScrollType) {
    KFScrollTypeNone = 0,    // 不滚动
    KFScrollTypeBottom,      // 滚动到底部
    KFScrollTypeHold         // 滚动到原来的位置,界面上不动
};

@class KFMessageModel;
@class KFChatTableView;

@protocol KFChatTableViewDelegate <NSObject>

- (void)tableViewWithRefreshData:(nonnull KFChatTableView *)tableView;

@end

@interface KFChatTableView : UITableView

@property (nullable, nonatomic, weak) id<KFChatViewCellDelegate,KFChatTableViewDelegate> tableDelegate;

@property (nullable, nonatomic, strong) NSMutableArray <KFMessageModel *>*messageModels;

//是否正在刷新
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign,getter=isCanRefresh) BOOL canRefresh;

- (void)scrollViewBottomWithAnimated:(BOOL)animated;

/**
 刷新并添加内容

 @param scrollType 滚动类型
 @param handleModelBlock 处理Model的block
 @warning handleModelBlock的返回值为@{@"insert":@[NSIndexPath],@"reload":@[NSIndexPath],@"delete":@[NSIndexPath]}
 */
- (void)reloadData:(KFScrollType)scrollType handleModelBlock:(NSDictionary <NSString *, NSArray <NSIndexPath *>*>* (^)(NSMutableArray<KFMessageModel *> *messageModels))handleModelBlock;

@end
