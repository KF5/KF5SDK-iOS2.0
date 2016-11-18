//
//  KFDetailMessageViewCell.h
//  Pods
//
//  Created by admin on 16/11/9.
//
//

#import <UIKit/UIKit.h>
#import "KFTicketFieldModel.h"

@interface KFDetailMessageViewCell : UITableViewCell<UIAppearance>
/**
 *  标题
 */
@property (nullable, nonatomic, weak) UILabel *titleLabel;
/**
 *  内容
 */
@property (nullable, nonatomic, weak) UILabel *contentLabel;

@property (nullable, nonatomic, strong) KFTicketFieldModel *ticketFieldModel;

@end
