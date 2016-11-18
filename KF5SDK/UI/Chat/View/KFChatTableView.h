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

@class KFMessageModel;
@class KFChatTableView;

@protocol KFChatTableViewDelegate <NSObject>

- (void)tableViewWithRefreshData:(nonnull KFChatTableView *)tableView;

/**
 返回偏移量高度
 */
- (CGFloat)tableViewWithOffsetTop:(nonnull KFChatTableView *)tableView;

@end

@interface KFChatTableView : UITableView

@property (nullable, nonatomic, weak) id<KFChatViewCellDelegate,KFChatTableViewDelegate> tableDelegate;

@property (nullable, nonatomic, strong) NSMutableArray <KFMessageModel *>*messageModelArray;

- (void)scrollViewBottomHasMainQueue:(BOOL)hasMainQueue;

- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime;

- (void)endRefreshing;
- (void)endRefreshingWithNoMoreData;

- (void)updateFrame;

@end
