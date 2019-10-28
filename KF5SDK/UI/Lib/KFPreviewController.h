//
//  KFPreviewController.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/21.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFPlayerController.h"
@class KFPreviewModel, KFPreviewView;

@interface KFPreviewController : KFBaseViewController

- (instancetype)initWithModels:(NSArray<KFPreviewModel *> *)models selectIndex:(NSInteger)selectIndex;
+ (void)presentForViewController:(UIViewController *)vc models:(NSArray <KFPreviewModel *>*)models selectIndex:(NSInteger)selectIndex;
+ (void)setPlaceholderErrorImage:(UIImage *)image;

+ (UIImage *)imageNamed:(NSString *)name;

@end

@interface KFPreviewPhotoCell : UICollectionViewCell

@property (nonatomic, strong) KFPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(UIImage *image);
@property (nonatomic, strong) KFPreviewView *previewView;
- (void)recoverSubviews;
@end

@interface KFPreviewVideoCell : UICollectionViewCell

@property (nonatomic, strong) KFPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);

@end

@interface KFPreviewView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) KFPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(UIImage *image);
- (void)recoverSubviews;

@end

@interface KFPreviewModel: NSObject
// UIImage or NSURL
@property (nonatomic,strong) id value;
@property (nonatomic,strong) UIImage *placeholder;
@property (nonatomic, assign) BOOL  isVideo;
- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder;
- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder isVideo:(BOOL)isVideo;

@end

#pragma mark 转场动画
@interface SwipeUpInteractiveTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

- (instancetype)initWithVC:(UIViewController *)vc;
@property (nonatomic, assign) BOOL shouldComplete;

@end
