//
//  KFSystemMessageCell.h
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import "KFChatViewCell.h"
#import "KFLabel.h"

@interface KFSystemMessageCell : KFChatViewCell

@property (nullable, nonatomic, weak) KFLabel *systemMessageLabel;
@property (nullable, nonatomic, weak) CALayer *backgroundLayer;

@end
