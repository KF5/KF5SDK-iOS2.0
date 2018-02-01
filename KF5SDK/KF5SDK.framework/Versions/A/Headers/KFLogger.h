//
//  KFLogger.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import <Foundation/Foundation.h>

@interface KFLogger : NSObject

/**
 SDK打印内容

 @param format 日志内容
 */
+ (void) log:(nonnull NSString *)format, ...;

/**
 是否输出日志
 */
+ (void) enable:(BOOL)enabled;

@end
