//
//  KFTicketTableView.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import <UIKit/UIKit.h>
#import "KFComment.h"
#import "KFTicketViewCell.h"
#import "KFRatingModel.h"

@class KFTicketTableView;
@protocol KFTicketTableViewDelegate  <NSObject>

- (void)ticketTableView:(nullable KFTicketTableView *)tableView clickHeaderViewWithRatingModel:(nullable KFRatingModel *)ratingModel;

@end

@interface KFTicketTableView : UITableView

@property (nullable, nonatomic, weak) id <KFTicketTableViewDelegate,KFTicketViewCellDelegate> cellDelegate;

@property (nullable, nonatomic, strong) NSMutableArray <KFComment *>*commentList;

- (void)scrollViewBottomWithAnimated:(BOOL)animated;
- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime;


/**
 如果ratingModel为nil,则不显示满意度评价入口
 */
@property (nullable, nonatomic, strong) KFRatingModel *ratingModel;

@end
