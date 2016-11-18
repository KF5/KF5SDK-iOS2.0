//
//  NSDate+KF5.m
//  NSDateDemo
//
//  Created by admin on 16/10/24.
//  Copyright © 2016年 kf5. All rights reserved.
//

#import "NSDate+KF5.h"

NSString *const KF5DateFormatTime                = @"HH:mm";
NSString *const KF5DateFormatWeekdayWithTime     = @"EEEE HH:mm";
NSString *const KF5DateFormatShortDateWithTime   = @"MMM dd HH:mm";
NSString *const KF5DateFormatFullDateWithTime    = @"MMM dd, yyyy HH:mm";

NSString *const KF5DateFormatSQLDate             = @"yyyy-MM-dd";
NSString *const KF5DateFormatSQLTime             = @"HH:mm:ss";
NSString *const KF5DateFormatSQLDateWithTime     = @"yyyy-MM-dd HH:mm:ss";

@implementation NSDate (KF5)

static NSCalendar *_calendar = nil;
static NSDateFormatter *_displayFormatter = nil;

+ (void)initializeStatics {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_calendar == nil) {
            _calendar = [NSCalendar currentCalendar];
        }
        if (_displayFormatter == nil) {
            _displayFormatter = [[NSDateFormatter alloc] init];
        }
    });
}

+ (NSCalendar *)sharedCalendar {
    [self initializeStatics];
    return _calendar;
}

+ (NSDateFormatter *)sharedDateFormatter {
    [self initializeStatics];
    return _displayFormatter;
}


+ (NSDate *)kf5_dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *formatter = [self sharedDateFormatter];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSDate *)kf5_dateFromString:(NSString *)string {
    return [NSDate kf5_dateFromString:string withFormat:KF5DateFormatSQLDateWithTime];
}

+ (NSString *)kf5_stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    return [date kf5_stringWithFormat:format];
}

+ (NSString *)kf5_stringFromDate:(NSDate *)date {
    return [date kf5_stringWithFormat:KF5DateFormatSQLDateWithTime];
}

+ (NSString *)kf5_stringForDisplayFromDate:(NSDate *)date{
    
    NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [[self sharedCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                                  fromDate:today];
    NSDate *midnight = [[self sharedCalendar] dateFromComponents:offsetComponents];
    NSString *displayString = nil;
    
    NSComparisonResult midnight_result = [date compare:midnight];
    if (midnight_result == NSOrderedDescending) {
        [[self sharedDateFormatter] setDateFormat:KF5DateFormatTime];
    } else {
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        NSDate *lastweek = [[self sharedCalendar] dateByAddingComponents:componentsToSubtract toDate:today options:0];
        NSComparisonResult lastweek_result = [date compare:lastweek];
        if (lastweek_result == NSOrderedDescending) {
            [[self sharedDateFormatter] setDateFormat:KF5DateFormatWeekdayWithTime];
        } else {
            NSInteger thisYear = [offsetComponents year];
            NSDateComponents *dateComponents = [[self sharedCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                                        fromDate:date];
            NSInteger thatYear = [dateComponents year];
            if (thatYear >= thisYear) {
                [[self sharedDateFormatter] setDateFormat:KF5DateFormatShortDateWithTime];
            } else {
                [[self sharedDateFormatter] setDateFormat:KF5DateFormatFullDateWithTime];
            }
        }
    }
    
    displayString = [[self sharedDateFormatter] stringFromDate:date];
    return displayString;
}


- (NSString *)kf5_stringWithFormat:(NSString *)format{
    [[self class] initializeStatics];
    [[[self class] sharedDateFormatter] setDateFormat:format];
    NSString *timestamp_str = [[[self class] sharedDateFormatter] stringFromDate:self];
    return timestamp_str;
}
- (NSString *)kf5_string{
    return [self kf5_stringWithFormat:KF5DateFormatSQLDateWithTime];
}

@end
