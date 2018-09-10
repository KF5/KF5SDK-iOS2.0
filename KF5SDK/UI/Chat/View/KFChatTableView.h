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
- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime;


@end
