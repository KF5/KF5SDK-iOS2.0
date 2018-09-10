//
//  KFHelper.h
//  Pods
//
//  Created by admin on 16/10/11.
//
//

#import <UIKit/UIKit.h>

@interface KFHelper : NSObject

+ (nonnull instancetype)shareHelper;

@property (nullable, nonatomic, strong) UIImage *chat_ctnMeBg;
@property (nullable, nonatomic, strong) UIImage *chat_ctnMeBgH;
@property (nullable, nonatomic, strong) UIImage *chat_ctnOtherBg;
@property (nullable, nonatomic, strong) UIImage *chat_ctnOtherBgH;

@property (nullable, nonatomic, strong) UIImage *chat_faceDelete;
@property (nullable, nonatomic, strong) UIImage *chatTool_face;
@property (nullable, nonatomic, strong) UIImage *chatTool_keyBoard;
@property (nullable, nonatomic, strong) UIImage *chatTool_picture;
@property (nullable, nonatomic, strong) UIImage *chatTool_voice;

@property (nullable, nonatomic, strong) UIImage *chat_record_cancel;
@property (nullable, nonatomic, strong) NSArray <UIImage *>*chat_records;
@property (nullable, nonatomic, strong) NSArray <UIImage *>*chat_meWaves;
@property (nullable, nonatomic, strong) NSArray <UIImage *>*chat_otherWaves;


@property (nullable, nonatomic, strong) UIImage *failedImage;
@property (nullable, nonatomic, strong) UIImage *agentImage;
@property (nullable, nonatomic, strong) UIImage *endUserImage;
@property (nullable, nonatomic, strong) UIImage *hudErrorImage;

@property (nullable, nonatomic, strong) UIImage *placeholderImage;
@property (nullable, nonatomic, strong) UIImage *placeholderImageFailed;
@property (nullable, nonatomic, strong) UIImage *placeholderOther;


@property (nullable, nonatomic, strong) UIImage *ticketTool_addAtt;
@property (nullable, nonatomic, strong) UIImage *ticketTool_closeAtt;
@property (nullable, nonatomic, strong) UIImage *ticketTool_openAtt;

@property (nullable, nonatomic, strong) UIImage *ticket_createAtt;


@property (nonnull, nonatomic, strong) UIColor *KF5TitleColor;
@property (nonnull, nonatomic, strong) UIColor *KF5NameColor;
@property (nonnull, nonatomic, strong) UIColor *KF5TimeColor;
@property (nonnull, nonatomic, strong) UIColor *KF5BgColor;
@property (nonnull, nonatomic, strong) UIColor *KF5MeURLColor;
@property (nonnull, nonatomic, strong) UIColor *KF5OtherURLColor;

@property (nonnull, nonatomic, strong) UIColor *KF5SatifiedColor;

@property (nonnull, nonatomic, strong) UIColor *KF5BlueColor;

@property (nonnull, nonatomic, strong) UIColor *KF5PlaceHolderBgColor;

@property (nonnull, nonatomic, strong) UIFont *KF5TitleFont;
@property (nonnull, nonatomic, strong) UIFont *KF5ContentFont;
@property (nonnull, nonatomic, strong) UIFont *KF5NameFont;
@property (nonnull, nonatomic, strong) UIFont *KF5TimeFont;

@property (nonatomic, assign) CGFloat KF5DefaultSpacing;
@property (nonatomic, assign) CGFloat KF5VerticalSpacing;
@property (nonatomic, assign) CGFloat KF5HorizSpacing;
@property (nonatomic, assign) CGFloat KF5MiddleSpacing;
@property (nonatomic, assign) CGFloat KF5ChatToolTextViewTopSpacing;
@property (nonatomic, assign) CGFloat KF5ChatCellHeaderHeight;
@property (nonatomic, assign) CGFloat KF5ChatCellMessageBtnInsterTopBottom;
@property (nonatomic, assign) CGFloat KF5ChatCellMessageBtnArrowWidth;
@property (nonatomic, assign) CGFloat KF5ChatCellMessageBtnInsterLeftRight;

#pragma mark - 工单列表
@property (nonnull, nonatomic, strong) UIColor *KF5TicketPointColor;
@property (nonatomic, assign) CGFloat KF5TicketPointViewWitdh;
#pragma mark - 创建工单界面
@property (nonnull, nonatomic, strong) UIColor *KF5CreateTicketPlaceholderTextColor;


#pragma mark - 聊天界面
@property (nonnull, nonatomic, strong) UIFont *KF5ChatTextFont;

@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolViewBackgroundColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolViewLineColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolPlaceholderTextColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolTextViewBorderColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolTextViewBackgroundColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolViewSpeakBtnTitleColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatToolViewSpeakBtnTitleColorH;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatFaceViewPageControlSelectColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatFaceViewPageControlNormalColor;

#pragma mark - 聊天cell
@property (nonnull, nonatomic, strong) UIColor *KF5ChatSystemCellTimeLabelBackgroundColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatTextCellMeLabelUrlColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatTextCellOtherLabelUrlColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatTextCellMeLabelTextColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatTextCellOtherLabelTextColor;

#pragma mark 卡片cell
@property (nonnull, nonatomic, strong) UIColor *KF5ChatCardCellTitleLabelTextColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatCardCellPriceLabelTextColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatCardCellLinkBtnTextColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatCardCellLinkBtnBackgroundColor;
@property (nonnull, nonatomic, strong) UIColor *KF5ChatCardCellBackgroundColor;

+ (CGSize)mainSize;
+ (CGRect)safe_mainFrame;

#pragma mark - NSObject
+ (nullable NSString *)JSONStringWithObject:(nonnull id)object;
+ (nullable NSDictionary *)dictWithJSONString:(nonnull NSString *)JSONString;
+ (nonnull NSString *)md5HexDigest:(nonnull NSString *)input;

#pragma mark - NSBundle
+ (nonnull NSBundle *)shareBundle;
///如果想使用系统语言,请设置本地语言为nil
+ (void)setLocalLanguage:(nullable NSString *)localLanguage;
+ (nullable NSString *)localLanguage;
+ (nullable NSString *)localizedStringForKey:(nonnull NSString *)key value:(nullable NSString *)value;
+ (nullable NSString *)localizedStringForKey:(nonnull NSString *)key;

#pragma mark - Alert
+ (UIAlertController *_Nonnull)alertWithTitle:(NSString *_Nullable)title message:(NSString *_Nullable)message;
+ (UIAlertController *_Nonnull)alertWithMessage:(NSString *_Nullable)message confirmHandler:(void (^ __nullable)(UIAlertAction *_Nonnull action))handler;
+ (UIAlertController *_Nonnull)alertWithMessage:(NSString *_Nullable)message;

+ (UIViewController *_Nonnull)imagePickerControllerWithMaxCount:(NSInteger)maxCount selectedAssets:(NSArray *_Nullable)selectedAssets didFinishedHandle:(void (^)(NSArray <UIImage *>*photos, NSArray *assets))didFinishedHandle;

#pragma mark - helper
+ (BOOL)isNetworkEnable;

+ (BOOL)canRecordVoice;

+ (nullable NSString *)disable_emoji:(nonnull NSString *)text;
+ (nonnull UILabel *)labelWithFont:(nonnull UIFont *)font textColor:(nullable UIColor *)textColor;
///单行计算尺寸
+ (CGSize)sizeWithText:(nonnull NSString *)text font:(nonnull UIFont *)font;
///多行计算尺寸
+ (CGSize)sizeWithText:(nonnull NSString *)text font:(nonnull UIFont *)font maxSize:(CGSize)maxSize;

@end

@interface UIAlertController(KF5)
- (void)showToVC:(UIViewController *_Nullable)vc;
@end


#ifndef KFHelper_h
#define KFHelper_h

#define KF_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))

// 国际化
#define KF5Localized(string)  [KFHelper localizedStringForKey:string]
// KF5SDK.bundle文件路径
#define KF5SrcName(file) [[KFHelper shareBundle].bundlePath stringByAppendingPathComponent:file]
// iOS版本号
#define KF5SystemVersion  [[[UIDevice currentDevice] systemVersion] doubleValue]

#define KF5Helper   [KFHelper shareHelper]

/**横屏*/
#define KF5ViewLandscape UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

/** 竖屏*/
#define KF5ViewVertical UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)

static NSString * _Nonnull const KF5SDKBundle            = @"KF5SDK.bundle";
static NSString * _Nonnull const KF5SDKFrameworkBundle   = @"Frameworks/KF5SDK.framework/KF5SDK.bundle";
static NSString * _Nonnull const KF5LocalLanguage        = @"KF5LocalLanguage";

static NSString * _Nonnull const KF5LinkTitle           = @"KF5LinkTitle";//title
static NSString * _Nonnull const KF5LinkType            = @"KF5LinkType";//类型
static NSString * _Nonnull const KF5LinkKey             = @"KF5LinkKey";//key
static NSString * _Nonnull const KF5LinkURL             = @"KF5LinkURL";//url

#pragma mark - ViewTag
static const NSInteger kKF5ChatToolViewTag              = 1000011;
static const NSInteger kKF5TicketToolViewTag            = 1000022;
static const NSInteger kKF5RecordViewTag                = 1000044;

#pragma mark - 通知
static NSString * _Nonnull const KKF5NoteNeedLoadTicketListData      = @"KKF5NoteNeedLoadTicketListData";
static NSString * _Nonnull const KKF5NoteCallPhone                   = @"kKF5NoteCallPhone";//打电话通知
static NSString * _Nonnull const KKF5NoteTransferAgent      = @"KKF5NoteTransferAgent"; //转接客服通知
static NSString * _Nonnull const KKF5NoteLeaveMessage      = @"KKF5NoteLeaveMessage";   //排队中留言

#pragma mark - 存储
static NSString * _Nonnull const kKF5UserDefaultUserMessage  = @"kKF5UserDefaultUserMessage";//用户信息

#endif
