//
//  KFImageMessageCell.m
//  Pods
//
//  Created by admin on 16/10/28.
//
//

#import "KFImageMessageCell.h"
#import "UIImageView+WebCache.h"
#import "KFHelper.h"

@implementation KFImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *messageImageView = [[UIImageView alloc] init];
        messageImageView.backgroundColor = KF5Helper.KF5PlaceHolderBgColor;
        messageImageView.contentMode = UIViewContentModeScaleAspectFit;
        messageImageView.userInteractionEnabled = YES;
        [messageImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        [self.contentView addSubview:messageImageView];
        _messageImageView = messageImageView;
    }
    return self;
}

- (void)tapImage:(UITapGestureRecognizer *)tap{
    if ([self.cellDelegate respondsToSelector:@selector(cell:clickImageWithMessageModel:)]) {
        [self.cellDelegate cell:self clickImageWithMessageModel:self.messageModel];
    }
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    _messageImageView.frame = messageModel.messageViewFrame;
    _messageImageView.image = messageModel.image;
    
    if (_messageImageView.image == nil) {
        if ([messageModel.message.url hasPrefix:@"http"]) {
            __weak UIImageView *weakImageView = _messageImageView;
            [_messageImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&thumb=1",messageModel.message.url]] placeholderImage:KF5Helper.placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    weakImageView.image = KF5Helper.placeholderImageFailed;
                }else{
                    messageModel.image = image;
                }
            }];
        }
    }
}

@end
