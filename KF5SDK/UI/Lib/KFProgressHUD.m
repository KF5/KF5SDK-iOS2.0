//
//  KFProgressHUD.m
//  Pods
//
//  Created by admin on 16/10/13.
//
//

#import "KFProgressHUD.h"
#import "MBProgressHUD.h"
#import "KFCategory.h"

static UIFont *kProgressHUDFont;
static UIColor *kProgressHUDBackgroundColor;
static UIColor *kProgressHUDColor;


@interface KFProgressHUD()

@end

@implementation KFProgressHUD

+ (void)initialize {
    kProgressHUDFont = [UIFont systemFontOfSize:14.f];
    kProgressHUDBackgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    kProgressHUDColor = [UIColor whiteColor];
}

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view title:(NSString *)title{
    if (view == nil) return nil;
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view]?:[MBProgressHUD showHUDAddedTo:view animated:YES];

    hud.contentColor = kProgressHUDColor;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = kProgressHUDBackgroundColor;
    hud.label.font = kProgressHUDFont;
    hud.label.text = title;
        
    return hud;
}

+ (void)showTitleToView:(UIView *)view title:(NSString *)title{
    [self showTitleToView:view title:title hideAfter:0];
}
+ (void)showLoadingTo:(UIView *)view title:(NSString *)title{
    [self showLoadingTo:view title:title hideAfter:0];
}
+ (void)showDefaultLoadingTo:(UIView *)view{
    [self showLoadingTo:view title:KF5Localized(@"kf5_loading") hideAfter:0];
}
+ (void)hideHUDForView:(UIView *)view{
    [self hideHUDForView:view hideAfter:0];
}

+ (void)showProgress:(UIView *)view progress:(CGFloat)progress{
    MBProgressHUD *hud = [KFProgressHUD showHUDAddedTo:view title:nil];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.progress = progress;
}


+ (void)showLoadingTo:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
    MBProgressHUD *hud = [KFProgressHUD showHUDAddedTo:view title:title];
    if(afterSecond > 0)
        [hud hideAnimated:YES afterDelay:afterSecond];
}

+ (void)showTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
    MBProgressHUD *hud = [self showHUDAddedTo:view title:title];
    hud.mode = MBProgressHUDModeText;
    if(afterSecond > 0)
        [hud hideAnimated:YES afterDelay:afterSecond];
}

+ (void)showErrorTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
     MBProgressHUD *hud = [self showHUDAddedTo:view title:title];
    hud.customView = [[UIImageView alloc] initWithImage:KF5Helper.hudErrorImage];
    hud.mode = MBProgressHUDModeCustomView;
    if(afterSecond > 0)
        [hud hideAnimated:YES afterDelay:afterSecond];
}
+ (void)showSuccessTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
    MBProgressHUD *hud = [self showHUDAddedTo:view title:title];
    hud.customView = [[UIImageView alloc] initWithImage:KF5Helper.hudSuccessImage];
    hud.mode = MBProgressHUDModeCustomView;
    if(afterSecond > 0)
        [hud hideAnimated:YES afterDelay:afterSecond];
}

+ (void)hideHUDForView:(UIView *)view hideAfter:(NSTimeInterval)afterSecond{
    if (view == nil) return;
    if (afterSecond > 0) {
        MBProgressHUD *HUD = [MBProgressHUD HUDForView:view];
        [HUD hideAnimated:YES afterDelay:afterSecond];
    }else{
        [MBProgressHUD hideHUDForView:view animated:YES];
    }
}

+ (void)setFont:(UIFont *)font backgroundColor:(UIColor *)backgroundColor contentColor:(UIColor *)contentColor{
    kProgressHUDFont = font;
    kProgressHUDBackgroundColor = backgroundColor;
    kProgressHUDColor = contentColor;
}

@end
