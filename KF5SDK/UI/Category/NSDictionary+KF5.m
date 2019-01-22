//
//  NSDictionary+KF5.m
//  Pods
//
//  Created by admin on 16/10/24.
//
//

#import "NSDictionary+KF5.h"

@implementation NSDictionary (KF5)

- (id)kf5_objectForKeyPath:(NSString *)keyPath{
    
    NSAssert([keyPath isKindOfClass:[NSString class]], @"key必须是字符串,且不能为nil");
    
    id object = [self valueForKeyPath:keyPath];
    
    if (object && [object isKindOfClass:[NSNull class]]) {
        
        NSAssert(NO, @"该value类型不能为NSNull");
    }
    if (![object isKindOfClass:[NSNull class]])
        return object;
    
    return nil;
}
- (NSString *)kf5_stringForKeyPath:(NSString *)keyPath{
    id value = [self kf5_objectForKeyPath:keyPath];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"%@  keyPath:%@ 该value类型不是NSString",self, keyPath);
        if ([value isKindOfClass:[NSString class]]) return value;
    }
    
    return nil;
}
-(NSNumber *)kf5_numberForKeyPath:(NSString *)keyPath{
    id value = [self kf5_objectForKeyPath:keyPath];
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"%@  keyPath:%@ 该value类型不是NSNumber",self, keyPath);
        if ([value isKindOfClass:[NSNumber class]]) return value;
    }
    return nil;
}
-(NSArray *)kf5_arrayForKeyPath:(NSString *)keyPath{
    id value = [self kf5_objectForKeyPath:keyPath];
    if (value) {
        NSAssert([value isKindOfClass:[NSArray class]], @"%@  keyPath:%@ 该value类型不是NSArray",self, keyPath);
        if ([value isKindOfClass:[NSArray class]]){
            NSArray *array = value;
            BOOL hasNull = NO;
            for (id v in array) {
                NSAssert(![v isKindOfClass:[NSNull class]], @"%@  keyPath:%@ 数组内部有NULL",self, keyPath);
                hasNull = [v isKindOfClass:[NSNull class]];
                if (hasNull)break;
            }
            if (hasNull) {
                NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
                for (id v in array) {
                    if (![v isKindOfClass:[NSNull class]]) {
                        [newArray addObject:v];
                    }
                }
                return newArray;
            }
            return value;
        }
    }
    
    
    return nil;
}
- (NSDictionary *)kf5_dictionaryForKeyPath:(NSString *)keyPath{
    id value = [self kf5_objectForKeyPath:keyPath];
    if (value) {
        NSAssert([value isKindOfClass:[NSDictionary class]], @"%@  keyPath:%@ 该value类型不是NSDictionary",self, keyPath);
        if ([value isKindOfClass:[NSDictionary class]]) return value;
    }
    return nil;
}

- (BOOL)kf5_hasKey:(NSString *)key{
    return [[self allKeys]containsObject:key];
}

@end
