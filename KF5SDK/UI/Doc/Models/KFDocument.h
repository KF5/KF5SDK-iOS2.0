//
//  KFDocument.h
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import <Foundation/Foundation.h>

@interface KFDocument : NSObject

///文档id
@property (nonatomic, assign) NSInteger document_id;
///标题
@property (nullable, nonatomic, copy) NSString *title;
///创建时间
@property (nonatomic, assign) double created_at;
///内容
@property (nullable, nonatomic, copy) NSString *content;
///附件
@property (nullable, nonatomic,strong) NSArray *attachments;

+ (nullable instancetype)documentWithDict:(nonnull NSDictionary *)dict;

@end
