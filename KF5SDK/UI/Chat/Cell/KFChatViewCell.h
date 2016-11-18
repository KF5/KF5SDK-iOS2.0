//
//  KFChatViewCell.h
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import <UIKit/UIKit.h>
#import "KFMessageModel.h"

@class KFChatViewCell;

@protocol KFChatViewCellDelegate <NSObject>

- (void)cell:(nonnull KFChatViewCell *)cell reSendMessageWithMessageModel:(nullable KFMessageModel *)model;
- (void)cell:(nonnull KFChatViewCell *)cell clickImageWithMessageModel:(nullable KFMessageModel *)model;
- (void)cell:(nonnull KFChatViewCell *)cell clickVoiceWithMessageModel:(nullable KFMessageModel *)model;
- (void)cell:(nonnull KFChatViewCell *)cell clickLabelWithInfo:(nullable NSDictionary *)info;
- (void)reloadCell:(nonnull KFChatViewCell *)cell;

@end

@interface KFChatViewCell : UITableViewCell

@property (nullable, nonatomic, weak) id <KFChatViewCellDelegate>cellDelegate;

@property (nullable, nonatomic, strong) KFMessageModel *messageModel;

@end
