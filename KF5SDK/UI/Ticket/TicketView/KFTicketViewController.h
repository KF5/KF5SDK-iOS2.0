//
//  KFTicketViewController.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFBaseViewController.h"

@interface KFTicketViewController : KFBaseViewController

/** 工单是否被关闭*/
@property (nonatomic, assign) BOOL isClose;
/**工单id*/
@property (nonatomic, assign) NSInteger ticket_id;
/**
  初始化方法

 @param ticket_id 工单id
 @param isClose   工单是否为已关闭工单
 */
- (instancetype)initWithTicket_id:(NSInteger)ticket_id isClose:(BOOL)isClose;

@end
