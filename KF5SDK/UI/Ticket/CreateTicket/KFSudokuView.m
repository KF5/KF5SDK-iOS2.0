//
//  KFSudokuView.m
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/22.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "KFSudokuView.h"
#import "KFAutoLayout.h"
#import "KFAttachment.h"
#import "UIImageView+WebCache.h"
#import "KFHelper.h"

static NSString *cellID = @"KFSudokuViewCell";

@interface KFSudokuView()<UICollectionViewDataSource>

@property (nonatomic, assign) CGFloat oldWidth;
@property (nullable, nonatomic, strong) KFAutoLayoutMaker *heightLayoutMaker;

@end

@implementation KFSudokuView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout{
    self = [super initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewLayout alloc] init]];
    if (self) {
        self.scrollsToTop = NO;
        self.scrollEnabled = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.maxColumnNumber = 3;
        self.dataSource = self;
        [self registerClass:[KFSudokuViewCell class] forCellWithReuseIdentifier:cellID];
    }
    return self;
}

- (NSInteger)rowNumber{
    return ceil(((CGFloat)self.items.count) / self.maxColumnNumber);
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    [self kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        self.heightLayoutMaker = make.height.equalTo(self.kf5_width).multiplier(0).priority(UILayoutPriorityDefaultHigh);
    }];
}

- (void)setItems:(NSArray *)items{
    _items = items;
    [self.heightLayoutMaker.multiplier(self.rowNumber/ ((CGFloat)self.maxColumnNumber)) active];
    [self reloadData];
}

#pragma mark UICollectionView delegate datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KFSudokuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.item = self.items[indexPath.row];
    __weak typeof(self)weakSelf = self;
    cell.clickCellBlock = ^(KFSudokuViewCell *cell) {
        if (weakSelf.clickCellBlock) {
            weakSelf.clickCellBlock(cell);
        }
    };
    return cell;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.oldWidth != self.frame.size.width) {
        self.oldWidth = self.frame.size.width;
        CGFloat sideLength = self.frame.size.width / self.maxColumnNumber;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = CGSizeMake(sideLength, sideLength);
        flowLayout.sectionInset = UIEdgeInsetsZero;
        self.collectionViewLayout = flowLayout;
    }
}

@end

@implementation KFSudokuViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        [imageView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            CGFloat spacing = KF5Helper.KF5DefaultSpacing/2;
            make.top.equalTo(self.contentView).offset(spacing);
            make.left.equalTo(self.contentView).offset(spacing);
            make.bottom.equalTo(self.contentView).offset(-spacing);
            make.right.equalTo(self.contentView).offset(-spacing);
        }];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)]];
    }
    return self;
}

- (void)tapImageView:(UITapGestureRecognizer *)tap{
    if (self.clickCellBlock) {
        self.clickCellBlock(self);
    }
}

- (void)setItem:(id)item{
    _item = item;
    if ([item isKindOfClass:[KFAssetImage class]]) {
        self.imageView.image = ((KFAssetImage *)item).image;
    }else if ([item isKindOfClass:[KFAttachment class]]){
        KFAttachment *attachment = item;
        if (attachment.isImage) {
            if ([attachment.url isKindOfClass:[UIImage class]]) {
                self.imageView.image = (UIImage *)attachment.url;
            }else if ([attachment.url isKindOfClass:[NSString class]]){
                __weak typeof(self)weakSelf = self;
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:attachment.url] placeholderImage:KF5Helper.placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            weakSelf.imageView.image = KF5Helper.placeholderImageFailed;
                        }
                    });
                }];
            }
        }else{
            self.imageView.image = KF5Helper.placeholderOther;
        }
    }
}

@end


@implementation KFAssetImage

+ (NSMutableArray<KFAssetImage *> *)assetImagesWithImages:(NSArray<UIImage *> *)images assets:(NSArray *)assets{
    if (images.count != assets.count) return nil;
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
