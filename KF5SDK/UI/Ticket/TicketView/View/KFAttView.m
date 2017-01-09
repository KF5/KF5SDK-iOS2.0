//
//  KFAttView.m
//  SampleSDKApp
//
//  Created by admin on 15/3/27.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "KFAttView.h"
#import "KFHelper.h"
#import "JKAlert.h"

@interface KFAttView()

@property (nonatomic, weak) UIButton *closeBtn;

@property (nonatomic, weak) UIButton *addImageBtn;

@end


@implementation KFAttView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        [closeBtn setImage:KF5Helper.ticketTool_closeAtt forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(delAttBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.closeBtn = closeBtn;

        closeBtn.frame = CGRectMake(KF5Helper.KF5DefaultSpacing, KF5Helper.KF5DefaultSpacing, KFViewSideLength, KFViewSideLength);
        [self addSubview:closeBtn];
        
        UIButton *addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addImageBtn setImage:KF5Helper.ticketTool_addAtt forState:UIControlStateNormal];
        [addImageBtn addTarget:self action:@selector(addAttBtn:) forControlEvents:UIControlEventTouchUpInside];
        addImageBtn.frame = CGRectMake(CGRectGetMaxX(closeBtn.frame) + KF5Helper.KF5DefaultSpacing, KF5Helper.KF5DefaultSpacing, KFViewSideLength, KFViewSideLength);
        self.addImageBtn = addImageBtn;
        [self addSubview:addImageBtn];
        
    }
    return self;
}
#pragma mark 添加附件
- (void)addAttBtn:(UIButton *)btn{
    if ([self.degelate respondsToSelector:@selector(attViewAddAction:)])
        [self.degelate attViewAddAction:self];
}
#pragma mark 关闭该视图
- (void)delAttBtn:(UIButton *)btn{
    if ([self.degelate respondsToSelector:@selector(attViewcloseAction:)])
        [self.degelate attViewcloseAction:self];
}

/**
 *  添加图片
 */
- (void)setImages:(NSMutableArray<KFAssetImage *> *)images{
    
    [self removeImages];
    _images = images;
    
    for (NSInteger i = 0; i< images.count; i++) {
        KFAssetImage *assetImage = images[i];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[assetImage.image kf5_imageCompressForSize:CGSizeMake(KFViewSideLength, KFViewSideLength)]];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2 - 5;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteImage:)]];
        [self addSubview:imageView];
        
    }
    [self setNeedsLayout];
    
}

/**
 *  删除图片事件
 */
- (void)deleteImage:(UITapGestureRecognizer *)recognizer{
    __weak typeof(self)weakSelf = self;
    [JKAlert showMessage:KF5Localized(@"kf5_delete_this_image") OKHandler:^(JKAlertItem *item) {
        if (recognizer.view.tag < weakSelf.images.count) {
            [weakSelf.images removeObjectAtIndex:recognizer.view.tag];
        }
        [recognizer.view removeFromSuperview];
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = self.subviews[i];
        
        view.frame = CGRectMake(KFViewSideLength * i  + KF5Helper.KF5DefaultSpacing * (i + 1), KF5Helper.KF5DefaultSpacing, KFViewSideLength, KFViewSideLength);
        view.center = CGPointMake(view.center.x, self.frame.size.height / 2);
        view.layer.cornerRadius = KFViewSideLength / 2 - 11;
    }
}

- (void)removeImages{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.subviews];
    [array removeObjectAtIndex:0];
    [array removeObjectAtIndex:0];
    [array makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.images removeAllObjects];
}


@end
