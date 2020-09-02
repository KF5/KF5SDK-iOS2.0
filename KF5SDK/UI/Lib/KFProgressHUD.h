//
//  KFProgressHUD.h
//  Pods
//
//  Created by admin on 16/10/13.
//
//

#import <UIKit/UIKit.h>

@interface KFProgressHUD : NSObject

+ (void)showTitleToView:(UIView *)view title:(NSString *)title;
+ (void)showLoadingTo:(UIView *)view title:(NSString *)title;
+ (void)showDefaultLoadingTo:(UIView *)view;
+ (void)hideHUDForView:(UIView *)view;
+ (void)showProgress:(UIView *)view progress:(CGFloat)progress;

+ (void)showLoadingTo:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;
+ (void)showTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;
+ (void)showErrorTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;
+ (void)showSuccessTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;

+ (void)hideHUDForView:(UIView *)view hideAfter:(NSTimeInterval)afterSecond;

+ (void)setFont:(UIFont *)font backgroundColor:(UIColor *)backgroundColor contentColor:(UIColor *)contentColor;

@end
