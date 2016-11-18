//
//  KFAttachment.m
//  SampleSDKApp
//
//  Created by admin on 15/8/17.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "KFAttachment.h"

@implementation KFAttachment

+ (NSArray *)attachmentsWithDict:(NSArray *)array{
    if (![array isKindOfClass:[NSArray class]])return nil;
    
    NSMutableArray *attachments = [NSMutableArray array];
    for (NSDictionary *attDict in array) {
        KFAttachment *attchment = [[KFAttachment alloc]init];
        attchment.Id = [attDict objectForKey:@"id"];
        attchment.name = [attDict objectForKey:@"name"];
        attchment.size = [attDict objectForKey:@"size"];
        attchment.token = [attDict objectForKey:@"token"];
        attchment.url = [attDict objectForKey:@"content_url"];
        
        NSSet *set = [NSSet setWithObjects:@"png",@"jpg",@"jif",@"jpeg",@"bmp",@"gif", nil];
        BOOL isImage = NO;
        if ([attchment.name isKindOfClass:[NSString class]]) {
            for (NSString *str in set) {
                NSString *name = [attchment.name lowercaseString];
                if ([name hasSuffix:str]) {
                    isImage = YES;
                    break;
                }
            }
        }
        
        attchment.isImage = isImage;
        
        [attachments addObject:attchment];
    }
    return attachments;
}

@end
