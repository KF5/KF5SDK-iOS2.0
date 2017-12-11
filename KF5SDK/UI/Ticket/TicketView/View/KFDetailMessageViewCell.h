//
//  KFDetailMessageViewCell.h
//  Pods
//
//  Created by admin on 16/11/9.
//
//

#import <UIKit/UIKit.h>

@interface KFDetailMessageViewCell : UITableViewCell<UIAppearance>
/**
 *  标题
 */
@property (nullable, nonatomic, weak) UILabel *titleLabel;
/**
 *  内容
 */
@property (nullable, nonatomic, weak) UILabel *contentLabel;

@property (nonnull, nonatomic, strong) NSDictionary *ticketFieldDict;

@end
