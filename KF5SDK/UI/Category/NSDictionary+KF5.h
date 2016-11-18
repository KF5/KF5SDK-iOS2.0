//
//  NSDictionary+KF5.h
//  Pods
//
//  Created by admin on 16/10/24.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KF5)

- (nullable id)kf5_objectForKeyPath:(nonnull NSString *)keyPath;
- (nullable NSString *)kf5_stringForKeyPath:(nonnull NSString *)keyPath;
- (nullable NSNumber *)kf5_numberForKeyPath:(nonnull NSString *)keyPath;
- (nullable NSArray *)kf5_arrayForKeyPath:(nonnull NSString *)keyPath;
- (nullable NSDictionary *)kf5_dictionaryForKeyPath:(nonnull NSString *)keyPath;
- (BOOL)kf5_hasKey:(nonnull NSString *)key;

@end
