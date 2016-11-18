//
//  NSDate+KF5.h
//  NSDateDemo
//
//  Created by admin on 16/10/24.
//  Copyright © 2016年 kf5. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const KF5DateFormatTime;
FOUNDATION_EXPORT NSString *const KF5DateFormatWeekdayWithTime;
FOUNDATION_EXPORT NSString *const KF5DateFormatShortDateWithTime;
FOUNDATION_EXPORT NSString *const KF5DateFormatFullDateWithTime;
FOUNDATION_EXPORT NSString *const KF5DateFormatSQLDate;
FOUNDATION_EXPORT NSString *const KF5DateFormatSQLTime;
FOUNDATION_EXPORT NSString *const KF5DateFormatSQLDateWithTime;

@interface NSDate (KF5)

+ (NSDate *)kf5_dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSDate *)kf5_dateFromString:(NSString *)string;
+ (NSString *)kf5_stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)kf5_stringFromDate:(NSDate *)date;

+ (NSString *)kf5_stringForDisplayFromDate:(NSDate *)date;

- (NSString *)kf5_stringWithFormat:(NSString *)format;
- (NSString *)kf5_string;

@end
