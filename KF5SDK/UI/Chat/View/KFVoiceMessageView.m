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

@property (nonatomic, weak) UIActivityIndicatorView *loadingView;

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
        
        UILabel *timeLabel = [KFHelper labelWithFont:textFont textColor:nil];
        [self addSubview:timeLabel];
        _timeLabel  = timeLabel;
        
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidden = YES;
        [self addSubview:loadingView];
        _loadingView = loadingView;
        
        UIImageView *voiceImageView = [[UIImageView alloc]init];
        voiceImageView.animationImages = KF5Helper.chat_meWaves;
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
        if (messageForm == KFMessageFromMe) {
            self.voiceImageView.animationImages = KF5Helper.chat_meWaves;
        }else{
            self.voiceImageView.animationImages = KF5Helper.chat_otherWaves;
        }
        [self setNeedsLayout];
    }
}

- (void)setDuration:(double)duration{
    if (duration >= 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%d\"",(int)(ceil(duration))];
    }else{
        _timeLabel.text = @"";
    }
}

- (void)setIsLoading:(BOOL)isLoading{
    _isLoading = isLoading;
    if (isLoading) {
        [_loadingView startAnimating];
        _loadingView.hidden = NO;
    }else{
        [_loadingView stopAnimating];
        _loadingView.hidden = YES;
    }
}

- (void)startAnimating{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.voiceImageView startAnimating];
    });
}
- (void)stopAnimating{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.voiceImageView stopAnimating];
    });
}

- (void)layoutSubviews{
    
    CGSize timeSize = CGSizeMake(35, 20);
    if (_messageForm == KFMessageFromMe) {
        self.voiceImageView.image = KF5Helper.chat_meWaves.lastObject;
        self.timeLabel.textColor = self.meTextColor;
        
        self.voiceImageView.frame = CGRectMake(self.frame.size.width - 20 + 5, 0, 20, 20);
        self.timeLabel.frame = CGRectMake(0, 0, timeSize.width, self.frame.size.height);
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        self.voiceImageView.image = KF5Helper.chat_otherWaves.lastObject;
        self.timeLabel.textColor = self.otherTextColor;
        
        self.voiceImageView.frame = CGRectMake(-5, 0, 20, 20);
        self.timeLabel.frame = CGRectMake(self.frame.size.width - timeSize.width, 0, timeSize.width, self.frame.size.height);
        self.timeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    self.voiceImageView.center = CGPointMake(self.voiceImageView.center.x, self.frame.size.height / 2);
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.frame.size.height / 2);
    self.loadingView.center = self.timeLabel.center;
}


@end
