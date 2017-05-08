//
//  KFMessageModel.h
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import <UIKit/UIKit.h>

#import "KFHelper.h"
#import "YYTextLayout.h"

@interface KFMessageModel : NSObject

@property (nonnull, nonatomic, strong) KFMessage *message;

/**时间text*/
@property (nullable, nonatomic, copy) NSString *timeText;
/**头像*/
@property (nullable, nonatomic, strong) UIImage *headerImage;
/**内容背景*/
@property (nullable, nonatomic, strong) UIImage *messageViewBgImage;
/**内容背景高亮*/
@property (nullable, nonatomic, strong) UIImage *messageViewBgImageH;


/**内容*/
@property (nullable, nonatomic, strong) YYTextLayout *textLayout;
/**图片*/
@property (nullable, nonatomic, strong) UIImage *image;
/**语音*/
@property (nullable, nonatomic, strong) NSData *voiceData;
/**音频长度*/
@property (nonatomic, assign) CGFloat voiceLength;
///是否正在播放
@property (nonatomic, assign) BOOL isPlaying;
///是否显示时间
@property (nonatomic, assign,getter=isShowTime) BOOL showTime;
/**时间的frame*/
@property (nonatomic, assign) CGRect timeFrame;
/**头像的frame*/
@property (nonatomic, assign) CGRect headerFrame;
/**内容背景的frame*/
@property (nonatomic, assign) CGRect messageBgViewFrame;
/**内容的frame,可能是文字,图片,语音*/
@property (nonatomic, assign) CGRect messageViewFrame;
/**loadView的frame*/
@property (nonatomic, assign) CGRect loadViewFrame;


/**系统消息的frame*/
@property (nonatomic, assign) CGRect systemFrame;
/**系统消息背景的frame*/
@property (nonatomic, assign) CGRect systemBackgroundFrame;
/**系统消息文本*/
@property (nullable, nonatomic, strong) YYTextLayout *systemTextLayout;



/**cell高度*/
@property (nonatomic, assign) CGFloat cellHeight;

/**
 初始化messageModel
 */
- (nonnull instancetype)initWithMessage:(nonnull KFMessage *)message;

/**重置frame*/
- (void)updateFrame;

@end
