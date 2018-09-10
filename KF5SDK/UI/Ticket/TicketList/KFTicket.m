//
//  KFTicket.m
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import "KFTicket.h"
#import "KFCategory.h"

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

- (nullable NSString *)statusString{
    NSString *statusStr = nil;
    switch (self.status) {
        case KFTicketStatusNew:
            statusStr = KF5Localized(@"kf5_ticket_status_New");
            break;
        case KFTicketStatusOpen:
            statusStr = KF5Localized(@"kf5_ticket_status_Open");
            break;
        case KFTicketStatusPending:
            statusStr = KF5Localized(@"kf5_ticket_status_Pending");
            break;
        case KFTicketStatusSolved:
            statusStr = KF5Localized(@"kf5_ticket_status_Solved");
            break;
        case KFTicketStatusClosed:
            statusStr = KF5Localized(@"kf5_ticket_status_Closed");
            break;
        default:
            break;
    }
    return statusStr;
}

@end
