//
//  KFPlayerViewController.m
//  KFAutoLayout
//
//  Created by admin on 12/5/18.
//

#import "KFPlayerController.h"
#import "KFAutoLayout.h"
#import "KFPreviewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "KFProgressHUD.h"
#import <Photos/Photos.h>
#import "KFCategory.h"

@interface KFPlayerController ()<NSURLSessionDelegate>

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, strong) NSURL *localURL;

@property (nonatomic, weak) UIView *contentView;

@end

@implementation KFPlayerController
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([KFPlayerController isSupportLandscape]) {
        return [super supportedInterfaceOrientations];
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}
- (BOOL)shouldAutorotate{
    if ([KFPlayerController isSupportLandscape]) {
        return [super shouldAutorotate];
    }else{
        return NO;
    }
}
static BOOL _supportLandscape;
+ (void)setSupportLandscape:(BOOL)supportLandscape{
    NSArray *interfaceOrientations = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    if ([interfaceOrientations isKindOfClass:[NSArray class]] && ([interfaceOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"] || [interfaceOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"])) {
        _supportLandscape = supportLandscape;
    }
}
+ (BOOL)isSupportLandscape {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *interfaceOrientations = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
        _supportLandscape = [interfaceOrientations isKindOfClass:[NSArray class]] && ([interfaceOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"] || [interfaceOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"]);
    });
    return _supportLandscape;
}

- (void)deviceOrientationDidChange{
    CGSize size = CGSizeZero;
    CGFloat angle = 0;
    if (self.contentView.bounds.size.width > self.contentView.bounds.size.height) {
        size = self.view.frame.size;
        angle = 0;
    }else{
        size =CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);
        angle = M_PI_2;
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.contentView.transform = CGAffineTransformMakeRotation(angle);
        self.contentView.bounds = CGRectMake(0, 0, size.width, size.height);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView *contentView = [[UIView alloc] init];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [contentView addSubview:imageView];
    self.imageView = imageView;
    
    KFPlayerView *playView = [[KFPlayerView alloc] init];
    __weak typeof(self) weakSelf = self;
    playView.statusChange = ^(KFPlayerStatus status) {
        if (status == KFPlayerStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.hidden = YES;
            });
        }
    };
    playView.longTapBlock = ^{
        if (weakSelf.longTapGestureBlock) {
            weakSelf.longTapGestureBlock(weakSelf.model);
        }else{
            [weakSelf saveVideo:weakSelf.model];
        }
    };
    if ([KFPlayerController isSupportLandscape]){
        playView.largeTapBlock = nil;
    }else{
        playView.largeTapBlock = ^{
            [weakSelf deviceOrientationDidChange];
        };
    }

    [contentView addSubview:playView];
    self.playView = playView;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitle:KF5Localized(@"kf5_close") forState:UIControlStateNormal];
    closeBtn.layer.cornerRadius = 5;
    closeBtn.backgroundColor = [[UIColor alloc] initWithWhite:0.5 alpha:0.5];
    [contentView addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    if ([KFPlayerController isSupportLandscape]) {
        [contentView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.left.kf_equalTo(self.view);
            make.right.kf_equalTo(self.view);
            make.top.kf_equalTo(self.view);
            make.bottom.kf_equalTo(self.view);
        }];
    }else{
        contentView.frame = self.view.bounds;
    }
    
    [self.playView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self.contentView);
        make.right.kf_equalTo(self.contentView);
        make.top.kf_equalTo(self.contentView);
        make.bottom.kf_equalTo(self.contentView);
    }];
    
    [closeBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self.contentView.kf5_safeAreaLayoutGuideTop).kf_offset(20);
        make.width.kf_equal(50);
        make.left.kf_equalTo(self.contentView.kf5_safeAreaLayoutGuideLeft).kf_offset(20);
    }];
    
    if (self.model != nil || [self.model.value isKindOfClass:[NSURL class]]) {
        [self assetWithModel:self.model];
        [self.playView resetPlay];
    }
}

- (void)assetWithModel:(KFPreviewModel *)model {
    self.model = model;
    if (model == nil || ![model.value isKindOfClass:[NSURL class]]) {
        return;
    }
    if (model.placeholder) {
        self.imageView.hidden = NO;
        self.imageView.image = model.placeholder;
        [self.imageView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.centerX.kf_equalTo(self.contentView);
            make.centerY.kf_equalTo(self.contentView);
            make.width.kf_equalTo(self.contentView);
            make.height.kf_equalTo(self.imageView.kf5_width).multiplier(self.imageView.image.size.height / self.imageView.image.size.width);
        }];
    }
    
    NSURL *url = model.value;
    if (!url.isFileURL) {
        if (self.localURL) {
            url = self.localURL;
        }else{
            NSString *localPath= [[KFConfig dataDefaultPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[KFPlayerController md5HexDigest:url.absoluteString]]];
            if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                url = [NSURL fileURLWithPath:localPath];
                self.localURL = url;
            }
        }
    }
    [self.playView assetWithURL:url];
    self.playView.mode = KFLayerVideoGravityResizeAspect;
}

- (void)closeAction:(UIButton *)btn {
    if (self.closeGestureBlock) {
        self.closeGestureBlock();
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc{
    [self.playView stop];
    self.playView = nil;
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    [KFProgressHUD showProgress:self.view progress:1.0 * totalBytesWritten / totalBytesExpectedToWrite];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSURL *localURL=  [NSURL fileURLWithPath:[[KFConfig dataDefaultPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[KFPlayerController md5HexDigest:downloadTask.originalRequest.URL.absoluteString]]]];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:localURL error:nil];
    __weak typeof(self) weakSelf = self;
    [self saveVideoWithUrl:localURL location:nil completion:^(PHAsset *asset, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:KF5Localized(@"kf5_save_fial") hideAfter:0.7];
            }else{
                [KFProgressHUD showSuccessTitleToView:weakSelf.view title:KF5Localized(@"kf5_save_success") hideAfter:0.7];
            }
        });

    }];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showErrorTitleToView:self.view title:KF5Localized(@"kf5_save_fial") hideAfter:0.7];
        });
    }
}

#pragma mark - other

- (void)saveVideo:(KFPreviewModel *)model{
    // 如果localURL存在,说明已经下载过了,直接使用这个url即可
    NSURL *url = self.localURL ?: model.value;
    if (url == nil)  return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:KF5Localized(@"kf5_reminder") message:KF5Localized(@"kf5_save_video") preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self)weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:KF5Localized(@"kf5_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KFProgressHUD showDefaultLoadingTo:weakSelf.view];
        });
        if (url.isFileURL) {
            [weakSelf saveVideoWithUrl:url location:nil completion:^(PHAsset *asset, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KFProgressHUD showSuccessTitleToView:weakSelf.view title:KF5Localized(@"kf5_save_success") hideAfter:0.7];
                });
            }];
        }else{
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:weakSelf delegateQueue:[NSOperationQueue mainQueue]];
            [[session downloadTaskWithURL:url] resume];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:KF5Localized(@"kf5_cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveVideoWithUrl:(NSURL *)url location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion {
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}

+ (NSString *)md5HexDigest:(NSString *)input{
    if (input == nil) return nil;
    
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i< CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}

@end





@interface KFPlayerView ()<UIGestureRecognizerDelegate,KFControlViewDelegate>

@end
static NSInteger count = 0;
@implementation KFPlayerView
+(Class)layerClass{
    return [AVPlayerLayer class];
}
//KFRK: Get方法和Set方法
-(AVPlayer *)player{
    return self.playerLayer.player;
}
-(void)setPlayer:(AVPlayer *)player{
    self.playerLayer.player = player;
}
-(AVPlayerLayer *)playerLayer{
    return (AVPlayerLayer *)self.layer;
}
-(CGFloat)rate{
    return self.player.rate;
}
-(void)setRate:(CGFloat)rate{
    self.player.rate = rate;
}
-(void)setMode:(KFLayerVideoGravity)mode{
    switch (mode) {
        case KFLayerVideoGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case KFLayerVideoGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case KFLayerVideoGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
    }
}
-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
-(NSString *)title{
    return self.titleLabel.text;
}
//KFRK:实例化
-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        _url = url;
        [self setupPlayerUI];
        [self assetWithURL:url];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPlayerUI];
    }
    return self;
}

-(void)assetWithURL:(NSURL *)url{
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    self.anAsset = [[AVURLAsset alloc]initWithURL:url options:options];
    NSArray *keys = @[@"duration"];
    __weak typeof(self) weakSelf = self;
    [self.anAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [weakSelf.anAsset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!CMTIME_IS_INDEFINITE(weakSelf.anAsset.duration)) {
                        CGFloat second = weakSelf.anAsset.duration.value / weakSelf.anAsset.duration.timescale;
                        weakSelf.controlView.totalTime = [self convertTime:second];
                        weakSelf.controlView.minValue = 0;
                        weakSelf.controlView.maxValue = second;
                    }
                });
            }
                break;
            case AVKeyValueStatusFailed:{
                //NSLog(@"AVKeyValueStatusFailed失败,请检查网络,或查看plist中是否添加App Transport Security Settings");
            }
                break;
            case AVKeyValueStatusCancelled:{
                //                NSLog(@"AVKeyValueStatusCancelled取消");
            }
                break;
            case AVKeyValueStatusUnknown:{
                //                NSLog(@"AVKeyValueStatusUnknown未知");
            }
                break;
            case AVKeyValueStatusLoading:{
                //                NSLog(@"AVKeyValueStatusLoading正在加载");
            }
                break;
        }
    }];
    [self setupPlayerWithAsset:self.anAsset];
    
}
-(instancetype)initWithAsset:(AVURLAsset *)asset{
    self = [super init];
    if (self) {
        [self setupPlayerUI];
        [self setupPlayerWithAsset:asset];
    }
    return self;
}
-(void)setupPlayerWithAsset:(AVURLAsset *)asset{
    self.item = [[AVPlayerItem alloc]initWithAsset:asset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.item];
    [self.playerLayer displayIfNeeded];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self addPeriodicTimeObserver];
    //添加KVO
    [self addKVO];
    //添加消息中心
    [self addNotificationCenter];
}
//FIXME: Tracking time,跟踪时间的改变
-(void)addPeriodicTimeObserver{
    __weak typeof(self) weakSelf = self;
    playbackTimerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.f, 1.f) queue:NULL usingBlock:^(CMTime time) {
        weakSelf.controlView.value = weakSelf.item.currentTime.value/weakSelf.item.currentTime.timescale;
        if (!CMTIME_IS_INDEFINITE(weakSelf.anAsset.duration)) {
            weakSelf.controlView.currentTime = [weakSelf convertTime:weakSelf.controlView.value];
        }
        if (count>=5) {
            [weakSelf setSubViewsIsHide:YES];
        }else{
            [weakSelf setSubViewsIsHide:NO];
        }
        count += 1;
    }];
}
//TODO: KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        
        switch (itemStatus) {
            case AVPlayerItemStatusUnknown: {
                self.status = KFPlayerStatusUnknown;
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                self.status = KFPlayerStatusReadyToPlay;
            }
                break;
            case AVPlayerItemStatusFailed: {
                self.status = KFPlayerStatusFailed;
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        NSArray *loadedTimeRanges = [self.item loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = self.item.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存值
        self.controlView.bufferValue=timeInterval / totalDuration;
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        self.status = KFPlayerStatusBuffering;
        if (!self.activityIndeView.isAnimating) {
            [self.activityIndeView startAnimating];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        [self.activityIndeView stopAnimating];
    } else if ([keyPath isEqualToString:@"rate"]){//当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue]==0) {
            _isPlaying=false;
            self.status = KFPlayerStatusPlaying;
        }else{
            _isPlaying=true;
            self.status = KFPlayerStatusStopped;
        }
    }
}
- (void)setStatus:(KFPlayerStatus)status{
    _status = status;
    if (self.statusChange) {
        self.statusChange(status);
    }
}
//添加KVO
-(void)addKVO{
    //监听状态属性
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络加载情况属性
    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [self.item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [self.item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //监听暂停或者播放中
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}
//KFRK:添加消息中心
-(void)addNotificationCenter{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(KFPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}
//KFRK: NotificationCenter
-(void)KFPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification{
    [self.item seekToTime:kCMTimeZero];
    [self setSubViewsIsHide:NO];
    count = 0;
    [self pause];
    self.pauseOrPlayView.isPlay = NO;
}
-(void)willResignActive:(NSNotification *)notification{
    if (_isPlaying) {
        [self setSubViewsIsHide:NO];
        count = 0;
        [self pause];
        self.pauseOrPlayView.isPlay = NO;
    }
}
//KFRK: 设置界面 在此方法下面可以添加自定义视图，和删除视图
-(void)setupPlayerUI{
    if (_backgroundView) return;
    // 背景
    _backgroundView = [[UIImageView alloc] initWithImage:[KFPreviewController imageNamed:@"kf5_blur"]];
    [self addSubview:_backgroundView];
    // loading
    _activityIndeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndeView.hidesWhenStopped = YES;
    [self addSubview:_activityIndeView];
    [_activityIndeView startAnimating];
    // 标题
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 2;
    [self addSubview:_titleLabel];
    
    //添加播放和暂停按钮
    _pauseOrPlayView = [[KFPauseOrPlayView alloc]init];
    _pauseOrPlayView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weakSelf = self;
    _pauseOrPlayView.clickBlock = ^(BOOL isPlay) {
        count = 0;
        if (isPlay) { [weakSelf play]; }else{  [weakSelf pause]; }
    };
    [self addSubview:_pauseOrPlayView];
    
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTapAction:)];
    longTap.delegate = self;
    [self addGestureRecognizer:longTap];
    [_pauseOrPlayView addGestureRecognizer:longTap];
    
    //添加控制视图
    _controlView = [[KFControlView alloc]init];
    _controlView.delegate = self;
    _controlView.backgroundColor = [UIColor clearColor];
    _controlView.currentTime = @"00:00";
    _controlView.totalTime = @"00:00";
    [self addSubview:_controlView];
    
    [self.backgroundView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self);
        make.right.kf_equalTo(self);
        make.top.kf_equalTo(self);
        make.bottom.kf_equalTo(self);
    }];
    [self.titleLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.left.kf_equalTo(self);
        make.right.kf_equalTo(self);
        make.top.kf_equalTo(self).kf_offset(12);
        make.width.kf_equalTo(self);
    }];
    [self.pauseOrPlayView kf5_makeConstraints:^(KFAutoLayout *make) {
        make.left.kf_equalTo(self);
        make.right.kf_equalTo(self);
        make.top.kf_equalTo(self);
        make.bottom.kf_equalTo(self);
    }];
    [self.controlView kf5_makeConstraints:^(KFAutoLayout *make) {
        make.left.kf_equalTo(self);
        make.right.kf_equalTo(self);
        make.bottom.kf_equalTo(self.kf5_safeAreaLayoutGuideBottom);
        make.height.kf_equal(44);
    }];
    //添加加载视图
    [self.activityIndeView kf5_makeConstraints:^(KFAutoLayout *make) {
        make.width.kf_equal(80);
        make.height.kf_equal(80);
        make.centerX.kf_equalTo(self);
        make.centerY.kf_equalTo(self);
    }];
    
    [self layoutIfNeeded];
}
// 因为在UICollectionView的cell中,cell的横屏下iphonex的safeAreaInsets是{0,0,0,20}而不是{0,44,44,20}
// 所以需要借助UIApplication的keyWindow的safeAreaInsets
- (void)safeAreaInsetsDidChange{
    [self.controlView kf5_remakeConstraints:^(KFAutoLayout *make) {
        UIEdgeInsets insets = [UIApplication sharedApplication].keyWindow.kf5_safeAreaInsets;
        make.left.kf_equalTo(self).kf_offset(insets.left);
        make.right.kf_equalTo(self).kf_offset(-insets.right);
        make.bottom.kf_equalTo(self.kf5_safeAreaLayoutGuideBottom);
        make.height.kf_equal(44);
    }];
}

-(void)handleTapAction:(UITapGestureRecognizer *)gesture{
    [self setSubViewsIsHide:NO];
    count = 0;
}

- (void)handleLongTapAction:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan && self.longTapBlock) {
        self.longTapBlock();
    }
}

//设置子视图是否隐藏
-(void)setSubViewsIsHide:(BOOL)isHide{
    self.controlView.hidden = isHide;
    self.pauseOrPlayView.hidden = isHide;
    self.titleLabel.hidden = isHide;
    self.backgroundView.hidden = isHide;
}
#pragma mark - 重新开始播放
- (void)resetPlay{
    [self.item seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    count = 0;
    [self play];
    self.pauseOrPlayView.isPlay = YES;
}

//KFRK: KFControlViewDelegate
-(void)controlView:(KFControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value{
    count = 0;
    CMTime pointTime = CMTimeMake(value * self.item.currentTime.timescale, self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
-(void)controlView:(KFControlView *)controlView draggedPositionWithSlider:(UISlider *)slider{
    count = 0;
    CMTime pointTime = CMTimeMake(controlView.value * self.item.currentTime.timescale, self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
-(void)controlView:(KFControlView *)controlView withLargeButton:(UIButton *)button{
    if (self.largeTapBlock) {
        self.largeTapBlock();
    }else{
        if (self.frame.size.width<self.frame.size.height) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }else{
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
    }
}
//KFRK: UIGestureRecognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[KFControlView class]]) {
        return NO;
    }
    return YES;
}
//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
//旋转方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    if ( [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)play{
    if (self.player) {
        [self.player play];
    }
}
-(void)pause{
    if (self.player) {
        [self.player pause];
    }
}
-(void)stop{
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:playbackTimerObserver];
    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    if (self.player) {
        [self pause];
        self.anAsset = nil;
        self.item = nil;
        self.controlView.value = 0;
        self.controlView.currentTime = @"00:00";
        self.controlView.totalTime = @"00:00";
        self.player = nil;
        self.activityIndeView = nil;
        [self removeFromSuperview];
    }
}

- (void)dealloc{
    [self stop];
}

@end


#pragma mark - KFControlView
@interface KFControlView ()
//当前时间
@property (nonatomic,strong) UILabel *timeLabel;
//总时间
@property (nonatomic,strong) UILabel *totalTimeLabel;
//进度条
@property (nonatomic,strong) UISlider *slider;
//缓存进度条
@property (nonatomic,strong) UISlider *bufferSlier;
@end
static NSInteger padding = 8;
@implementation KFControlView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_timeLabel];
        
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_totalTimeLabel];
        
        _bufferSlier = [[UISlider alloc]init];
        [_bufferSlier setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferSlier.continuous = YES;
        _bufferSlier.minimumTrackTintColor = [UIColor redColor];
        _bufferSlier.minimumValue = 0.f;
        _bufferSlier.maximumValue = 1.f;
        _bufferSlier.userInteractionEnabled = NO;
        [self addSubview:_bufferSlier];
        
        _slider = [[SZSlider alloc]init];
        _slider.continuous = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [_slider addTarget:self action:@selector(handleSliderPosition:) forControlEvents:UIControlEventValueChanged];
        [_slider addGestureRecognizer:self.tapGesture];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        [self addSubview:_slider];
        
        _largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _largeButton.contentMode = UIViewContentModeScaleToFill;
        [_largeButton setImage:[KFPreviewController imageNamed:@"kf5_landscape"] forState:UIControlStateNormal];
        [_largeButton addTarget:self action:@selector(hanleLargeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_largeButton];
        
        //添加约束
        [self.timeLabel kf5_makeConstraints:^(KFAutoLayout *make) {
            make.left.kf_equalTo(self.kf5_left).kf_offset(padding).priority(UILayoutPriorityDefaultHigh);
            make.centerY.kf_equalTo(self);
        }];
        [self.slider kf5_makeConstraints:^(KFAutoLayout *make) {
            make.left.kf_equalTo(self.timeLabel.kf5_right).kf_offset(padding).priority(UILayoutPriorityDefaultHigh);
            make.centerY.kf_equalTo(self.timeLabel);
        }];
        [self.totalTimeLabel kf5_makeConstraints:^(KFAutoLayout *make) {
            make.left.kf_equalTo(self.slider.kf5_right).kf_offset(padding).priority(UILayoutPriorityDefaultHigh);
            make.centerY.kf_equalTo(self.slider);
            make.right.kf_greaterThanOrEqualTo(self.kf5_right).kf_offset(-padding).priority(UILayoutPriorityDefaultLow);
        }];
        [self.largeButton kf5_makeConstraints:^(KFAutoLayout *make) {
            make.left.kf_equalTo(self.totalTimeLabel.kf5_right).kf_offset(padding).priority(UILayoutPriorityDefaultHigh);
            make.right.kf_equalTo(self.kf5_right).kf_offset(-padding);
            make.centerY.kf_equalTo(self.totalTimeLabel);
        }];
        [self.bufferSlier kf5_makeConstraints:^(KFAutoLayout *make) {
            make.top.kf_equalTo(self.slider);
            make.left.kf_equalTo(self.slider);
            make.right.kf_equalTo(self.slider);
            make.bottom.kf_equalTo(self.slider);
        }];
    }
    return self;
}

-(void)hanleLargeBtn:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(controlView:withLargeButton:)]) {
        [self.delegate controlView:self withLargeButton:button];
    }
}

-(void)handleSliderPosition:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlView:draggedPositionWithSlider:)]) {
        [self.delegate controlView:self draggedPositionWithSlider:self.slider];
    }
}

-(void)handleTap:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.slider];
    CGFloat pointX = point.x;
    CGFloat sliderWidth = self.slider.frame.size.width;
    CGFloat currentValue = pointX/sliderWidth * self.slider.maximumValue;
    if ([self.delegate respondsToSelector:@selector(controlView:pointSliderLocationWithCurrentValue:)]) {
        [self.delegate controlView:self pointSliderLocationWithCurrentValue:currentValue];
    }
}

//setter 和 getter方法
-(void)setValue:(CGFloat)value{
    self.slider.value = value;
}
-(CGFloat)value{
    return self.slider.value;
}
-(void)setMinValue:(CGFloat)minValue{
    self.slider.minimumValue = minValue;
}
-(CGFloat)minValue{
    return self.slider.minimumValue;
}
-(void)setMaxValue:(CGFloat)maxValue{
    self.slider.maximumValue = maxValue;
}
-(CGFloat)maxValue{
    return self.slider.maximumValue;
}
-(void)setCurrentTime:(NSString *)currentTime{
    self.timeLabel.text = currentTime;
}
-(NSString *)currentTime{
    return self.timeLabel.text;
}
-(void)setTotalTime:(NSString *)totalTime{
    self.totalTimeLabel.text = totalTime;
}
-(NSString *)totalTime{
    return self.totalTimeLabel.text;
}
-(CGFloat)bufferValue{
    return self.bufferSlier.value;
}
-(void)setBufferValue:(CGFloat)bufferValue{
    self.bufferSlier.value = bufferValue;
}

@end

#pragma mark - KFPauseOrPlayView
@implementation KFPauseOrPlayView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageBtn addTarget:self action:@selector(handleImageTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageBtn];
        self.imageBtn = imageBtn;
        [imageBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.top.kf_equalTo(self);
            make.left.kf_equalTo(self);
            make.right.kf_equalTo(self);
            make.bottom.kf_equalTo(self);
        }];
        self.isPlay = NO;
    }
    return self;
}

- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    [self.imageBtn setImage:[KFPreviewController imageNamed:isPlay ? @"kf5_pause" : @"kf5_play"] forState:UIControlStateNormal];
}

-(void)handleImageTapAction:(UIButton *)button{
    self.isPlay = !self.isPlay;
    if (self.clickBlock) {
        self.clickBlock(self.isPlay);
    }
}

@end


#pragma mark - SZSlider

#define SLIDER_X_BOUND 30
#define SLIDER_Y_BOUND 40

@interface SZSlider ()
/**lastBounds*/
@property (nonatomic,assign) CGRect lastBounds;
@end
@implementation SZSlider


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setThumbImage:[KFPreviewController imageNamed:@"kf5_knob"] forState:UIControlStateHighlighted];
        [self setThumbImage:[KFPreviewController imageNamed:@"kf5_knob_pre"] forState:UIControlStateNormal];
    }
    return self;
}

//修改滑块位置
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    //    rect.origin.x   = rect.origin.x - 6 ;
    //    rect.size.width = rect.size.width + 12;
    CGRect result   = [super thumbRectForBounds:bounds trackRect:rect value:value];
    //记录下最终的frame
    _lastBounds     = result;
    return result;
}
//检查点击事件点击范围是否能够交给self处理
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //调用父类方法,找到能够处理event的view
    UIView* result = [super hitTest:point withEvent:event];
    if (result != self) {
        /*如果这个view不是self,我们给slider扩充一下响应范围,
         这里的扩充范围数据就可以自己设置了
         */
        if ((point.y >= -15) &&
            (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND)) &&
            (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            //如果在扩充的范围类,就将event的处理权交给self
            result = self;
        }
    }
    //否则,返回能够处理的view
    return result;
}
//检查是点击事件的点是否在slider范围内
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    //调用父类判断
    BOOL result = [super pointInside:point withEvent:event];
    if (!result) {
        //同理,如果不在slider范围类,扩充响应范围
        if ((point.x >= (_lastBounds.origin.x - SLIDER_X_BOUND)) && (point.x <= (_lastBounds.origin.x + _lastBounds.size.width + SLIDER_X_BOUND))
            && (point.y >= -SLIDER_Y_BOUND) && (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND))) {
            //在扩充范围内,返回yes
            result = YES;
        }
    }
    //否则返回父类的结果
    return result;
}

@end
