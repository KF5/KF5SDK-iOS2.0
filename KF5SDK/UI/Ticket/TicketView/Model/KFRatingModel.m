//
//  KFRatingModel.m
//  KF5SDKUI2.0
//
//  Created by admin on 16/12/30.
//  Copyright © 2016年 kf5. All rights reserved.
//

#import "KFRatingModel.h"
#import "KFHelper.h"

@interface KFRatingModel()

@property (nonnull, nonatomic,strong, readwrite)NSArray <NSNumber *> *rateLevelArray;

@end

@implementation KFRatingModel

- (NSArray<NSNumber *> *)rateLevelArray{
    if (_rateLevelArray == nil) {
        if (self.rateLevelCount == 2) {
            _rateLevelArray = @[@(KFTicketRatingScoreGreat), @(KFTicketRatingScoreBad)];
        }else if (self.rateLevelCount == 3) {
            _rateLevelArray = @[@(KFTicketRatingScoreGreat), @(KFTicketRatingScoreOk),@(KFTicketRatingScoreBad)];
        }else {
            _rateLevelArray = @[@(KFTicketRatingScoreGreat),@(KFTicketRatingScoreGood),@(KFTicketRatingScoreOk),@(KFTicketRatingScoreSoso),@(KFTicketRatingScoreBad)];
        }
    }
    return _rateLevelArray;
}

+ (NSString *)stringForRatingScore:(KFTicketRatingScore)ratingScore{
    switch (ratingScore) {
        case KFTicketRatingScoreBad:
            return KF5Localized(@"kf5_bad");
            break;
        case KFTicketRatingScoreSoso:
            return KF5Localized(@"kf5_soso");
            break;
        case KFTicketRatingScoreOk:
            return KF5Localized(@"kf5_ok");
            break;
        case KFTicketRatingScoreGood:
            return KF5Localized(@"kf5_good");
            break;
        case KFTicketRatingScoreGreat:
            return KF5Localized(@"kf5_great");
            break;
        default:
            return nil;
            break;
    }
}

@end
