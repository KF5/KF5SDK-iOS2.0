//
//  KFPhotoGroupView.h
//  Pods
//
//  Created by admin on 16/11/17.
//
//

#import <UIKit/UIKit.h>

/// Single picture's info.
@interface KFPhotoGroupItem : NSObject
@property (nullable, nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nullable, nonatomic, strong) NSURL *largeImageURL;
@end

@interface KFPhotoGroupView : UIView


@property (nullable, nonatomic, readonly) NSArray <KFPhotoGroupItem *>*groupItems;
@property (nonatomic, readonly) NSInteger currentPage;


- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
- (nonnull instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nonnull instancetype)initWithGroupItems:(nonnull NSArray <KFPhotoGroupItem *>*)groupItems;

- (void)presentFromImageView:(nonnull UIView *)fromView
                 toContainer:(nonnull UIView *)container
                    animated:(BOOL)animated
                  completion:(nullable void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;
- (void)dismiss;

@end
