//
//  KFSudokuView.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/22.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFAttachment;
@class KFSudokuViewCell;

@interface KFAssetImage : NSObject

@property (nullable, nonatomic, strong) UIImage *image;
@property (nullable, nonatomic, strong) id asset;
+ (nonnull NSMutableArray <KFAssetImage *>*)assetImagesWithImages:(nonnull NSArray  <UIImage *>*)images assets:(nonnull NSArray *)assets;

@end

@interface KFSudokuView : UICollectionView

// 每行默认3个
@property (nonatomic, assign) NSInteger maxColumnNumber;
// 图片数组 @[KFAssetImage]或@[KFAttachment]
@property (nullable, nonatomic, strong) NSArray *items;
@property (nullable, nonatomic, copy) void(^clickCellBlock)(KFSudokuViewCell * _Nonnull cell);

@end

@interface KFSudokuViewCell : UICollectionViewCell

@property (nonatomic,weak) UIImageView * _Nullable imageView;
@property (nullable,nonatomic,strong) NSIndexPath *indexPath;
// KFSudokuImage或KFAttachment
@property (nullable,nonatomic,strong) id item;
@property (nullable, nonatomic, copy) void(^clickCellBlock)(KFSudokuViewCell * _Nonnull cell);
@end
