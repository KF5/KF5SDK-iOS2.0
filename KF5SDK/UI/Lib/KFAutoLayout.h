//
//  KFAutoLayout.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/16.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - view属性
@interface KFViewAttribute: NSObject

@property (nonatomic, weak, readonly) id _Nullable item;
@property (nonatomic, assign, readonly) NSLayoutAttribute layoutAttribute;
- (id _Nonnull )initWithItem:(id _Nullable )item layoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end

#pragma mark - autolayout操作
@interface KFAutoLayoutMaker : NSObject

@property (nullable, nonatomic,strong, readonly) NSLayoutConstraint *layoutConstraint;

- (nonnull instancetype)initWithFirstItem:(nonnull id)firstItem firstAttribute:(NSLayoutAttribute)firstAttribute;
// 偏移量
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat offset))kf_offset;
// 关系
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(id _Nonnull attr))kf_equalTo;
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(id _Nonnull attr))kf_greaterThanOrEqualTo;
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(id _Nonnull attr))kf_lessThanOrEqualTo;
// 赋值
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat constant))kf_equal;
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat constant))kf_greaterThanOrEqual;
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat constant))kf_lessThanOrEqual;
// 倍数
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat multiplier))multiplier;
// 权重
- (KFAutoLayoutMaker * _Nonnull (^_Nonnull)(UILayoutPriority priority))priority;

- (BOOL)isActive;

- (nonnull NSLayoutConstraint *)active;
- (void)deactivate;
@end

@interface KFAutoLayout : NSObject

- (nonnull instancetype)initWithView:(UIView * _Nonnull)view;

// 基本操作
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull left;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull top;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull right;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull bottom;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull leading;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull trailing;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull width;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull height;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull centerX;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull centerY;
@property (nonatomic, strong, readonly) KFAutoLayoutMaker * _Nonnull baseline;

// 激活
- (void)active;
// 取消
- (void)deactivate;

@end

@interface UIView (KF5AutoLayout)

@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_left;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_top;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_right;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_bottom;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_leading;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_trailing;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_width;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_height;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_centerX;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_centerY;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_baseline;

//iOS11 safeArea
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_safeAreaLayoutGuideTop;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_safeAreaLayoutGuideBottom;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_safeAreaLayoutGuideLeft;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_safeAreaLayoutGuideRight;

- (void)kf5_makeConstraints:(void(^_Nonnull)(KFAutoLayout * _Nonnull make))make;
- (void)kf5_remakeConstraints:(void(^_Nonnull)(KFAutoLayout * _Nonnull make))make;

- (UIEdgeInsets)kf5_safeAreaInsets;

@end

@interface UIViewController (KF5AutoLayout)

@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_topLayoutGuide;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_bottomLayoutGuide;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_topLayoutGuideTop;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_bottomLayoutGuideBottom;

@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_safeAreaTopLayoutGuide;
@property (nonatomic, strong, readonly) KFViewAttribute * _Nonnull kf5_safeAreaBottomLayoutGuide;

@end
