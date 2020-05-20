//
//  KFBaseViewController.m
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import "KFBaseViewController.h"
#import "KFHelper.h"

@implementation KFBaseTableViewController
- (instancetype)init{
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willRotateFromInterface:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        self.modalPresentationStyle = KF5Helper.defaultModalPresentationStyle;
    }
    return self;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (![viewControllerToPresent isKindOfClass:[UISearchController class]]) {
        viewControllerToPresent.modalPresentationStyle = KF5Helper.defaultModalPresentationStyle;
    }
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)willRotateFromInterface:(NSNotification *)note{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self updateFrame];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)updateFrame{}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

@end


@implementation KFBaseViewController
- (instancetype)init{
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willRotateFromInterface:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        self.modalPresentationStyle = KF5Helper.defaultModalPresentationStyle;
    }
    return self;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    viewControllerToPresent.modalPresentationStyle = KF5Helper.defaultModalPresentationStyle;
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)willRotateFromInterface:(NSNotification *)note{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self updateFrame];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)updateFrame{}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

@end
