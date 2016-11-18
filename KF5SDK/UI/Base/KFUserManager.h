//
//  KFUserManager.h
//  Pods
//
//  Created by admin on 16/11/9.
//
//

#import <Foundation/Foundation.h>
#import "KFUser.h"

@interface KFUserManager : NSObject

+ (nonnull instancetype)shareUserManager;

@property (nullable, nonatomic, strong) KFUser *user;

/**
 将user保存到本地
 */
+ (void)saveUser:(nonnull KFUser *)user;
/**
 删除用户
 */
+ (void)deleteUser;

/**
 邮箱初始化用户

 @param email      用户邮箱
 */
- (void)initializeWithEmail:(nonnull NSString *)email completion:(nullable void (^) ( KFUser *_Nullable user,NSError * _Nullable error))completion;
/**
 手机号初始化用户

 @param phone      用户手机号
 */
- (void)initializeWithPhone:(nonnull NSString *)phone completion:(nullable void (^) (KFUser * _Nullable user,NSError * _Nullable error))completion;
/**
 初始化用户

 @param params     初始化参数
 */
- (void)initializeWithParams:(nonnull NSDictionary *)params completion:(nullable void (^)(KFUser * _Nullable, NSError * _Nullable))completion;

@end
