//
//  KFAttView.h
//  SampleSDKApp
//
//  Created by admin on 15/3/27.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFImageView.h"

static CGFloat KFViewSideLength = 30;

@class KFAttView;
@protocol KFAttViewDelegate <NSObject>

- (void)attViewAddAction:(KFAttView *)attView;

- (void)attViewcloseAction:(KFAttView *)attView;

@end

@interface KFAttView : UIView

@property (nonatomic, strong) NSMutableArray <KFAssetImage *>*images;

@property (nonatomic ,weak) id<KFAttViewDelegate> degelate;

/**
 *  删除所有添加的图片
 */
- (void)removeImages;

@end
