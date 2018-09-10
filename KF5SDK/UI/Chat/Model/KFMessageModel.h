//
//  KFMessageModel.h
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import <UIKit/UIKit.h>
@class KFMessage;

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
@property (nullable, nonatomic, strong) NSMutableAttributedString *text;
/**图片*/
@property (nullable, nonatomic, strong) UIImage *image;
/**语音*/
@property (nullable, nonatomic, strong) NSData *voiceData;
/**音频长度*/
@property (nonatomic, assign) CGFloat voiceLength;
/**是否显示时间*/
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
@property (nullable, nonatomic, strong) NSMutableAttributedString *systemText;

/**卡片消息的frame*/
@property (nonatomic, assign) CGRect cardImageFrame;
/**卡片消息标题的frame*/
@property (nonatomic, assign) CGRect cardTitleFrame;
/**卡片消息价格的frame*/
@property (nonatomic, assign) CGRect cardPriceFrame;
/**卡片消息按钮的frame*/
@property (nonatomic, assign) CGRect cardLinkBtnFrame;
/**卡片消息需要的数据*/
@property (nullable, nonatomic, strong) NSDictionary *cardDict;

/**cell高度*/
@property (nonatomic, assign) CGFloat cellHeight;

/**
 初始化messageModel
 */
- (nonnull instancetype)initWithMessage:(nonnull KFMessage *)message;

/**重置frame*/
- (void)updateFrame;

@end
