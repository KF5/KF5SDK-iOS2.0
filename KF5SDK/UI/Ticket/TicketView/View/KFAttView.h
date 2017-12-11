//
//  KFAttView.h
//  SampleSDKApp
//
//  Created by admin on 15/3/27.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFSudokuView.h"

@interface KFAttView : UICollectionView

// 图片数组
@property (nullable, nonatomic, strong) NSArray <KFAssetImage *>*images;
@property (nullable, nonatomic, copy) void(^closeViewBlock)(void);
@property (nullable, nonatomic, copy) void(^addImageBlock)(void);

@end
