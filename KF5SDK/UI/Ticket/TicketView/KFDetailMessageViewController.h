//
//  KFDetailMessageViewController.h
//  Pods
//
//  Created by admin on 16/9/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "KFBaseViewController.h"

@interface KFDetailMessageViewController : KFBaseTableViewController
/**
 *  初始化方法
 *
 *  @param ticket_id 工单的id
 */
- (instancetype)initWithTicket_id:(NSInteger)ticket_id;

@end
