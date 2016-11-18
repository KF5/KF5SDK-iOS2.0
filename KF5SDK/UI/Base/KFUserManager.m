//
//  KFUserManager.m
//  Pods
//
//  Created by admin on 16/11/9.
//
//

#import "KFUserManager.h"
#import "KFHelper.h"
#import  <KF5SDK/KFHttpTool.h>
#import  <KF5SDK/KFDispatcher.h>
#import "AFNetworkReachabilityManager.h"

static NSString * const KF5UserInfo = @"KF5USERINFO";

@implementation KFUserManager

+ (instancetype)shareUserManager{
    static KFUserManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!share) {
            share = [[KFUserManager alloc] init];
            share.user = [KFUserManager localUser];
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        }
    });
    return share;
}

- (void)initializeWithEmail:(NSString *)email completion:(void (^)(KFUser * _Nullable, NSError * _Nullable))completion{
    NSAssert([KFHelper validateEmail:email], @"邮箱不能为空且格式必须正确");
    [self initializeWithParams:@{@"email":email?:@""} completion:completion];
}

- (void)initializeWithPhone:(NSString *)phone completion:(void (^)(KFUser * _Nullable, NSError * _Nullable))completion{
    NSAssert([KFHelper validatePhone:phone], @"手机号不能为空且格式必须正确");
    [self initializeWithParams:@{@"phone":phone?:@""} completion:completion];
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
- (void)dealloc{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
@end
