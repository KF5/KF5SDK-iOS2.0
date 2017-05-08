//
//  KFDocObject.h
//  Pods
//
//  Created by admin on 15/12/14.
//
//

#import <Foundation/Foundation.h>

@interface KFDocItem : NSObject

///Id
@property (nonatomic, assign) NSInteger Id;
///标题
@property (nullable, nonatomic, copy) NSString *title;
///描述
@property (nullable, nonatomic, copy) NSString *content;

+ (nonnull instancetype)docItemForDict:(nonnull NSDictionary *)dict;

+ (nonnull NSArray <KFDocItem *>*)docItemsWithDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

@end
