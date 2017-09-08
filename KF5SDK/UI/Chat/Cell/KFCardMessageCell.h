//
//  KFCardMessageCell.h
//  Pods
//
//  Created by admin on 2017/9/5.
//
//

#import <UIKit/UIKit.h>
#import "KFChatViewCell.h"

@interface KFCardMessageCell : KFChatViewCell
@property (nullable, nonatomic, weak) UIImageView *headerImageView;
@property (nullable, nonatomic, weak) UILabel *titleLabel;
@property (nullable, nonatomic, weak) UILabel *priceLabel;
@property (nullable, nonatomic, weak) UIButton *linkBtn;
@end
