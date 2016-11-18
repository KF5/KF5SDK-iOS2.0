//
//  KFTicketModel.h
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import <UIKit/UIKit.h>

@class KFTicket;

@interface KFTicketModel : NSObject
///工单模型
@property (nonnull, nonatomic, strong) KFTicket *ticket;
///内容
@property (nullable, nonatomic, copy) NSString *content;
///时间
@property (nullable, nonatomic, copy) NSString *time;
///状态
@property (nullable, nonatomic, copy) NSString *status;
///是否有新回复
@property (nonatomic, assign,getter=hasNewComment) BOOL newComment;
///内容frame
@property (nonatomic, assign) CGRect contentFrame;
///时间frame
@property (nonatomic, assign) CGRect timeFrame;
///状态frame
@property (nonatomic, assign) CGRect statusFrame;
///红点frame
@property (nonatomic, assign) CGRect pointViewFrame;
///cell高度
@property (nonatomic, assign) CGFloat cellHeight;

- (nonnull instancetype)initWithTicket:(nonnull KFTicket *)ticket;

- (void)updateFrame;

@end
