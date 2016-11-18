//
//  KFUser.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import <Foundation/Foundation.h>

@interface KFUser : NSObject<NSCoding>

/**
 用户唯一标示
 */
@property (nullable, nonatomic, copy,readonly) NSString *userToken;

/**
 用户的id
 */
@property (nonatomic, assign,readonly) NSInteger user_id;

/**
 邮箱
 */
@property (nullable, nonatomic, copy,readonly) NSString *email;

/**
 手机号
 */
@property (nullable, nonatomic, copy,readonly) NSString *phone;

/**
 昵称
 */
@property (nullable, nonatomic, copy,readonly) NSString *userName;

/**
 deviceTokens集合
 */
@property (nullable, nonatomic, strong,readonly) NSDictionary *deviceTokens;

+ (nonnull instancetype)userWithDict:(nonnull NSDictionary *)dict;
@end
