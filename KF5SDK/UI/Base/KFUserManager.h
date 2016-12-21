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

 @param email       用户邮箱
 */
- (void)initializeWithEmail:(nonnull NSString *)email completion:(nullable void (^) ( KFUser *_Nullable user,NSError * _Nullable error))completion;
/**
 手机号初始化用户

 @param phone       用户手机号
 */
- (void)initializeWithPhone:(nonnull NSString *)phone completion:(nullable void (^) (KFUser * _Nullable user,NSError * _Nullable error))completion;
/**
 初始化用户

 @param params 参数,如下
 @{
     KF5Email:@"",  // 用户的邮箱,选其一
     KF5Phone:@""   // 用户的手机号,选其一
 };
 @warning   email和phone只能选其一,两者都填默认优先验证手机号
 */
- (void)initializeWithParams:(nonnull NSDictionary *)params completion:(nullable void (^)(KFUser * _Nullable, NSError * _Nullable))completion;
/**
 更新用户信息

 @param email 更新邮箱,为空不更新
 @param phone 更新手机号,为空不更新
 @param name  更新昵称,为空不更新
 @warning   必须初始化完成后,才能使用
 */
- (void)updateUserWithEmail:(nullable NSString *)email phone:(nullable NSString *)phone name:(nullable NSString *)name completion:(nullable void (^)(KFUser * _Nullable, NSError * _Nullable))completion;

@end
