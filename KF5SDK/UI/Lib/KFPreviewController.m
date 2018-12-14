//
//  KFPreviewController.m
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/21.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "KFPreviewController.h"
#import "UIImageView+WebCache.h"
#import "KFAutoLayout.h"

static UIImage *placeHolderErrorImage = nil;
static NSString *cellID = @"KFPreviewCell";

@interface KFProgressView : UIView

@property (nonatomic, assign) double progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@interface KFPreviewView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) KFProgressView *progressView;
@property (nonatomic, strong) KFPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(UIImage *image);
- (void)recoverSubviews;

@end

@interface KFPreviewCell : UICollectionViewCell

@property (nonatomic, strong) KFPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(UIImage *image);
@property (nonatomic, weak) KFPreviewView *previewView;
- (void)recoverSubviews;

@end

@interface KFSwipeUpInteractiveTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

- (instancetype)initWithVC:(UIViewController *)vc;
@property (nonatomic, assign) BOOL shouldComplete;
@property (nonatomic, assign) BOOL interacting;
@property (nonatomic, weak) UIViewController *presentingVC;

@end

@interface KFPreviewController()

@property (nonatomic,strong) NSArray <KFPreviewModel *>*models;
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) UILabel *numberLabel;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) KFSwipeUpInteractiveTransition *transitionController;

@end

@implementation KFPreviewController

- (instancetype)initWithModels:(NSArray<KFPreviewModel *> *)models selectIndex:(NSInteger)selectIndex{
    self = [super init];
    if (self) {
        _models = models;
        _selectIndex = selectIndex;
        _transitionController = [[KFSwipeUpInteractiveTransition alloc] initWithVC:self];
    }
    return self;
}

+ (void)presentForViewController:(UIViewController *)vc models:(NSArray<KFPreviewModel *> *)models selectIndex:(NSInteger)selectIndex{
    KFPreviewController *previewController = [[KFPreviewController alloc] initWithModels:models selectIndex:selectIndex];
    [vc presentViewController:previewController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (self.models.count == 0) return;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    collectionView.backgroundColor = [UIColor blackColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.contentOffset = CGPointZero;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    UILabel *numberLabel = [[UILabel alloc] init];
    numberLabel.font = [UIFont boldSystemFontOfSize:20];
    numberLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    [numberLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.centerX.kf_equalTo(self.view);
        make.bottom.kf_equalTo(self.view.kf5_safeAreaLayoutGuideBottom);
    }];
    
    [collectionView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self.view);
        make.left.kf_equalTo(self.view).kf_offset(-10);
        make.right.kf_equalTo(self.view).kf_offset(10);
        make.bottom.kf_equalTo(self.view);
    }];
    
    [_collectionView registerClass:[KFPreviewCell class] forCellWithReuseIdentifier:cellID];
    
    if (self.selectIndex < self.models.count) self.currentIndex = self.selectIndex;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    
    offSetWidth = offSetWidth +  ((self.view.frame.size.width + 20) * 0.5);
    NSInteger currentIndex = offSetWidth / (self.view.frame.size.width + 20);
    if (currentIndex < _models.count && self.currentIndex != currentIndex) {
        self.currentIndex = currentIndex;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%lu", currentIndex+1,(unsigned long)self.models.count];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize.height != self.collectionView.frame.size.height || self.selectIndex > -1) {
        self.selectIndex = -1;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [_collectionView setCollectionViewLayout:layout];
        _collectionView.contentSize = CGSizeMake(self.models.count * (self.collectionView.frame.size.width + 20), self.collectionView.frame.size.height);
        [_collectionView setContentOffset:CGPointMake(layout.itemSize.width * self.currentIndex, 0)];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KFPreviewCell *photoPreviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    photoPreviewCell.model = self.models[indexPath.row];
    __weak typeof(self)weakSelf = self;
    [photoPreviewCell setSingleTapGestureBlock:^{
        [weakSelf dismissView];
    }];
    [photoPreviewCell setLongTapGestureBlock:^(UIImage *image) {
        [weakSelf showSaveActivityView:image];
    }];
    return photoPreviewCell;
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSaveActivityView:(UIImage *)image{
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[KFPreviewCell class]]) {
        [(KFPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[KFPreviewCell class]]) {
        [(KFPreviewCell *)cell recoverSubviews];
    }
}
+ (void)setPlaceholderErrorImage:(UIImage *)image{
    placeHolderErrorImage = image;
}

@end

@implementation KFPreviewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        KFPreviewView *previewView = [[KFPreviewView alloc] initWithFrame:CGRectZero];
        [self addSubview:previewView];
        _previewView = previewView;
        __weak typeof(self) weakSelf = self;
        [previewView setSingleTapGestureBlock:^{
            if (weakSelf.singleTapGestureBlock) {
                weakSelf.singleTapGestureBlock();
            }
        }];
        [previewView setLongTapGestureBlock:^(UIImage *image) {
            if (weakSelf.longTapGestureBlock) {
                weakSelf.longTapGestureBlock(image);
            }
        }];
    }
    return self;
}

- (void)setModel:(KFPreviewModel *)model{
    _model = model;
    _previewView.model = model;
}

- (void)recoverSubviews {
    [_previewView recoverSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}
@end


@implementation KFPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_scrollView addSubview:_imageView];
        
        _progressView = [[KFProgressView alloc] init];
        _progressView.hidden = YES;
        [self addSubview:_progressView];
        
        [self configGestureRecognizer];
    }
    return self;
}

- (void)configGestureRecognizer {
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self addGestureRecognizer:longTap];
}

- (void)setModel:(KFPreviewModel *)model{
    _model = model;
    if ([model.value isKindOfClass:[UIImage class]]) {
        self.imageView.image = model.value;
        [self resizeSubviews];
        _progressView.hidden = YES;
    }else if ([model.value isKindOfClass:[NSURL class]]){
        __weak typeof(self)weakSelf = self;
        [self.imageView sd_setImageWithURL:model.value placeholderImage:model.placeholder options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.hidden = NO;
                [weakSelf bringSubviewToFront:weakSelf.progressView];
                CGFloat progress = receivedSize / (CGFloat)expectedSize;
                progress = progress > 0.02 ? progress : 0.02;
                weakSelf.progressView.progress = progress;
                if (progress >= 1) {
                    weakSelf.progressView.hidden = YES;
                }
            });
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    weakSelf.imageView.image = placeHolderErrorImage;
                }
                [weakSelf resizeSubviews];
                weakSelf.progressView.hidden = YES;
            });
        }];
    }else{
        NSAssert(NO, @"model的格式错误");
    }
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews{
    CGSize imageSize = self.imageView.image.size;
    
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        imageSize = CGSizeMake(320, 320);
    }
    CGRect imageFrame = CGRectZero;
    CGFloat scale = MIN(self.scrollView.frame.size.height / imageSize.height, self.scrollView.frame.size.width / imageSize.width);
    imageFrame.size.width = floor(scale * imageSize.width);
    imageFrame.size.height = floor(scale * imageSize.height);
    _imageView.frame = imageFrame;
    _imageView.center = CGPointMake(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
    
    _scrollView.contentSize = imageFrame.size;
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageView.frame.size.height <= self.frame.size.height ? NO : YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height);
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.frame.size.width - progressWH) / 2;
    CGFloat progressY = (self.frame.size.height - progressWH) / 2;
    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)longTap:(UILongPressGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateBegan && self.longTapGestureBlock && self.imageView.image != placeHolderErrorImage) {
        self.longTapGestureBlock(self.imageView.image);
    }
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.frame.size.width > _scrollView.contentSize.width) ? ((_scrollView.frame.size.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.frame.size.height > _scrollView.contentSize.height) ? ((_scrollView.frame.size.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end


@implementation KFProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _progressLayer.opacity = 1;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = 5;
        
        [_progressLayer setShadowColor:[UIColor blackColor].CGColor];
        [_progressLayer setShadowOffset:CGSizeMake(1, 1)];
        [_progressLayer setShadowOpacity:0.5];
        [_progressLayer setShadowRadius:2];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = rect.size.width / 2;
    CGFloat startA = - M_PI_2;
    CGFloat endA = - M_PI_2 + M_PI * 2 * _progress;
    _progressLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    _progressLayer.path =[path CGPath];
    
    [_progressLayer removeFromSuperlayer];
    [self.layer addSublayer:_progressLayer];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

@end


@implementation KFPreviewModel

- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder{
    self = [super init];
    if (self) {
        self.value = value;
        self.placeholder = placeholder;
    }
    return self;
}

@end

@implementation KFSwipeUpInteractiveTransition
- (instancetype)initWithVC:(UIViewController *)vc{
    self = [super init];
    if (self) {
        _presentingVC = vc;
        vc.transitioningDelegate = self;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [vc.view addGestureRecognizer:pan];
    }
    return self;
}

-(CGFloat)completionSpeed{
    return 1 - self.percentComplete;
}
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:

            self.interacting = YES;
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged: {

            CGFloat fraction = translation.y / ([UIScreen mainScreen].bounds.size.height * 0.6);
            fraction = fminf(fmaxf(fraction, 0.0), 1.0);
            self.shouldComplete = (fraction > 0.25);
            
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.interacting = NO;
            if (!self.shouldComplete || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect initFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame = CGRectOffset(initFrame, 0, screenBounds.size.height);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    [containerView sendSubviewToBack:toVC.view];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromVC.view.frame = finalFrame;
        toVC.view.frame = initFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interacting ? self : nil;
}

@end
