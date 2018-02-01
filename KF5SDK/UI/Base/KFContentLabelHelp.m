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

+ (NSMutableAttributedString *)baseMessageWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color{
    return [self attributedString:string labelHelpHandle:KFLabelHelpHandleATag|KFLabelHelpHandleHttp|KFLabelHelpHandlePhone|KFLabelHelpHandleBracket|KFLabelHelpHandleImg font:font color:color];
}

+ (NSMutableAttributedString *)documentStringWithString:(NSString *)string urlString:(NSString *)urlString font:(UIFont *)font color:(UIColor *)color{
    return [self hightlightBorderWithString:string userInfo:[self userInfoWithType:kKFLinkTypeURL title:string key:urlString] font:font color:color];
}

+ (NSMutableAttributedString *)customMessageWithJSONString:(NSString *)JSONString font:(UIFont *)font color:(UIColor *)color{
    NSDictionary *dict = [KFHelper dictWithJSONString:JSONString];
    if (!dict) return [self attStringWithString:@" " font:font color:color];
    NSString *type = [dict kf5_stringForKeyPath:@"type"];
    if ([type isEqualToString:@"video"]) {// json字符串{@"type":@"video",@"visitor_url":"xxxxxxxx";@"agent_url":"xxxxxxx"}
        NSString *visitor_url = [dict kf5_stringForKeyPath:@"visitor_url"];
        NSMutableAttributedString *text = [self hightlightBorderWithString:KF5Localized(@"kf5_invite_video_chat") userInfo:[self userInfoWithType:kKFLinkTypeVideo title:@"视频会话" key:visitor_url] font:font color:color];
        return text;
    }else if([type isEqualToString:@"document"]){// json字符串{@"type":@"document", @"content":"";@"documents":[{@"post_id":@(),@"title":@"",@"url":@""}]}
        
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
    }else if([type isEqualToString:@"question"]){// json字符串{@"type":@"question", @"content":"";@"questions":[{@"id":@(),@"title":@""}]}
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

+ (NSMutableAttributedString *)attributedString:(NSString *)string labelHelpHandle:(KFLabelHelpHandle)optional font:(UIFont *)font color:(UIColor *)color{
    if (string.length == 0) return [self attStringWithString:@" " font:font color:color];
    
    NSMutableAttributedString *text = [self attStringWithString:string font:font color:color];
    __weak typeof(self)weakSelf = self;
    if (optional&1<<0) {
        // 匹配 atag
        text = [self matchingWithRegular:self.regexAtagFormat attributeString:text mapHandle:^NSAttributedString *(NSArray *results) {
            if (results.count != 3) return nil;
            NSString *href = results[1];
            NSString *title = results[2];
            return [weakSelf hightlightBorderWithString:title userInfo:[weakSelf userInfoWithType:[title isEqualToString:@"[图片]"] ? kKFLinkTypeImg : kKFLinkTypeURL title:title key:href] font:font color:color];
        }];
    }
    
    if (optional&1<<1) {
        // 匹配img
        text = [self matchingWithRegular:self.regexImg attributeString:text mapHandle:^NSAttributedString *(NSArray *results) {
            if (results.count != 2) return nil;
            NSString *imgStr = results[1];
            NSString *title = @"[图片]";
            return [weakSelf hightlightBorderWithString:title userInfo:[weakSelf userInfoWithType:kKFLinkTypeImg title:title key:imgStr] font:font color:color];
        }];
    }
    
    if (optional&1<<2) {
        // 匹配 http
        text = [self matchingWithRegular:self.regexHttp attributeString:text mapHandle:^NSAttributedString *(NSArray *results) {
            if (results.count == 0) return nil;
            NSString *httpStr = results[0];
            return [weakSelf hightlightBorderWithString:httpStr userInfo:[weakSelf userInfoWithType:kKFLinkTypeURL title:httpStr key:httpStr] font:font color:color];
        }];
    }
    
    if (optional&1<<3) {
        // 匹配phone
        text = [self matchingWithRegular:self.regexPhone attributeString:text mapHandle:^NSAttributedString *(NSArray *results) {
            if (results.count != 1) return nil;
            NSString *phoneStr = results[0];
            return [weakSelf hightlightBorderWithString:phoneStr userInfo:[weakSelf userInfoWithType:kKFLinkTypePhone title:phoneStr key:phoneStr] font:font color:color];
        }];
    }
    if (optional&1<<4) {
        // 匹配{{}}
        text = [self matchingWithRegular:self.regexBracket attributeString:text mapHandle:^NSAttributedString *(NSArray *results) {
            if (results.count != 2) return nil;
            NSString *bracketStr = results[1];
            return [weakSelf hightlightBorderWithString:bracketStr userInfo:[weakSelf userInfoWithType:kKFLinkTypeBracket title:bracketStr key:bracketStr] font:font color:color];
        }];
    }
    
    return text;
}

+ (NSMutableAttributedString *)matchingWithRegular:(NSRegularExpression *)regular attributeString:(NSMutableAttributedString *)attributeString mapHandle:(NSAttributedString * (^)(NSArray *results))mapHandle {
    NSArray *array = [regular matchesInString:attributeString.string options:kNilOptions range:NSMakeRange(0, attributeString.string.length)];
    NSUInteger offSet = 0;
    for (NSTextCheckingResult *value in array) {
        if (value.range.location == NSNotFound && value.range.length <= 1) continue;
        NSRange range = value.range;
        range.location += offSet;
        if ([self attribute:attributeString attributeName:KFLinkAttributeName atIndex:range.location]) continue;
        
        NSMutableArray <NSString *>*results = [NSMutableArray array];
        for (NSInteger index = 0; index < value.numberOfRanges; index++) {
            NSRange ran = [value rangeAtIndex:index];
            if (ran.location != NSNotFound) {
                ran.location += offSet;
                NSString *str = [attributeString.string substringWithRange:ran];
                if (str.length > 0) {
                    [results addObject: str];
                }
            }
        }
        NSAttributedString *replace = mapHandle(results);
        if (replace) {
            [attributeString replaceCharactersInRange:range withAttributedString:replace];
            offSet += replace.length - range.length;
        }
    }
    return attributeString;
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
        atagFormat = [NSRegularExpression regularExpressionWithPattern:@"<a\\b[^>]+\\bhref\\s*=\\s*\"([^\"]*)\"[^>]*>([\\s\\S]*?)</a>" options:kNilOptions error:NULL];
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
#pragma mark 匹配img
+ (NSRegularExpression *)regexImg{
    static NSRegularExpression *img;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        img = [NSRegularExpression regularExpressionWithPattern:@"<img.*?src\\s*=\\s*\"(.*?)\".*?>" options:kNilOptions error:NULL];
    });
    return img;
}

#pragma mark userInfo制作
+ (NSMutableDictionary *)userInfoWithType:(kKFLinkType)linkType title:(NSString *)title key:(NSString *)key{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setObject:@(linkType) forKey:KF5LinkType];
    [userInfo setObject:title?:@"" forKey:KF5LinkTitle];
    [userInfo setObject:key?:@"" forKey:KF5LinkKey];
    return userInfo;
}

+ (id)attribute:(NSAttributedString *)attribute attributeName:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > attribute.length || attribute.length == 0) return nil;
    if (attribute.length > 0 && index == attribute.length) index--;
    return [attribute attribute:attributeName atIndex:index effectiveRange:NULL];
}

@end
