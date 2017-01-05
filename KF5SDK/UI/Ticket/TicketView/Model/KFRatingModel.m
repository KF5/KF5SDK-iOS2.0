//
//  KFRatingModel.m
//  KF5SDKUI2.0
//
//  Created by admin on 16/12/30.
//  Copyright © 2016年 kf5. All rights reserved.
//

#import "KFRatingModel.h"
#import "KFHelper.h"

@implementation KFRatingModel

+ (NSString *)stringForRatingScore:(KFRatingScore)ratingScore{
    switch (ratingScore) {
        case KFRatingScoreBad:
            return KF5Localized(@"kf5_bad");
            break;
        case KFRatingScoreSoso:
            return KF5Localized(@"kf5_soso");
            break;
        case KFRatingScoreOk:
            return KF5Localized(@"kf5_ok");
            break;
        case KFRatingScoreGood:
            return KF5Localized(@"kf5_good");
            break;
        case KFRatingScoreGreat:
            return KF5Localized(@"kf5_great");
            break;
        default:
            return nil;
            break;
    }
}

@end
