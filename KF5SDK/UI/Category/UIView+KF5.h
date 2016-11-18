//
//  UIView+KF5.h
//  Pods
//
//  Created by admin on 16/10/24.
//
//

#import <UIKit/UIKit.h>

@interface UIView (KF5)

@property (nonatomic) CGFloat kf5_left;        ///< Shortcut for frame.origin.x
@property (nonatomic) CGFloat kf5_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat kf5_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat kf5_bottom;      ///< Shortcut for frame.origin.y + frame.size.height

@property (assign, nonatomic) CGFloat kf5_x;
@property (assign, nonatomic) CGFloat kf5_y;
@property (assign, nonatomic) CGFloat kf5_w;
@property (assign, nonatomic) CGFloat kf5_h;
@property (assign, nonatomic) CGFloat kf5_centerX;
@property (assign, nonatomic) CGFloat kf5_centerY;
@property (assign, nonatomic) CGSize  kf5_size;
@property (assign, nonatomic) CGPoint kf5_origin;

- (UIViewController *)kf5_viewController;
- (UIImage *)kf5_snapshotImage;
- (UIImage *)kf5_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

@end
