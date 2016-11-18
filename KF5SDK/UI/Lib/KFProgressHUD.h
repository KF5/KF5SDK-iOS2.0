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


+ (void)showLoadingTo:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;
+ (void)showTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;
+ (void)showErrorTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond;

+ (void)hideHUDForView:(UIView *)view hideAfter:(NSTimeInterval)afterSecond;

+ (void)setFontSize:(CGFloat)fontSize opacity:(CGFloat)opacity;

@end
