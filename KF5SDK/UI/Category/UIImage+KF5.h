//
//  UIImage+KF5.h
//  Pods
//
//  Created by admin on 16/10/25.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (KF5)

+ (nullable UIImage *)kf5_imageWithBundleImageName:(nonnull NSString *)name;
- (nullable UIImage *)kf5_imageWithOverlayColor:(nonnull UIColor *)overlayColor;
- (nonnull UIImage *)kf5_imageResize;
- (nullable UIImage *)kf5_rotationimageWithRotate:(long double)rotate;
/// 设置图片尺寸
- (nullable UIImage*)kf5_imageCompressForSize:(CGSize)size;
///等比缩放
-(nullable UIImage *)kf5_imageScalingForSize:(CGSize)size;
///修复拍照上传图片竖着拍,上传后横屏的bug
-(nullable UIImage *)kf5_fixOrientation;
+ (nullable UIImage *)kf5_imageWithColor:(nonnull UIColor *)color size:(CGSize)size;
+ (nullable UIImage *)kf5_drawArrowImageWithColor:(nonnull UIColor *)color size:(CGSize)size;

@end
