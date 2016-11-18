//
//  UIView+KF5.m
//  Pods
//
//  Created by admin on 16/10/24.
//
//

#import "UIView+KF5.h"

@implementation UIView (KF5)

- (CGFloat)kf5_left {
    return self.frame.origin.x;
}

- (void)setKf5_left:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)kf5_top {
    return self.frame.origin.y;
}

- (void)setKf5_top:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)kf5_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setKf5_right:(CGFloat)right{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)kf5_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setKf5_bottom:(CGFloat)bottom{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


- (void)setKf5_x:(CGFloat)kf5_x{
    CGRect frame = self.frame;
    frame.origin.x = kf5_x;
    self.frame = frame;
}

- (CGFloat)kf5_x{
    return self.frame.origin.x;
}

- (void)setKf5_y:(CGFloat)kf5_y{
    CGRect frame = self.frame;
    frame.origin.y = kf5_y;
    self.frame = frame;
}

- (CGFloat)kf5_y{
    return self.frame.origin.y;
}

- (void)setKf5_w:(CGFloat)kf5_w{
    CGRect frame = self.frame;
    frame.size.width = kf5_w;
    self.frame = frame;
}

- (CGFloat)kf5_w{
    return self.frame.size.width;
}

- (void)setKf5_h:(CGFloat)kf5_h{
    CGRect frame = self.frame;
    frame.size.height = kf5_h;
    self.frame = frame;
}

- (CGFloat)kf5_h{
    return self.frame.size.height;
}

- (CGFloat)kf5_centerX {
    return self.center.x;
}

- (void)setKf5_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)kf5_centerY{
    return self.center.y;
}

- (void)setKf5_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


- (void)setKf5_size:(CGSize)kf5_size{
    CGRect frame = self.frame;
    frame.size = kf5_size;
    self.frame = frame;
}

- (CGSize)kf5_size{
    return self.frame.size;
}

- (void)setKf5_origin:(CGPoint)kf5_origin{
    CGRect frame = self.frame;
    frame.origin = kf5_origin;
    self.frame = frame;
}

- (CGPoint)kf5_origin{
    return self.frame.origin;
}

- (UIViewController *)kf5_viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (UIImage *)kf5_snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)kf5_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self kf5_snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

@end
