//
//  KFTicketViewCell.h
//  Pods
//
//  Created by admin on 16/11/4.
//
//

#import <UIKit/UIKit.h>
#import "KFComment.h"
#import "KFSudokuView.h"
#import "KFLabel.h"
#import "KFLoadView.h"

@class KFTicketViewCell;
@protocol KFTicketViewCellDelegate <NSObject>

- (void)ticketCell:(nonnull KFTicketViewCell *)cell clickImageWithIndex:(NSInteger)index;
- (void)ticketCell:(nonnull KFTicketViewCell *)cell clickLabelWithInfo:(nullable NSDictionary *)info;

@end

@interface KFTicketViewCell : UITableViewCell

@property (nullable, nonatomic, weak) id<KFTicketViewCellDelegate> cellDelegate;

/**附件**/
@property (nullable, nonatomic, weak) KFSudokuView *photoImageView;
/**头像*/
@property (nullable, nonatomic, weak) UIImageView *headImageView;
/**时间*/
@property (nullable, nonatomic, weak) UILabel *timeLabel;
/**角色*/
@property (nullable, nonatomic, weak) UILabel *nameLabel;
/**内容*/
@property (nullable, nonatomic, weak) KFLabel *commentLabel;
/**loadView*/
@property (nullable, nonatomic, weak) KFLoadView *loadView;


@property (nullable, nonatomic, strong) KFComment *comment;

@end
