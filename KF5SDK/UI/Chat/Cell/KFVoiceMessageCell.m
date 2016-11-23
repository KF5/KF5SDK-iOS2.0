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

@implementation KFVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        KFVoiceMessageView *voiceMessageView = [[KFVoiceMessageView alloc]initWithMeTextColor:[UIColor whiteColor] otherTextColor:[UIColor blackColor] textFont:KF5Helper.KF5TitleFont];
        voiceMessageView.userInteractionEnabled = YES;
        [voiceMessageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoice:)]];
        [self.contentView addSubview:voiceMessageView];
        _voiceMessageView  = voiceMessageView;
    }
    return self;
}

- (void)tapVoice:(UITapGestureRecognizer *)tap{
    if ([self.cellDelegate respondsToSelector:@selector(cell:clickVoiceWithMessageModel:)]) {
        [self.cellDelegate cell:self clickVoiceWithMessageModel:self.messageModel];
    }
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    
    if (self.messageModel) {
        if (self.messageModel.voiceLength == 0) {
            @try {[self.messageModel removeObserver:self forKeyPath:@"voiceLength"];
            } @catch (NSException *exception) {}
        }else{
            @try {[self.messageModel removeObserver:self forKeyPath:@"isPlaying"];
            } @catch (NSException *exception) {}
        }
    }
    
    [super setMessageModel:messageModel];
    
    _voiceMessageView.frame = messageModel.messageViewFrame;
    [_voiceMessageView setMessageForm:messageModel.message.messageFrom];
    [_voiceMessageView setDuration:messageModel.voiceLength];
    
    if (messageModel.isPlaying) {
        [_voiceMessageView startAnimating];
    }else{
        [_voiceMessageView stopAnimating];
    }
    
    if (self.messageModel) {
        if (self.messageModel.voiceLength == 0) {
            [self.messageModel addObserver:self forKeyPath:@"voiceLength" options:NSKeyValueObservingOptionNew context:NULL];
        }else{
            [self.messageModel addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"voiceLength"] || [keyPath isEqualToString:@"isPlaying"]){
        [self setMessageModel:self.messageModel];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc{
    if (self.messageModel) {
        if (self.messageModel.voiceLength == 0) {
            @try {[self.messageModel removeObserver:self forKeyPath:@"voiceLength"];
            } @catch (NSException *exception) {}
        }else{
            @try {[self.messageModel removeObserver:self forKeyPath:@"isPlaying"];
            } @catch (NSException *exception) {}
        }
    }
}

@end
