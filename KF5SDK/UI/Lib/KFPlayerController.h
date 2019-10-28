//
//  KFPlayerViewController.h
//  KFAutoLayout
//
//  Created by admin on 12/5/18.
//

#import "KFBaseViewController.h"
#import <AVFoundation/AVFoundation.h>
@class KFPlayerView;

typedef NS_ENUM(NSInteger,kLargeType) {
    kLargeTypeHidden = 0,// 隐藏全屏按钮
    kLargeTypeView,         // view旋转
    kLargeTypeSystem     // app支持旋转
};

@class KFPreviewModel;

@interface KFPlayerController : KFBaseViewController

@property (nonatomic, strong) KFPreviewModel *model;
@property (nonatomic, weak) KFPlayerView *playView;
@property (nonatomic, copy) void (^closeGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(KFPreviewModel *model);

- (void)assetWithModel:(KFPreviewModel *)model;

+ (void)setSupportLandscape:(BOOL)supportLandscape;

@end

//横竖屏的时候过渡动画时间，设置为0.0则是无动画
#define kTransitionTime 0.2
//填充模式枚举值
typedef NS_ENUM(NSInteger,KFLayerVideoGravity){
    KFLayerVideoGravityResizeAspect,
    KFLayerVideoGravityResizeAspectFill,
    KFLayerVideoGravityResize,
};
//播放状态枚举值
typedef NS_ENUM(NSInteger,KFPlayerStatus){
    KFPlayerStatusFailed,
    KFPlayerStatusReadyToPlay,
    KFPlayerStatusUnknown,
    KFPlayerStatusBuffering,
    KFPlayerStatusPlaying,
    KFPlayerStatusStopped,
};
@class KFControlView;
@class KFPauseOrPlayView;

@interface KFPlayerView : UIView{
    id playbackTimerObserver;
}

@property (nonatomic,strong,readonly) AVPlayerLayer *playerLayer;
//当前播放url
@property (nonatomic,strong) NSURL *url;
//底部控制视图
@property (nonatomic,strong) KFControlView *controlView;
//暂停和播放视图
@property (nonatomic,strong) KFPauseOrPlayView *pauseOrPlayView;
//添加标题
@property (nonatomic,strong) UILabel *titleLabel;
//加载动画
@property (nonatomic,strong) UIActivityIndicatorView *activityIndeView;
// 背景
@property (nonatomic, strong) UIImageView *backgroundView;

//AVPlayer
@property (nonatomic,strong) AVPlayer *player;
//AVPlayer的播放item
@property (nonatomic,strong) AVPlayerItem *item;
//总时长
@property (nonatomic,assign) CMTime totalTime;
//当前时间
@property (nonatomic,assign) CMTime currentTime;
//资产AVURLAsset
@property (nonatomic,strong) AVURLAsset *anAsset;
//播放器Playback Rate
@property (nonatomic,assign) CGFloat rate;
//播放状态
@property (nonatomic,assign,readonly) KFPlayerStatus status;
//videoGravity设置屏幕填充模式，（只写）
@property (nonatomic,assign) KFLayerVideoGravity mode;
//是否正在播放
@property (nonatomic,assign,readonly) BOOL isPlaying;
//设置标题
@property (nonatomic,copy) NSString *title;
//长按事件
@property (nonatomic, copy) void (^longTapBlock)(void);
//全屏事件
@property (nonatomic, copy) void (^largeTapBlock)(void);
//   状态变化
@property (nonatomic, copy) void (^statusChange)(KFPlayerStatus status);

//与url初始化
-(instancetype)initWithUrl:(NSURL *)url;
//将播放url放入资产中初始化播放器
-(void)assetWithURL:(NSURL *)url;
//公用同一个资产请使用此方法初始化
-(instancetype)initWithAsset:(AVURLAsset *)asset;
//播放
-(void)play;
//暂停
-(void)pause;
//停止 （移除当前视频播放下一个或者销毁视频，需调用Stop方法）
-(void)stop;
- (void)resetPlay;

@end


#pragma mark Other

@interface SZSlider : UISlider
@end

@interface KFPauseOrPlayView : UIView
@property (nonatomic, copy) void(^clickBlock)(BOOL isPlay);
@property (nonatomic,assign) BOOL isPlay;
@property (nonatomic,weak) UIButton *imageBtn;
@end


@class KFControlView;
@protocol KFControlViewDelegate <NSObject>
@required
/**
 点击UISlider获取点击点
 
 @param controlView 控制视图
 @param value 当前点击点
 */
-(void)controlView:(KFControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value;

/**
 拖拽UISlider的knob的时间响应代理方法
 
 @param controlView 控制视图
 @param slider UISlider
 */
-(void)controlView:(KFControlView *)controlView draggedPositionWithSlider:(UISlider *)slider ;

/**
 点击放大按钮的响应事件
 
 @param controlView 控制视图
 @param button 全屏按钮
 */
-(void)controlView:(KFControlView *)controlView withLargeButton:(UIButton *)button;
@end


@interface KFControlView : UIView
//全屏按钮
@property (nonatomic,strong) UIButton *largeButton;
//进度条当前值
@property (nonatomic,assign) CGFloat value;
//最小值
@property (nonatomic,assign) CGFloat minValue;
//最大值
@property (nonatomic,assign) CGFloat maxValue;
//当前时间
@property (nonatomic,copy) NSString *currentTime;
//总时间
@property (nonatomic,copy) NSString *totalTime;
//缓存条当前值
@property (nonatomic,assign) CGFloat bufferValue;
//UISlider手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
//代理方法
@property (nonatomic,weak) id<KFControlViewDelegate> delegate;

@end
