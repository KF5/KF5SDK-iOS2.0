//
//  Alert.m
//  AlertDemo
//
//  Created by Mark Miscavage on 4/22/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import "KFAlertMessage.h"
#import "KFHelper.h"
#import "KFAutoLayout.h"

@interface KFAlertMessage ()

@property (nonatomic, assign) CGFloat timeDuration;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, assign) KF5AlertType alertType;

@property (nonatomic,strong) NSLayoutConstraint *topLayout;

@end

@implementation KFAlertMessage

- (instancetype)initWithViewController:(UIViewController *)viewController title:(NSString *)title duration:(CGFloat)duration showType:(KF5AlertType)alertType{
    self = [super init];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        self.minimumScaleFactor = 14.0/16.0;
        self.text = title;
        
        self.viewController = viewController;
        self.timeDuration = duration;
        self.alertType = alertType;
    }
    
    return self;
}
#pragma mark Timer Methods

- (void)setTimer {
    if (_timeDuration != 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeDuration target:self selector:@selector(countTimePassed) userInfo:nil repeats:YES];
    }
}

- (void)countTimePassed {
    [_timer invalidate];
    _timer = nil;
    [self dismissAlert];
}

#pragma mark Accessor Methods
-(void)setAlertType:(KF5AlertType)alertType{
    _alertType = alertType;
    if (alertType == KF5AlertTypeError) {
        self.backgroundColor = [UIColor colorWithRed:0.91 green:0.302 blue:0.235 alpha:1]; /*#e84d3c*/
    }else if (alertType == KF5AlertTypeSuccess) {
        self.backgroundColor = [UIColor colorWithRed:0.196 green:0.576 blue:0.827 alpha:1]; /*#3293d3*/
    }else if (alertType == KF5AlertTypeWarning) {
        self.backgroundColor = [UIColor colorWithRed:1 green:0.804 blue:0 alpha:1]; /*#ffcd00*/
    }
}

- (void)showAlert{
    [self.viewController.view addSubview:self];
    
    [self kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.equalTo(self.viewController.view);
        self.topLayout =make.top.equalTo(self.viewController.kf5_safeAreaTopLayoutGuide).offset(-40).active;
        make.right.equalTo(self.viewController.view);
        make.height.kf_equal(40);
    }];
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:0.5f animations:^{
        self.topLayout.constant = 0;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setTimer];
    }];
}

- (void)dismissAlert{
    
    [_timer invalidate];
    _timer = nil;
    
    if (!self.viewController) return;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.topLayout.constant = -40;
        [self.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
