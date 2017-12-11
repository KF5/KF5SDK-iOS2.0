//
//  KFTicketListTableViewCell.h
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import <UIKit/UIKit.h>
#import "KFTicket.h"

@interface KFTicketListViewCell : UITableViewCell

@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *statusLabel;
@property (nonatomic, weak) UIView *pointView;

@property (nonatomic, strong) KFTicket *ticket;

@end
