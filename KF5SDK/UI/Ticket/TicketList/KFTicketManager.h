//
//  KFTicketManager.h
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import <Foundation/Foundation.h>
@class KFTicket;
@interface KFTicketManager : NSObject
/**
 保存工单最后一条回复的id,用于处理刷新工单的未读红点

 @param ticket_id      工单id
 @param lastComment_id 最后一条回复的id
 */
+ (void)saveTicketNewDateWithTicket:(NSInteger)ticket_id lastComment:(NSInteger)lastComment_id;
/**
 判断是否有新回复

 @param ticket 工单

 @return YES为有新回复
 */
+ (BOOL)hasNewCommentWithTicket:(KFTicket *)ticket;
/**
 清除保存的数据,切换用户时使用
 */
+ (void)cleanData;

@end
