//
//  KFImageView.m
//  SampleSDKApp
//
//  Created by admin on 15/3/26.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "KFImageView.h"
#import "UIImageView+WebCache.h"
#import "KFAttachment.h"
#import "KFHelper.h"
#import "JKAlert.h"

static const NSInteger kKF5MaxRow = 3;


@implementation KFAssetImage

+ (NSMutableArray<KFAssetImage *> *)assetImagesWithImages:(NSArray<UIImage *> *)images assets:(NSArray *)assets{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i<images.count; i++) {
        if (i < assets.count) {
            KFAssetImage *assetImage = [[KFAssetImage alloc] init];
            assetImage.image = images[i];
            assetImage.asset = assets[i];
            [array addObject:assetImage];
        }

    }
    return array;
}

@end

@interface KFImageView()

@end

@implementation KFImageView

- (id)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.placeholderImage = KF5Helper.placeholderImage;
    }
    return self;
}

/**
 *  删除图片事件
 */
- (void)deleteImage:(UILongPressGestureRecognizer *)recognizer{
    __weak typeof(self)weakSelf = self;
    [JKAlert showMessage:KF5Localized(@"kf5_delete_this_image") OKHandler:^(JKAlertItem *item) {
        [(UIImageView *)recognizer.view removeFromSuperview];
        
        if (recognizer.view.tag < weakSelf.images.count) {
            [weakSelf.images removeObjectAtIndex:recognizer.view.tag];
        }
        for (int i = 0; i < weakSelf.subviews.count; i++) {
            [self updateImageFrameWithIndex:i];
        }
        self.kf5_h = self.imageViewHeight;
    }];
}

/**
 *  添加图片
 */
- (void)setImages:(NSMutableArray<KFAssetImage *> *)images{
        
    _images = images;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i< images.count; i++) {
        KFAssetImage *assetImage = images[i];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[assetImage.image kf5_imageCompressForSize:CGSizeMake(self.imageHW, self.imageHW)]];
        imageView.tag = i;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteImage:)]];
        [self addSubview:imageView];
        [self updateImageFrameWithIndex:i];
    }
    self.kf5_h = self.imageViewHeight;
}

- (void)setAttachments:(NSArray<KFAttachment *> *)attachments{
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0,j = 0; i<attachments.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        [self addSubview:imageView];
        KFAttachment *attachment = attachments[i];
        if ([attachment.url isKindOfClass:[UIImage class]]) {
            imageView.image = (UIImage *)attachment.url;
            imageView.tag = j++;
        }else{
            if (attachment.isImage) {
                imageView.tag = j++;
                // 下载图片
                [imageView sd_setImageWithURL:[NSURL URLWithString:attachment.url] placeholderImage:self.placeholderImage options:SDWebImageLowPriority|SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
                        if (KF5Helper.placeholderImageFailed) {
                            imageView.image = KF5Helper.placeholderImageFailed;
                        }
                    }
                }];
            }else{
                imageView.image = KF5Helper.placeholderOther;
            }
        }
    }
    [self updateFrame];
}

#pragma mark 对添加的ImageView进行排列
- (void)updateImageFrameWithIndex:(NSInteger)index{
    CGFloat viewBorder = KF5Helper.KF5DefaultSpacing;

    NSInteger col = index % kKF5MaxRow;
    NSInteger row = index / kKF5MaxRow;
    UIImageView *imageView = self.subviews[index];
    
    imageView.frame = CGRectMake((viewBorder + self.imageHW) * col, (viewBorder + self.imageHW) * row, self.imageHW, self.imageHW);
}

- (void)updateFrame{
    for (int i = 0; i < self.subviews.count; i++) {
        [self updateImageFrameWithIndex:i];
    }
    self.kf5_h = self.imageViewHeight;
}

- (CGFloat)imageHW{
    return ceilf((self.kf5_w - KF5Helper.KF5DefaultSpacing * (kKF5MaxRow - 1)) / kKF5MaxRow);
}

#pragma mark 更新图片视图的布局
- (CGFloat)imageViewHeight{
    CGFloat viewBorder = KF5Helper.KF5DefaultSpacing;
    if (self.subviews.count > 0) {
        CGFloat rowCount = (self.subviews.count - 1) / kKF5MaxRow + 1;
        return (self.imageHW + viewBorder) * rowCount - viewBorder;
    }else{
        return 0;
    }
}

- (void)tapImage:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(imageViewLookWithIndex:)]) {
        [self.delegate imageViewLookWithIndex:(int)tap.view.tag];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
