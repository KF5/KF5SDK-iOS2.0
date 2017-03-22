//
//  KFUserManager.m
//  Pods
//
//  Created by admin on 16/11/9.
//
//

#import "KFUserManager.h"
#import "KFHelper.h"
#import <KF5SDK/KFHttpTool.h>
#import <KF5SDK/KFDispatcher.h>

static NSString * const KF5UserInfo = @"KF5USERINFO";

@implementation KFUserManager

+ (instancetype)shareUserManager{
    static KFUserManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!share) {
            share = [[KFUserManager alloc] init];
            share.user = [KFUserManager localUser];
        }
    });
    return share;
}

- (void)initializeWithEmail:(NSString *)email completion:(void (^)(KFUser * _Nullable, NSError * _Nullable))completion{
    NSAssert([KFHelper validateEmail:email], @"邮箱不能为空且格式必须正确");
    [self initializeWithParams:@{KF5Email:email?:@""} completion:completion];
}

- (void)initializeWithPhone:(NSString *)phone completion:(void (^)(KFUser * _Nullable, NSError * _Nullable))completion{
    NSAssert([KFHelper validatePhone:phone], @"手机号不能为空且格式必须正确");
    [self initializeWithParams:@{KF5Phone:phone?:@""} completion:completion];
}

- (void)initializeWithParams:(NSDictionary *)params completion:(void (^)(KFUser * _Nullable, NSError * _Nullable))completion{
    
    self.user = nil;
    
    __weak typeof(self)weakSelf = self;
    [KFHttpTool loginUserWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        if (!error) {
            weakSelf.user = [KFUser userWithDict:[result kf5_dictionaryForKeyPath:@"data.user"]];
            if(completion)completion(weakSelf.user,error);
        }else{
            if (error.code == KFErrorCodeUserNone) {
                [KFHttpTool createUserWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
                    if (!error)
                        weakSelf.user = [KFUser userWithDict:[result kf5_dictionaryForKeyPath:@"data.user"]];
                    
                    if(completion)completion(weakSelf.user,error);
                }];
            }else{
                if(completion)completion(nil,error);
            }
        }
    }];
}

- (void)updateUserWithEmail:(NSString *)email phone:(NSString *)phone name:(NSString *)name completion:(void (^)(KFUser * _Nullable, NSError * _Nullable))completion{
    if (self.user.userToken.length == 0) {
        NSError *error = [NSError errorWithDomain:@"请先调用KFUserManager的初始化方法" code:KFErrorCodeParamError userInfo:nil];
        if (completion) completion(nil,error);
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.user.userToken.length > 0) [params setObject:self.user.userToken forKey:KF5UserToken];
    if (email.length > 0) [params setObject:email forKey:KF5Email];
    if (phone.length > 0) [params setObject:phone forKey:KF5Phone];
    if (name.length > 0) [params setObject:name forKey:KF5Name];
    __weak typeof(self)weakSelf = self;
    [KFHttpTool updateUserWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        if (!error) {
            weakSelf.user = [KFUser userWithDict:[result kf5_dictionaryForKeyPath:@"data.user"]];
            if(completion)completion(weakSelf.user,error);
        }else{
            if(completion)completion(nil,error);
        }
    }];
}

- (void)setUser:(KFUser *)user{
    _user = user;
    if (user) {
        [KFUserManager saveUser:user];
    }
}

+ (void)saveUser:(KFUser *)user{
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults]setObject:userData forKey:KF5UserInfo];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)deleteUser{
    [KFUserManager shareUserManager].user = nil;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:KF5UserInfo];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (nullable KFUser *)localUser{
    NSData *userData = [[NSUserDefaults standardUserDefaults]objectForKey:KF5UserInfo];
    KFUser *user = nil;
    if (userData) {
        user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
    return user;
}

@end
