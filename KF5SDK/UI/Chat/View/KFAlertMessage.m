//
//  Alert.m
//  AlertDemo
//
//  Created by Mark Miscavage on 4/22/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import "KFAlertMessage.h"

@interface KFAlertMessage ()

@property (nonatomic, assign) CGFloat timeDuration;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, assign) KF5AlertType alertType;

@end

@implementation KFAlertMessage

- (instancetype)initWithViewController:(UIViewController *)viewController title:(NSString *)title duration:(CGFloat)duration showType:(KF5AlertType)alertType{
    
    if ([super init]) {
        _timeDuration = duration;
        self.text = title;
        self.backgroundColor = [UIColor colorWithRed:0.91 green:0.302 blue:0.235 alpha:1];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setTextColor:[UIColor whiteColor]];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
        [self setMinimumScaleFactor:14.0/16.0];
        
        self.viewController = viewController;
        self.timeDuration = duration;
        self.alertType = alertType;
        self.text = title;
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
    if (alertType == KF5AlertTypeError) {
        [self setBackgroundColor:[UIColor colorWithRed:0.91 green:0.302 blue:0.235 alpha:1] /*#e84d3c*/];
    }
    else if (alertType == KF5AlertTypeSuccess) {
        [self setBackgroundColor:[UIColor colorWithRed:0.196 green:0.576 blue:0.827 alpha:1] /*#3293d3*/];
    }
    else if (alertType == KF5AlertTypeWarning) {
        [self setBackgroundColor:[UIColor colorWithRed:1 green:0.804 blue:0 alpha:1] /*#ffcd00*/];
    }
}

- (void)showAlert{
    [self.viewController.view addSubview:self];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    self.frame = CGRectMake(0, -40, self.viewController.view.frame.size.width, 40);
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = 64;
        self.frame = frame;
        
    }completion:^(BOOL finished) {
        [self setTimer];
    }];
}

- (void)dismissAlert{
    
    [_timer invalidate];
    _timer = nil;
    
    if (!self.viewController) return;
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = -40;
        self.frame = frame;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
