//
//  KFVoiceMessageCell.m
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import "KFVoiceMessageCell.h"
#import "KFHelper.h"
#import "KFChatVoiceManager.h"
#import "KFProgressHUD.h"

@implementation KFVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        KFVoiceMessageView *voiceMessageView = [[KFVoiceMessageView alloc]initWithMeTextColor:[UIColor whiteColor] otherTextColor:[UIColor blackColor] textFont:KF5Helper.KF5TitleFont];
        voiceMessageView.userInteractionEnabled = YES;
        [voiceMessageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoice:)]];
        [self.contentView addSubview:voiceMessageView];
        _voiceMessageView  = voiceMessageView;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMessageModel:) name:KFChatVoiceDidDownloadNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMessageModel:) name:KFChatVoiceStopPlayNotification object:nil];
    }
    return self;
}

- (void)tapVoice:(UITapGestureRecognizer *)tap{
    if (![[KFChatVoiceManager sharedChatVoiceManager]isPlayingWithMessageModel:self.messageModel]) {
        [self.voiceMessageView startAnimating];
        [[KFChatVoiceManager sharedChatVoiceManager]playVoiceWithMessageModel:self.messageModel];
    }else{
        // 会使用通知中心暂停播放
        [[KFChatVoiceManager sharedChatVoiceManager]stopVoicePlayingMessage];
    }
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    _voiceMessageView.frame = messageModel.messageViewFrame;
    [_voiceMessageView setMessageForm:messageModel.message.messageFrom];
    // 如果还未下载完成,voiceLength = -1
    _voiceMessageView.isLoading = messageModel.voiceLength  < 0;
    [_voiceMessageView setDuration:messageModel.voiceLength];
    
    if ([[KFChatVoiceManager sharedChatVoiceManager] isPlayingWithMessageModel:messageModel]) {
        [_voiceMessageView startAnimating];
    }else{
        [_voiceMessageView stopAnimating];
    }
}

- (void)updateMessageModel:(NSNotification *)note{
    NSDictionary *dict = note.object;
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    KFMessageModel *model = dict[@"model"];
    NSError *error = dict[@"error"];
    if ([self.messageModel isEqual:model]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (note.name == KFChatVoiceDidDownloadNotification) {
                self.messageModel = model;
            }else if (note.name == KFChatVoiceStopPlayNotification){
                if (error) {
                    [KFProgressHUD showLoadingTo:[UIApplication sharedApplication].keyWindow title:KF5Localized(@"kf5_play_error") hideAfter:0.7f];
                }
                [self.voiceMessageView stopAnimating];
            }
        });
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if ([self.messageBgView pointInside:[self convertPoint:point toView:self.messageBgView] withEvent:event]) {
        return self.voiceMessageView;
    }else{
        return [super hitTest:point withEvent:event];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
