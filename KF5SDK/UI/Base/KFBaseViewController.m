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
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willRotateFromInterface:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)willRotateFromInterface:(NSNotification *)note{
    [self.view endEditing:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self updateFrame];
    });
}

// ios7以下系统的横屏的事件
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self updateFrame];
    [self.view endEditing:YES];
}

// ios8以上系统的横屏的事件
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.view endEditing:YES];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.view.bounds = CGRectMake(0, 0, size.width, size.height);
        [self updateFrame];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (KF5iOS7 && KF5ViewLandscape) {
        [self updateFrame];
    }
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
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willRotateFromInterface:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)willRotateFromInterface:(NSNotification *)note{
    [self.view endEditing:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self updateFrame];
    });
}

// ios7以下系统的横屏的事件
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self updateFrame];
    [self.view endEditing:YES];
}

// ios8以上系统的横屏的事件
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.view endEditing:YES];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.view.bounds = CGRectMake(0, 0, size.width, size.height);
        [self updateFrame];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (KF5iOS7 && KF5ViewLandscape) {
        [self updateFrame];
    }
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
