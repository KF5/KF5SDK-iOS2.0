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
typedef NS_ENUM(NSInteger,KFTicketRatingScore) {
    KFTicketRatingScoreNone = 0,  // 未评价
    KFTicketRatingScoreBad,       // 不满意
    KFTicketRatingScoreSoso,      // 不太满意
    KFTicketRatingScoreOk,        // 一般
    KFTicketRatingScoreGood,      // 基本满意
    KFTicketRatingScoreGreat      // 满意
};

@interface KFRatingModel : NSObject
/**
 工单满意度评分
 */
@property (nonatomic, assign) KFTicketRatingScore ratingScore;
/**
 意见
 */
@property (nullable, nonatomic, copy) NSString *ratingContent;
/**
 满意度评价等级,三种级别可选,2/3/5,对应[1,5],[1,3,5],[1,2,3,4,5]
 */
@property (nonatomic, assign) NSInteger rateLevelCount;
/**
 要显示的满意度数组
 */
@property (nonnull, nonatomic,strong, readonly)NSArray <NSNumber *> *rateLevelArray;
/**
 满意度字符串
 */
+ (nullable NSString *)stringForRatingScore:(KFTicketRatingScore)ratingScore;

@end
