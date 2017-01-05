//
//  KFRatingViewController.h
//  Pods
//
//  Created by admin on 16/12/30.
//
//

#import "KFBaseViewController.h"
#import "KFRatingModel.h"

@interface KFRatingViewController : KFBaseViewController

@property (nullable, nonatomic, copy) void(^completionBlock)( KFRatingModel * _Nonnull ratingModel);

- (nonnull instancetype)initWithTicket_id:(NSInteger)ticket_id ratingModel:(nonnull KFRatingModel *)ratingModel;

@end
