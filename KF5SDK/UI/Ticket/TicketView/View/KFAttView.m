//
//  KFAttView.m
//  SampleSDKApp
//
//  Created by admin on 15/3/27.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "KFAttView.h"
#import "KFHelper.h"

static NSString *cellID = @"KFAttViewCell";

@interface KFAttView()<UICollectionViewDataSource>
@property (nonatomic,strong) NSArray <KFAssetImage *>*items;
@end


@implementation KFAttView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout{
    self = [super initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.dataSource = self;
        [self registerClass:[KFSudokuViewCell class] forCellWithReuseIdentifier:cellID];
        self.images = nil;
    }
    return self;
}

- (void)setImages:(NSArray<KFAssetImage *> *)images{
    _images = images;
    NSArray *array = @[KF5Helper.ticketTool_closeAtt,KF5Helper.ticketTool_addAtt];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[KFAssetImage assetImagesWithImages:array assets:array]];
    if (images.count > 0) [items addObjectsFromArray:images];
    self.items = items;
    [self reloadData];
}

#pragma mark UICollectionView delegate datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KFSudokuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.imageView.userInteractionEnabled = YES;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 5;
    cell.indexPath = indexPath;
    cell.item = self.items[indexPath.row];
    __weak typeof(self)weakSelf = self;
    cell.clickCellBlock = ^(KFSudokuViewCell *cell) {
        switch (cell.indexPath.row) {
            case 0:
                if (weakSelf.closeViewBlock)
                    weakSelf.closeViewBlock();
                break;
            case 1:
                if (weakSelf.addImageBlock) {
                    weakSelf.addImageBlock();
                }
                break;
            default:
                [[KFHelper alertWithMessage:KF5Localized(@"kf5_delete_this_image") confirmHandler:^(UIAlertAction * _Nonnull action) {
                    NSMutableArray *array = [NSMutableArray arrayWithArray:weakSelf.images];
                    [array removeObject:cell.item];
                    weakSelf.images = array;
                }]showToVC:nil];
                break;
        }
    };
    return cell;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize.height != self.frame.size.height) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = CGSizeMake(self.frame.size.height, self.frame.size.height);
        flowLayout.sectionInset = UIEdgeInsetsZero;
        self.collectionViewLayout = flowLayout;
    }
}

@end
