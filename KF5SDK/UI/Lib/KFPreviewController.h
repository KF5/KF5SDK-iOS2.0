//
//  KFPreviewController.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/21.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KFPreviewModel;
@interface KFPreviewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

- (instancetype)initWithModels:(NSArray<KFPreviewModel *> *)models selectIndex:(NSInteger)selectIndex;
+ (void)presentForViewController:(UIViewController *)vc models:(NSArray <KFPreviewModel *>*)models selectIndex:(NSInteger)selectIndex;
+ (void)setPlaceholderErrorImage:(UIImage *)image;

@end

@interface KFPreviewModel: NSObject

// UIImage or NSURL
@property (nonatomic,strong) id value;
@property (nonatomic,strong) UIImage *placeholder;
- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder;

@end
