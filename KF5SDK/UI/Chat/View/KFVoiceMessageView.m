//
//  KFVoiceMessageView.m
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import "KFVoiceMessageView.h"
#import "KFHelper.h"

@interface KFVoiceMessageView ()

@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIImageView *voiceImageView;

@property (nonatomic, assign) KFMessageFrom messageForm;

@property (nonatomic, strong) UIColor *meTextColor;
@property (nonatomic, strong) UIColor *otherTextColor;

@end

@implementation KFVoiceMessageView

- (instancetype)initWithMeTextColor:(UIColor *)meTextColor otherTextColor:(UIColor *)otherTextColor textFont:(UIFont *)textFont{
    self = [super init];
    if (self) {
        _meTextColor = meTextColor;
        _otherTextColor = otherTextColor;
        
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.font = textFont;
        [self addSubview:timeLabel];
        _timeLabel  = timeLabel;
        
        UIImageView *voiceImageView = [[UIImageView alloc]init];
        voiceImageView.animationDuration    = 2.0;
        voiceImageView.animationRepeatCount = 30;
        [self addSubview:voiceImageView];
        _voiceImageView = voiceImageView;
        

    }
    return self;
}

- (void)setMessageForm:(KFMessageFrom)messageForm{
    if (messageForm != _messageForm) {
        _messageForm = messageForm;
        [self setNeedsLayout];
    }
}

- (void)setDuration:(double)duration{
    _timeLabel.text = [NSString stringWithFormat:@"%d\"",(int)(ceil(duration))];
}

- (void)startAnimating{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.voiceImageView.isAnimating) {
            if (_messageForm == KFMessageFromMe) {
                self.voiceImageView.animationImages = KF5Helper.chat_meWaves;
            }else{
                self.voiceImageView.animationImages = KF5Helper.chat_otherWaves;
            }
            [self.voiceImageView startAnimating];
        }
    });
}
- (void)stopAnimating{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.voiceImageView stopAnimating];
        self.voiceImageView.animationImages = nil;
    });
}

- (void)layoutSubviews{
    
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(100, 20)];
    if (_messageForm == KFMessageFromMe) {
        self.voiceImageView.image = KF5Helper.chat_meWaves.lastObject;
        self.timeLabel.textColor = self.meTextColor;
        
        self.voiceImageView.frame = CGRectMake(self.kf5_w - 20 + 5, 0, 20, 20);
        self.timeLabel.frame = CGRectMake(0, 0, timeSize.width, self.kf5_h);
    }else{
        self.voiceImageView.image = KF5Helper.chat_otherWaves.lastObject;
        self.timeLabel.textColor = self.otherTextColor;
        
        self.voiceImageView.frame = CGRectMake(-5, 0, 20, 20);
        self.timeLabel.frame = CGRectMake(self.kf5_w - timeSize.width, 0, timeSize.width, self.kf5_h);
    }
    
    self.voiceImageView.center = CGPointMake(self.voiceImageView.center.x, self.kf5_h / 2);
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.kf5_h / 2);
}


@end
