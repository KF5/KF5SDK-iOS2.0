//
//  KFTicketTableView.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import <UIKit/UIKit.h>
#import "KFCommentModel.h"
#import "KFTicketViewCell.h"

@interface KFTicketTableView : UITableView

@property (nullable, nonatomic, weak) id <KFTicketViewCellDelegate> cellDelegate;

@property (nullable, nonatomic, strong) NSMutableArray <KFCommentModel *>*commentModelArray;

- (void)scrollViewBottomHasMainQueue:(BOOL)hasMainQueue;
- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime;

@end
