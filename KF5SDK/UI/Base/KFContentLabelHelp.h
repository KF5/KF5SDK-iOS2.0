//
//  KFContentLabelHelp.h
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, KFLabelHelpHandle) {
    KFLabelHelpHandleATag = 1 << 0,     // 匹配a标签[KFLinkAtagFormatUrl][KFLinkAtagFormatName]
    KFLabelHelpHandleHttp = 1 << 1,     // 匹配http[KFLinkURLName]
    KFLabelHelpHandlePhone = 1 << 2,    // 匹配phone[KFLinkPhoneName]
    KFLabelHelpHandleBracket = 1 << 3   // 匹配{{}}[KFLinkBracket]
};

typedef enum : NSUInteger {
    kKFLinkTypeNone,         // 无
    kKFLinkTypePhone,        // 电话
    kKFLinkTypeURL,          // 链接
    kKFLinkTypeDucument,     // IM知识库文档
    kKFLinkTypeBracket,      // IM转接客服
    kKFLinkTypeLeaveMessage, // IM留言
    kKFLinkTypeVideo         // 视频
} kKFLinkType;

@interface KFContentLabelHelp : NSObject
/**
 *  制作文件点击文本
 *
 *  @param string    文件名称
 *  @param urlString 点击的url
 *  @param font      文本字体
 *  @param urlColor  文本颜色
 */
+ (NSMutableAttributedString *)documentStringWithString:(NSString *)string urlString:(NSString *)urlString font:(UIFont *)font urlColor:(UIColor *)urlColor;
/**
 *  自定义消息
 *
 *  @param JSONString JSON字符串
 *  @param font       字体
 *  @param textColor  文本颜色
 *  @param urlColor   链接颜色
 */
+ (NSMutableAttributedString *)customMessageWithJSONString:(NSString *)JSONString font:(UIFont *)font textColor:(UIColor *)textColor urlColor:(UIColor *)urlColor;
/**
 系统消息匹配{{去留言}}

 @param string     内容
 @param font       字体
 @param textColor  文字颜色
 @param urlColor   链接颜色
 */
+ (NSMutableAttributedString *)systemMessageWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor urlColor:(UIColor *)urlColor;
/**
 *  聊天消息匹配电话,url,http,a标签
 *
 *  @param string    内容
 *  @param optional  要解析的方式
 *  @param font      字体
 *  @param textColor 文本颜色
 *  @param urlColor  链接颜色
 */
+ (NSMutableAttributedString *)baseMessageWithString:(NSString *)string labelHelpHandle:(KFLabelHelpHandle)optional font:(UIFont *)font textColor:(UIColor *)textColor urlColor:(UIColor *)urlColor;

/**
 *  制作高亮富文本
 *
 *  @param string   内容
 *  @param userInfo 需要附加的信息
 *  @param font     字体
 *  @param color    颜色
 */
+ (NSMutableAttributedString *)hightlightBorderWithString:(NSString *)string userInfo:(NSDictionary *)userInfo font:(UIFont *)font color:(UIColor *)color;
@end
