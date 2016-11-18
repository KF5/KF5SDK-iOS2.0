//
//  KFDocument.m
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFDocument.h"
#import "KFHelper.h"

@implementation KFDocument

+(instancetype)documentWithDict:(NSDictionary *)dict{
    KFDocument *document = [[KFDocument alloc]init];
    document.document_id = [dict kf5_numberForKeyPath:@"id"].integerValue;
    document.title = [dict kf5_stringForKeyPath:@"title"];
    document.created_at = [dict kf5_numberForKeyPath:@"created_at"].doubleValue;
    document.content = [dict kf5_stringForKeyPath:@"content"];
    
    return document;
}

@end
