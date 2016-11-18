//
//  KFBaseMessageCell.h
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import "KFChatViewCell.h"
@class KFLoadView;

@interface KFBaseMessageCell : KFChatViewCell

@property (nullable, nonatomic, weak) UILabel *timeLabel;
@property (nullable, nonatomic, weak) UIImageView *headerImageView;
@property (nullable, nonatomic, weak) UIImageView *messageBgView;
@property (nullable, nonatomic, weak) KFLoadView *loadView;

@end
