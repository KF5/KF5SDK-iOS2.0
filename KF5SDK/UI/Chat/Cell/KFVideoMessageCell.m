//
//  KFVideoMessageCell.m
//  KF5SDKUI2.0
//
//  Created by admin on 1/7/19.
//  Copyright © 2019 kf5. All rights reserved.
//

#import "KFVideoMessageCell.h"
#import "KFCategory.h"
#import "KFChatVoiceManager.h"

@implementation KFVideoMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *messageImageView = [[UIImageView alloc] init];
        messageImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:messageImageView];
        _messageImageView = messageImageView;
        
        UIButton *playImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playImageButton.frame = CGRectMake(0, 0, 50, 50);
        [playImageButton setImage:KF5Helper.videoPlayImage forState:UIControlStateNormal];
        [playImageButton setImage:KF5Helper.videoPlayImageH forState:UIControlStateNormal];
        [playImageButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [messageImageView addSubview:playImageButton];
        _playImageButton = playImageButton;
    }
    return self;
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    UIImage *image = [[KFChatVoiceManager sharedChatVoiceManager]downloadVideoImageWithMessageModel:messageModel];
    self.messageImageView.frame = messageModel.messageViewFrame;
    self.messageImageView.image = image ?: KF5Helper.placeholderImage;
    
    self.playImageButton.center = CGPointMake(self.messageImageView.bounds.size.width / 2, self.messageImageView.bounds.size.height / 2);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if ([self.messageBgView pointInside:[self convertPoint:point toView:self.messageBgView] withEvent:event]) {
        return self.playImageButton;
    }else{
        return [super hitTest:point withEvent:event];
    }
}

- (void)playVideo {
    if ([self.cellDelegate respondsToSelector:@selector(cell:clickVideoWithMessageModel:image:)]) {
        [self.cellDelegate cell:self clickVideoWithMessageModel:self.messageModel image:self.messageImageView.image];
    }
}

@end
