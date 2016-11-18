//
//  KFTicket.m
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import "KFTicket.h"
#import "KFHelper.h"

@implementation KFTicket

+ (instancetype)ticketWithDict:(NSDictionary *)dict{
    KFTicket *ticket = [[KFTicket alloc]init];
    ticket.ticket_id = [dict kf5_numberForKeyPath:@"id"].integerValue;
    ticket.title = [dict kf5_stringForKeyPath:@"title"];
    ticket.status = [dict kf5_numberForKeyPath:@"status"].integerValue;
    ticket.ticket_description = [dict kf5_stringForKeyPath:@"description"];
    ticket.created_at = [dict kf5_numberForKeyPath:@"created_at"].doubleValue;
    ticket.updated_at = [dict kf5_numberForKeyPath:@"updated_at"].doubleValue;
    ticket.due_date = [dict kf5_numberForKeyPath:@"due_date"].doubleValue;
    ticket.lastComment_id = [dict kf5_numberForKeyPath:@"last_comment_id"].doubleValue;
    return ticket;
}

+ (NSArray<KFTicket *> *)ticketsWithDictArray:(NSArray<NSDictionary *> *)dictArray{    
    NSMutableArray *tickets = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *dict in dictArray) {
        KFTicket *object = [KFTicket ticketWithDict:dict];
        [tickets addObject:object];
    }
    return tickets;
}

@end
