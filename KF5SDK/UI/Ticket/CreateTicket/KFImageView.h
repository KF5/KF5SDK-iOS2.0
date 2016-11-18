//
//  KFImageView.h
//  SampleSDKApp
//
//  Created by admin on 15/3/26.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KFAttachment;
@class KFImageView;

@interface KFAssetImage : NSObject

@property (nullable, nonatomic, strong) UIImage *image;
@property (nullable, nonatomic, strong) id asset;

/**
 快捷方法

 @warning assets.count必须等于images.count
 */
+ (nonnull NSMutableArray <KFAssetImage *>*)assetImagesWithImages:(nonnull NSArray  <UIImage *>*)images assets:(nonnull NSArray *)assets;

@end

@protocol KFImageViewDelegate <NSObject>
@optional

- (void)imageViewLookWithIndex:(NSInteger)index;

@end

@interface KFImageView : UIView

@property (nullable, nonatomic, strong) NSMutableArray <KFAssetImage *>*images;

@property (nullable, nonatomic, strong) UIImage *placeholderImage;

@property (nullable, nonatomic ,weak) id<KFImageViewDelegate> delegate;

/**
 工单内容cell使用
 */
- (void)setAttachments:(nonnull NSArray <KFAttachment *>*)attachments;

- (CGFloat)imageViewHeight;

- (void)updateFrame;


@end
