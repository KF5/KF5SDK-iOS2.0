//
//  KFRatingModel.h
//  KF5SDKUI2.0
//
//  Created by admin on 16/12/30.
//  Copyright © 2016年 kf5. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 工单状态
 */
typedef NS_ENUM(NSInteger,KFRatingScore) {
    KFRatingScoreNone = 0,  // 未评价
    KFRatingScoreBad,       // 不满意
    KFRatingScoreSoso,      // 不太满意
    KFRatingScoreOk,        // 一般
    KFRatingScoreGood,      // 满意
    KFRatingScoreGreat      // 非常满意
};

@interface KFRatingModel : NSObject
/**
 满意度评分
 */
@property (nonatomic, assign) KFRatingScore ratingScore;
/**
 意见
 */
@property (nullable, nonatomic, copy) NSString *ratingContent;
/**
 满意度字符串
 */
+ (nullable NSString *)stringForRatingScore:(KFRatingScore)ratingScore;

@end
