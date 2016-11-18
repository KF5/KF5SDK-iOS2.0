//
//  KFTicketManager.m
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import "KFTicketManager.h"
#import "KFHelper.h"
#import "KFTicket.h"

static NSString * const TicketIdentifier = @"KFTicketManagerIdentifier";

@implementation KFTicketManager

#pragma mark 保存lastComment_id
+ (void)saveTicketNewDateWithTicket:(NSInteger)ticket_id lastComment:(NSInteger)lastComment_id{
    if (ticket_id == 0 || lastComment_id == 0) return;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]valueForKey:TicketIdentifier]];
    [dict setObject:@(lastComment_id) forKey:[NSString stringWithFormat:@"%d",(int)ticket_id]];
    [[NSUserDefaults standardUserDefaults]setValue:dict forKey:TicketIdentifier];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
#pragma mark 判断是否有新回复
+ (BOOL)hasNewCommentWithTicket:(KFTicket *)ticket{
    if (ticket.lastComment_id == 0)return NO;
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]valueForKey:TicketIdentifier];
    NSInteger oldComment_id = [dict kf5_numberForKeyPath:[NSString stringWithFormat:@"%d",(int)ticket.ticket_id]].integerValue;
    if (oldComment_id == 0) {// 如果本地的为0,则说明暂时没有存储,先存储,并返回没有新回复
        [self saveTicketNewDateWithTicket:ticket.ticket_id lastComment:ticket.lastComment_id];
        return NO;
    }
    return oldComment_id != ticket.lastComment_id;
}
#pragma mark 清除数据
+ (void)cleanData{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:TicketIdentifier];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
