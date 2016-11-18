//
//  KFVoiceMessageCell.h
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import "KFBaseMessageCell.h"
#import "KFVoiceMessageView.h"

@interface KFVoiceMessageCell : KFBaseMessageCell

@property (nullable, nonatomic, weak) KFVoiceMessageView *voiceMessageView;

@end
