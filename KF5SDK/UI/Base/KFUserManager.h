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
 初始化信息
 
 @param hostName  云客服域名
 @param appId     公司密钥
 */
+ (void)initializeWithHostName:(nonnull NSString *)hostName appId:(nonnull NSString *)appId;
/**
 是否输出日志
 */
+ (void)loggerEnabled:(BOOL)enabled;
/**
 获取当前SDK的版本(当前SDK版本为2.7.0)
 
 @return 版本号
 */
+ (nonnull NSString *)version;


/**
 邮箱初始化用户

 @param email       用户邮箱
 */
- (void)initializeWithEmail:(nonnull NSString *)email completion:(nullable void (^) ( KFUser *_Nullable user,NSError * _Nullable error))completion;
/**
 手机号初始化用户

 @param phone       用户手机号
 */
- (void)initializeWithPhone:(nonnull NSString *)phone completion:(nullable void (^) (KFUser * _Nullable user,NSError * _Nullable error))completion;
/**
 更新用户信息
 
 @param email 更新邮箱,为空不更新
 @param phone 更新手机号,为空不更新
 @param name  更新昵称,为空不更新
 @warning   必须初始化完成后,才能使用
 */
- (void)updateUserWithEmail:(nullable NSString *)email phone:(nullable NSString *)phone name:(nullable NSString *)name completion:(nullable void (^)(KFUser * _Nullable user, NSError * _Nullable error))completion;

/**
 保存deviceToken

 @param deviceToken 用户deviceToken,不能为空
 @warning   必须初始化完成后,才能使用
 */
- (void)saveDeviceToken:(nonnull NSString *)deviceToken completion:(nullable void (^)(NSDictionary * _Nullable result, NSError * _Nullable error))completion;
/**
 删除deviceToken
 
 @param deviceToken 用户deviceToken,不能为空
 @warning   必须初始化完成后,才能使用
 */
- (void)deleteDeviceToken:(nonnull NSString *)deviceToken completion:(nullable void (^)(NSDictionary * _Nullable result, NSError * _Nullable error))completion;

/**
 初始化用户

 @param params 参数,如下
 @{
     KF5Email:@"",  // 用户的邮箱,选其一
     KF5Phone:@""   // 用户的手机号,选其一
 };
 @warning   email和phone只能选其一,两者都填默认优先验证手机号
 */
- (void)initializeWithParams:(nonnull NSDictionary *)params completion:(nullable void (^)(KFUser * _Nullable user, NSError * _Nullable error))completion;
/**
 更新用户信息
 @param params 参数,如下
 @{
 KF5Email:@"",  // 更新邮箱,选填,不传则不更新
 KF5Phone:@""   // 更新手机号,选填,不传则不更新
 KF5Name:@""    // 更新昵称,选填,不传则不更新
 };
 @warning   必须初始化完成后,才能使用
 */
- (void)updateUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^)(KFUser * _Nullable user, NSError * _Nullable error))completion;

@end
