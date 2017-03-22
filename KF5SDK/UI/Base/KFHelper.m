//
//  KFHelper.m
//  Pods
//
//  Created by admin on 16/10/11.
//
//

// 获得RGB颜色
#define KF5Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
// 获取ARGB十六进制颜色
#define KF5ColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define  KF5LazyImage(property,imageName) \
- (UIImage *)property{\
if (!_##property) {\
    _##property = [UIImage kf5_imageWithBundleImageName:imageName];\
}\
return _##property;\
}

#define  KF5LazyImageResize(property,imageName) \
- (UIImage *)property{\
if (!_##property) {\
_##property = [[UIImage kf5_imageWithBundleImageName:imageName]kf5_imageResize];\
}\
return _##property;\
}

#import "KFHelper.h"
#import "AFNetworkReachabilityManager.h"
#import <CommonCrypto/CommonDigest.h>

static NSString * _Nonnull const kKF5UserDefaultHasChatQueueMessage  = @"kKF5UserDefaultHasChatQueueMessage";//排队时用户发送的消息

@implementation KFHelper

+ (AFNetworkReachabilityManager *)reachabilityManager{
    static AFNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [AFNetworkReachabilityManager manager];
    });
    return _sharedManager;
}

+ (void)load{
    [[self reachabilityManager]startMonitoring];
}

+ (instancetype)shareHelper{
    static KFHelper *share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!share) {
            share = [[super alloc] init];
            [share setup];
        }
    });
    return share;
}

KF5LazyImageResize(chat_ctnMeBg, @"kf5_chat_contentMeBg");
KF5LazyImageResize(chat_ctnMeBgH, @"kf5_chat_contentMeBg_pre");
KF5LazyImageResize(chat_ctnOtherBg, @"kf5_chat_contentOtherBg");
KF5LazyImageResize(chat_ctnOtherBgH, @"kf5_chat_contentOtherBg_pre");

KF5LazyImage(chat_faceDelete, @"kf5_chat_face_delete");
KF5LazyImage(chatTool_face, @"kf5_chat_face");
KF5LazyImage(chatTool_keyBoard, @"kf5_chat_keyBoard");
KF5LazyImage(chatTool_picture, @"kf5_chat_picture");
KF5LazyImage(chatTool_voice, @"kf5_chat_voice");

KF5LazyImage(failedImage, @"kf5_failed");
KF5LazyImage(agentImage, @"kf5_header_agent");
KF5LazyImage(endUserImage, @"kf5_header_endUser");
KF5LazyImage(hudErrorImage, @"kf5_hud_error");

KF5LazyImage(placeholderImage, @"kf5_placeholder_image");
KF5LazyImage(placeholderImageFailed, @"kf5_placeholder_image_failed");
KF5LazyImage(placeholderOther, @"kf5_placeholder_other");
KF5LazyImage(ticketTool_addAtt, @"kf5_ticket_addatt");
KF5LazyImage(ticketTool_closeAtt, @"kf5_ticket_closeatt");
KF5LazyImage(ticketTool_openAtt, @"kf5_ticket_attBtn");

KF5LazyImage(ticket_createAtt, @"kf5_ticket_create_att");


- (NSArray<UIImage *> *)chat_records{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:14];
    for (int i = 0; i < 14; i++) {
        UIImage *image = [UIImage kf5_imageWithBundleImageName:[NSString stringWithFormat:@"kf5_chat_record_%02d",(i+1)]];
        if (image) [array addObject:image];
    }
    return array;
}

- (NSArray<UIImage *> *)chat_meWaves{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        UIImage *image = [[[UIImage kf5_imageWithBundleImageName:[NSString stringWithFormat:@"kf5_chat_wave_%d",i]]kf5_imageWithOverlayColor:self.KF5ChatTextCellMeLabelTextColor]kf5_rotationimageWithRotate:M_PI];
        if (image) [array addObject:image];
    }
    return array;
}
- (NSArray<UIImage *> *)chat_otherWaves{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        UIImage *image = [[UIImage kf5_imageWithBundleImageName:[NSString stringWithFormat:@"kf5_chat_wave_%d",i]]kf5_imageWithOverlayColor:self.KF5ChatTextCellOtherLabelTextColor];
        if (image) [array addObject:image];
    }
    return array;
}

- (void)setup{
    
    self.KF5TitleColor = KF5ColorFromRGB(0x424345);
    self.KF5NameColor = KF5ColorFromRGB(0xa0a0a0);
    self.KF5TimeColor = KF5ColorFromRGB(0x888888);
    self.KF5BgColor = KF5ColorFromRGB(0xf7f7f8);
    self.KF5MeURLColor = KF5ColorFromRGB(0xb7ebff);
    self.KF5OtherURLColor = KF5ColorFromRGB(0x64cbf4);
    
    self.KF5SatifiedColor = KF5ColorFromRGB(0xF5A613);
    self.KF5BlueColor = KF5ColorFromRGB(0x1da4ec);
    
    self.KF5PlaceHolderBgColor = KF5ColorFromRGB(0xefeff4);
    
    self.KF5TitleFont = [UIFont systemFontOfSize:16];
    self.KF5NameFont = [UIFont systemFontOfSize:13];
    self.KF5TimeFont = [UIFont systemFontOfSize:12];
    
    self.KF5DefaultSpacing = 10;
    self.KF5VerticalSpacing = 20;
    self.KF5HorizSpacing = 20;
    self.KF5MiddleSpacing = 15;
    self.KF5ChatToolTextViewTopSpacing = 8;
    self.KF5ChatCellHeaderHeight = 40;
    self.KF5ChatCellMessageBtnInsterTopBottom = 14;
    self.KF5ChatCellMessageBtnArrowWidth = 8;
    self.KF5ChatCellMessageBtnInsterLeftRight = 14;
    
    // 工单列表界面
    self.KF5TicketPointColor = KF5ColorFromRGB(0xff441f);
    self.KF5TicketPointViewWitdh = 8;
    
    // 创建工单界面
    self.KF5CreateTicketPlaceholderTextColor = KF5ColorFromRGB(0x6c6c6c);
    
    // 聊天界面
    self.KF5ChatTextFont = [UIFont systemFontOfSize:17];
    
    self.KF5ChatToolViewBackgroundColor = KF5ColorFromRGB(0xf7f7f8);
    self.KF5ChatToolViewLineColor = KF5ColorFromRGB(0xcccccc);
    self.KF5ChatToolPlaceholderTextColor = [UIColor colorWithWhite:0.8 alpha:1];
    self.KF5ChatToolTextViewBorderColor = KF5ColorFromRGB(0xc8c8cd);
    self.KF5ChatToolTextViewBackgroundColor = KF5ColorFromRGB(0xfafafa);
    self.KF5ChatToolViewSpeakBtnTitleColor = KF5ColorFromRGB(0x434343);
    self.KF5ChatToolViewSpeakBtnTitleColorH = KF5ColorFromRGB(0xcecece);
    self.KF5ChatFaceViewPageControlSelectColor = KF5ColorFromRGB(0x8b8b8b);
    self.KF5ChatFaceViewPageControlNormalColor = KF5ColorFromRGB(0xbbbbbb);
    
    self.KF5ChatSystemCellTimeLabelBackgroundColor = KF5ColorFromRGB(0xcecece);
    self.KF5ChatTextCellMeLabelUrlColor = KF5ColorFromRGB(0xb7ebff);
    self.KF5ChatTextCellMeLabelTextColor = [UIColor whiteColor];
    self.KF5ChatTextCellOtherLabelUrlColor = KF5ColorFromRGB(0x64cbf4);
    self.KF5ChatTextCellOtherLabelTextColor = [UIColor blackColor];
}

#pragma mark - NSObject
+ (NSString *)JSONStringWithObject:(id)object{
    if (object != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
        if(jsonData){
            NSString *jsonCustomField = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return jsonCustomField;
        }
    }
    return nil;
}
+ (NSDictionary *)dictWithJSONString:(NSString *)JSONString{
    if (JSONString == nil)return nil;
    
    NSData *jsonData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:kNilOptions
                                                          error:NULL];
    
    if (![dic isKindOfClass:[NSDictionary class]]) return nil;
    
    return dic;
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

#pragma mark - NSBundle
+ (NSBundle *)shareBundle{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:KF5SDKBundle ofType:nil];
        if (!path) {
            path = [[NSBundle mainBundle]pathForResource:KF5SDKFrameworkBundle ofType:nil];
        }
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}

+ (void)setLocalLanguage:(NSString *)localLanguage{
    if (localLanguage.length == 0) return;
    
    if (![[self localLanguage] isEqualToString:localLanguage]) {
        [[NSUserDefaults standardUserDefaults]setObject:localLanguage forKey:KF5LocalLanguage];
        [[NSUserDefaults standardUserDefaults]synchronize];
        bundle = nil;
    }
}
+ (NSString *)localLanguage{
    return [[NSUserDefaults standardUserDefaults]objectForKey:KF5LocalLanguage];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    return [self localizedStringForKey:key value:@""];
}

static NSBundle *bundle = nil;
+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value {
    
    if (bundle == nil) {
        // 如果本地存储的语言为nil,则使用系统语言
        NSString *language = [self localLanguage]?:[NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[KFHelper shareBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

#pragma mark - helper
+ (BOOL)isNetworkEnable{
    BOOL isNetwork = [[KFHelper reachabilityManager] isReachable];
    return isNetwork;
}

+ (BOOL)validateEmail:(NSString *)email{
    if (![email isKindOfClass:[NSString class]]) return NO;
    if (email.length ==0) return NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z0-9a-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL b = [emailTest evaluateWithObject:email];
    return b;
}

+ (BOOL)validatePhone:(NSString *)phone{
    if (![phone isKindOfClass:[NSString class]]) return NO;
    if (phone.length ==0) return NO;
    NSString *emailRegex = @"^1\\d{10}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL b = [emailTest evaluateWithObject:phone];
    return b;
}

/**
 *  禁止系统表情的输入
 */
+ (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

+ (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font{
    return [text sizeWithAttributes:@{NSFontAttributeName: font}];
}
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize{
    CGRect rect = [text boundingRectWithSize:maxSize
        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin//采用换行模式
        attributes:@{NSFontAttributeName: font}//传人的字体字典
        context:nil];
    return rect.size;
}

+ (BOOL)hasChatQueueMessage{
    NSNumber *hasChatQueueMessage = [[NSUserDefaults standardUserDefaults]valueForKey:kKF5UserDefaultHasChatQueueMessage];
    return hasChatQueueMessage.boolValue;
    
}
+ (void)setHasChatQueueMessage:(BOOL)hasChatQueueMessage{
    if (hasChatQueueMessage) {
        [[NSUserDefaults standardUserDefaults]setBool:hasChatQueueMessage forKey:kKF5UserDefaultHasChatQueueMessage];
    }else{
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:kKF5UserDefaultHasChatQueueMessage];
    }
}

- (void)dealloc{
    [[KFHelper reachabilityManager] stopMonitoring];
}

@end
