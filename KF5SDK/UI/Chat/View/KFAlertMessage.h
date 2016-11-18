//
//  Alert.h
//  AlertDemo
//
//  Created by Mark Miscavage on 4/22/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import <UIKit/UIKit.h>

//Type of alert, Error = red, Success = blue, Warning = yellow
typedef NS_ENUM(NSUInteger, KF5AlertType) {
    KF5AlertTypeError = 1,
    KF5AlertTypeSuccess,
    KF5AlertTypeWarning
};

@interface KFAlertMessage : UILabel

- (instancetype)initWithViewController:(UIViewController *)viewController title:(NSString *)title duration:(CGFloat)duration showType:(KF5AlertType)alertType;
- (void)showAlert;
- (void)dismissAlert;
@end
