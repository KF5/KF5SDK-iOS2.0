//
//  KFProgressHUD.m
//  Pods
//
//  Created by admin on 16/10/13.
//
//

#import "KFProgressHUD.h"
#import "MBProgressHUD.h"
#import "KFHelper.h"

static CGFloat FONTSIZE = 14.f;
static CGFloat OPACITY = 0.95;

@interface KFProgressHUD()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation KFProgressHUD

+ (instancetype)showHUDAddedTo:(UIView *)view title:(NSString *)title{
    if (view == nil) return nil;
    
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:view]?:[MBProgressHUD showHUDAddedTo:view animated:YES];

    HUD.contentColor = [UIColor whiteColor];
    HUD.bezelView.color = [UIColor colorWithWhite:0 alpha:OPACITY];
    HUD.label.font = [UIFont systemFontOfSize:FONTSIZE];
    HUD.label.text = title;
    
    KFProgressHUD *progress = [[KFProgressHUD alloc]init];
    progress.hud = HUD;
    
    return progress;
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


+ (void)showLoadingTo:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
    KFProgressHUD *progress = [KFProgressHUD showHUDAddedTo:view title:title];
    if(afterSecond > 0)
        [progress.hud hideAnimated:YES afterDelay:afterSecond];
}

+ (void)showTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
    KFProgressHUD *progress = [self showHUDAddedTo:view title:title];
    progress.hud.mode = MBProgressHUDModeText;
    if(afterSecond > 0)
        [progress.hud hideAnimated:YES afterDelay:afterSecond];
}

+ (void)showErrorTitleToView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)afterSecond{
     KFProgressHUD *progress = [self showHUDAddedTo:view title:title];
    progress.hud.customView = [[UIImageView alloc] initWithImage:KF5Helper.hudErrorImage];
    progress.hud.mode = MBProgressHUDModeCustomView;
    if(afterSecond > 0)
        [progress.hud hideAnimated:YES afterDelay:afterSecond];
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

+ (void)setFontSize:(CGFloat)fontSize opacity:(CGFloat)opacity{
    FONTSIZE = fontSize;
    OPACITY = opacity;
}

@end
