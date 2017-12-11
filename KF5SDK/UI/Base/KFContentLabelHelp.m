//
//  KFContentLabelHelp.m
//  Pods
//
//  Created by admin on 16/10/10.
//
//

#import "KFContentLabelHelp.h"

#import "KFHelper.h"
#import "KFLabel.h"


@implementation KFContentLabelHelp

+ (NSMutableAttributedString *)documentStringWithString:(NSString *)string urlString:(NSString *)urlString font:(UIFont *)font color:(UIColor *)color{
    if (string.length == 0) return [self attStringWithString:@" " font:font color:color];
    
    NSMutableAttributedString *text = [self hightlightBorderWithString:string userInfo:[self userInfoWithType:kKFLinkTypeURL title:string key:urlString] font:font color:color];
    return text;
}
+ (NSMutableAttributedString *)customMessageWithJSONString:(NSString *)JSONString font:(UIFont *)font color:(UIColor *)color{
    NSDictionary *dict = [KFHelper dictWithJSONString:JSONString];
    if (!dict) return [self attStringWithString:@" " font:font color:color];
    
    if ([[dict kf5_stringForKeyPath:@"type"]isEqualToString:@"video"]) {// json字符串{@"type":@"video",@"visitor_url":"xxxxxxxx";@"agent_url":"xxxxxxx"}
        NSString *visitor_url = [dict kf5_stringForKeyPath:@"visitor_url"];
        NSMutableAttributedString *text = [self hightlightBorderWithString:KF5Localized(@"kf5_invite_video_chat") userInfo:[self userInfoWithType:kKFLinkTypeVideo title:@"视频会话" key:visitor_url] font:font color:color];
        return text;
    }else if([[dict kf5_stringForKeyPath:@"type"]isEqualToString:@"document"]){// json字符串{@"type":@"document", @"content":"";@"documents":[{@"post_id":@(),@"title":@"",@"url":@""}]}
        
        NSString *content = [dict objectForKey:@"content"];
        
        NSMutableAttributedString *text = [self baseMessageWithString:content font:font color:color];
        
        NSArray *documents = [dict objectForKey:@"documents"];
        for (NSDictionary *docDict in documents) {
            NSNumber *post_id = [docDict kf5_numberForKeyPath:@"post_id"]?:[docDict kf5_numberForKeyPath:@"id"];
            NSString *title = [docDict kf5_stringForKeyPath:@"title"];
            NSString *url = [docDict kf5_stringForKeyPath:@"url"];
            
            NSMutableDictionary *userInfo = [self userInfoWithType:kKFLinkTypeDucument title:title key:post_id?[NSString stringWithFormat:@"%@",post_id]:@""];
            [userInfo setObject:url?:@"" forKey:KF5LinkURL];
            
            NSMutableAttributedString *docText = [self hightlightBorderWithString:title userInfo: userInfo font:font color:color];
            
            NSMutableAttributedString *t = [self attStringWithString:@"\n ● " font:font color:color];
            [text appendAttributedString:t];
            [text appendAttributedString:docText];
        }
        return text;
    }else if([[dict kf5_stringForKeyPath:@"type"] isEqualToString:@"question"]){// json字符串{@"type":@"question", @"content":"";@"questions":[{@"id":@(),@"title":@""}]}
        NSString *content = [dict objectForKey:@"content"];
        
        NSMutableAttributedString *text = [self baseMessageWithString:content font:font color:color];
        
        NSArray *questions = [dict objectForKey:@"questions"];
        for (NSDictionary *questionDict in questions) {
            NSNumber *question_id = [questionDict kf5_numberForKeyPath:@"id"];
            NSString *title = [questionDict kf5_stringForKeyPath:@"title"];
            
            NSMutableDictionary *userInfo = [self userInfoWithType:kKFLinkTypeQuestion title:title key:question_id?[NSString stringWithFormat:@"%@",question_id]:@""];
            
            NSMutableAttributedString *questionText = [self hightlightBorderWithString:title userInfo: userInfo font:font color:color];
            
            NSMutableAttributedString *t = [self attStringWithString:@"\n ● " font:font color:color];
            [text appendAttributedString:t];
            [text appendAttributedString:questionText];
        }
        return text;
    }else{
        return [self baseMessageWithString:JSONString font:font color:color];
    }
}

+ (NSMutableAttributedString *)systemMessageWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color{
    if (string.length == 0) [self attStringWithString:@" " font:font color:color];
    
    NSMutableAttributedString *text = [self attStringWithString:string font:font color:color];
    // 匹配{{}}
    NSArray *bracketResults = [[self regexBracket]matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
    NSUInteger bracketResultsChangeLength = 0;
    for (NSTextCheckingResult *bracketResult in bracketResults) {
        if (bracketResult.range.location == NSNotFound && bracketResult.range.length <= 1) continue;
        NSRange range = bracketResult.range;
        range.location += bracketResultsChangeLength;
        if ([self attribute:text attributeName:KFLinkAttributeName atIndex:range.location]) continue;
        
        NSString *bracketString = [text.string substringWithRange:NSMakeRange(range.location + 2, range.length - 4)];
        
        // 要替换的字符串
        NSMutableAttributedString *replace = [self hightlightBorderWithString:bracketString userInfo:[self userInfoWithType:kKFLinkTypeLeaveMessage title:bracketString key:bracketString] font:font color:color];
        // 替换
        [text replaceCharactersInRange:range withAttributedString:replace];
        bracketResultsChangeLength += replace.length - range.length;
    }
    return text;
}

+ (id)attribute:(NSAttributedString *)attribute  attributeName:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > attribute.length || attribute.length == 0) return nil;
    if (attribute.length > 0 && index == attribute.length) index--;
    return [attribute attribute:attributeName atIndex:index effectiveRange:NULL];
}

+ (NSMutableAttributedString *)baseMessageWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color{
    return [self attributedString:string labelHelpHandle:KFLabelHelpHandleATag|KFLabelHelpHandleHttp|KFLabelHelpHandlePhone|KFLabelHelpHandleBracket font:font color:color];
}

+ (NSMutableAttributedString *)attributedString:(NSString *)string labelHelpHandle:(KFLabelHelpHandle)optional font:(UIFont *)font color:(UIColor *)color{
    if (string.length == 0) return [self attStringWithString:@" " font:font color:color];
    
    NSMutableAttributedString *text = [self attStringWithString:string font:font color:color];
    
    if (optional&1<<0) {
        // 匹配 <a></a>
        NSArray *aTagFormatResults = [[self regexAtagFormat] matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
        NSUInteger aTagFormatchangeLength = 0;
        for (NSTextCheckingResult *aTagFormat in aTagFormatResults) {
            if (aTagFormat.range.location == NSNotFound && aTagFormat.range.length <= 1) continue;
            NSRange range = aTagFormat.range;
            range.location += aTagFormatchangeLength;
            if ([self attribute:text attributeName:KFLinkAttributeName atIndex:range.location]) continue;
    
            NSString *aTag = [text.string substringWithRange:range];
    
            // 获取url
            NSArray *urls = [[self regexHttp]matchesInString:aTag options:kNilOptions range:NSMakeRange(0, aTag.length)];
            if (urls.count == 0) continue;
            NSTextCheckingResult *urlResult = urls.firstObject;
            if (urlResult.range.location == NSNotFound && urlResult.range.length <= 1) continue;
            NSString *url = [aTag substringWithRange:urlResult.range];
            // 获取文本信息
            NSString *pageStart=@">";
            NSString *pageEnd=@"</";
            NSRange startRange=[aTag rangeOfString:pageStart];
            NSRange endRange=[aTag rangeOfString:pageEnd];
            NSString *title=[aTag substringWithRange:NSMakeRange(NSMaxRange(startRange), endRange.location-NSMaxRange(startRange))];
    
            // 要替换的字符串
            NSMutableAttributedString *replace = [self hightlightBorderWithString:title userInfo:[self userInfoWithType:kKFLinkTypeURL title:title key:url] font:font color:color];
    
            // 替换
            [text replaceCharactersInRange:range withAttributedString:replace];
            aTagFormatchangeLength += replace.length - range.length;
        }
    }
    
    if (optional&1<<1) {
        // 匹配 http
        NSArray *httpResults = [[self regexHttp] matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *httpResult in httpResults) {
            if (httpResult.range.location == NSNotFound && httpResult.range.length <= 1) continue;
            NSRange range = httpResult.range;
            if ([self attribute:text attributeName:KFLinkAttributeName atIndex:range.location]) continue;

            NSString *httpString = [text.string substringWithRange:range];
            
            // 要替换的高亮富文本
            NSMutableAttributedString *replace = [self hightlightBorderWithString:httpString userInfo:[self userInfoWithType:kKFLinkTypeURL title:httpString key:httpString] font:font color:color];
            
            // 替换
            [text replaceCharactersInRange:range withAttributedString:replace];
        }
    }
    
    if (optional&1<<2) {
        // 匹配手机号
        NSArray *phoneResults = [[self regexPhone]matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *phoneResult in phoneResults) {
            if (phoneResult.range.location == NSNotFound && phoneResult.range.length <= 1) continue;
            NSRange range = phoneResult.range;
            if ([self attribute:text attributeName:KFLinkAttributeName atIndex:range.location]) continue;
            
            NSString *phoneString = [text.string substringWithRange:range];
            // 要替换的字符串
            NSMutableAttributedString *replace = [self hightlightBorderWithString:phoneString userInfo:[self userInfoWithType:kKFLinkTypePhone title:phoneString key:phoneString] font:font color:color];
            // 替换
            [text replaceCharactersInRange:range withAttributedString:replace];
        }
    }
    if (optional&1<<3) {
        // 匹配{{}}
        NSArray *bracketResults = [[self regexBracket]matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
        NSUInteger bracketResultsChangeLength = 0;
        for (NSTextCheckingResult *bracketResult in bracketResults) {
            if (bracketResult.range.location == NSNotFound && bracketResult.range.length <= 1) continue;
            NSRange range = bracketResult.range;
            range.location += bracketResultsChangeLength;
            if ([self attribute:text attributeName:KFLinkAttributeName atIndex:range.location]) continue;

            NSString *bracketString = [text.string substringWithRange:NSMakeRange(range.location + 2, range.length - 4)];
            
            // 要替换的字符串
            NSMutableAttributedString *replace = [self hightlightBorderWithString:bracketString userInfo:[self userInfoWithType:kKFLinkTypeBracket title:bracketString key:bracketString] font:font color:color];
            // 替换
            [text replaceCharactersInRange:range withAttributedString:replace];
            bracketResultsChangeLength += replace.length - range.length;
        }
    }
    
    return text;
}



/**
 *  制作高亮的富文本
 *
 *  @param string   文本
 *  @param userInfo 携带信息
 */
+ (NSMutableAttributedString *)hightlightBorderWithString:(NSString *)string userInfo:(NSDictionary *)userInfo font:(UIFont *)font color:(UIColor *)color{
    if (string.length == 0) return [self attStringWithString:@" " font:font color:color];
    
    NSMutableAttributedString *hightlightString = [self attStringWithString:string font:font color:color];
    [hightlightString addAttribute:KFLinkAttributeName value:userInfo range:NSMakeRange(0, hightlightString.length)];
    
    return hightlightString;
}
/**
 *  制作普通富文本
 */
+ (NSMutableAttributedString *)attStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color{
    if (!string) string = @"";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    if (font)
        [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    if (color)
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

#pragma mark 手机号
+ (NSRegularExpression *)regexPhone{
    static NSRegularExpression *phone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        phone = [NSRegularExpression regularExpressionWithPattern:@"1[0-9]{10}" options:kNilOptions error:NULL];
    });
    return phone;
}

#pragma mark 匹配a标签
+ (NSRegularExpression *)regexAtagFormat{
    static NSRegularExpression *atagFormat;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        atagFormat = [NSRegularExpression regularExpressionWithPattern:@"<a.*?[^<]+</a>" options:kNilOptions error:NULL];
    });
    return atagFormat;
}
#pragma mark 匹配{{}}
+ (NSRegularExpression *)regexBracket{
    static NSRegularExpression *bracket;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bracket = [NSRegularExpression regularExpressionWithPattern:@"\\{\\{(.+?)\\}\\}" options:kNilOptions error:NULL];
    });
    return bracket;
}
#pragma mark 匹配http
+ (NSRegularExpression *)regexHttp{
    static NSRegularExpression *http;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http = [NSRegularExpression regularExpressionWithPattern:@"([hH]ttp[s]{0,1})://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\-~!@#$%^&*+?:_/=<>.\',;]*)?" options:kNilOptions error:NULL];
    });
    return http;
}


#pragma mark userInfo制作
+ (NSMutableDictionary *)userInfoWithType:(kKFLinkType)linkType title:(NSString *)title key:(NSString *)key{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setObject:@(linkType) forKey:KF5LinkType];
    [userInfo setObject:title?:@"" forKey:KF5LinkTitle];
    [userInfo setObject:key?:@"" forKey:KF5LinkKey];
    return userInfo;
}

@end
