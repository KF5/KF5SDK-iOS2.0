//
//  KFUser.m
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import "KFUser.h"
#import "KFHelper.h"

@interface KFUser()

@property (nullable, nonatomic, copy, readwrite) NSString *userToken;
@property (nonatomic, assign, readwrite) NSInteger user_id;
@property (nullable, nonatomic, copy, readwrite) NSString *email;
@property (nullable, nonatomic, copy, readwrite) NSString *phone;
@property (nullable, nonatomic, copy, readwrite) NSString *userName;
@property (nullable, nonatomic, strong, readwrite) NSDictionary *deviceTokens;

@end

@implementation KFUser

+ (instancetype)userWithDict:(NSDictionary *)dict{
    KFUser *user = [[KFUser alloc] init];
    user.userToken = [dict kf5_stringForKeyPath:@"userToken"];
    user.user_id = [dict kf5_numberForKeyPath:@"id"].integerValue;
    user.email = [dict kf5_stringForKeyPath:@"email"];
    user.phone = [dict kf5_stringForKeyPath:@"phone"];
    user.userName = [dict kf5_stringForKeyPath:@"userName"];
    user.deviceTokens = [dict kf5_dictionaryForKeyPath:@"deviceTokens"];
    return user;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userToken = [decoder decodeObjectForKey:@"userToken"];
    self.user_id = [decoder decodeIntegerForKey:@"user_id"];
    self.email = [decoder decodeObjectForKey:@"email"];
    self.phone = [decoder decodeObjectForKey:@"phone"];
    self.userName = [decoder decodeObjectForKey:@"userName"];
    self.deviceTokens = [decoder decodeObjectForKey:@"deviceTokens"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userToken forKey:@"userToken"];
    [encoder encodeInteger:self.user_id forKey:@"user_id"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.deviceTokens forKey:@"deviceTokens"];
}

@end
