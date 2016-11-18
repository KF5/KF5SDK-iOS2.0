//
//  KFTicketModel.m
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import "KFTicketModel.h"
#import "KFHelper.h"
#import "KFTicketManager.h"
#import "KFTicket.h"

@implementation KFTicketModel

- (instancetype)initWithTicket:(KFTicket *)ticket{
    self = [super init];
    if (self) {
        _ticket = ticket;
        _content = _ticket.ticket_description;
        _time = [NSDate dateWithTimeIntervalSince1970:ticket.created_at].kf5_string;
        [self setStatusString:_ticket.status];
        [self updateFrame];
    }
    return self;
}

- (void)setStatusString:(KFTicketStatus)status{
    switch (status) {
        case KFTicketStatusNew:
            _status = KF5Localized(@"kf5_ticket_status_New");
            break;
        case KFTicketStatusOpen:
            _status = KF5Localized(@"kf5_ticket_status_Open");
            break;
        case KFTicketStatusPending:
            _status = KF5Localized(@"kf5_ticket_status_Pending");
            break;
        case KFTicketStatusSolved:
            _status = KF5Localized(@"kf5_ticket_status_Solved");
            break;
        case KFTicketStatusClosed:
            _status = KF5Localized(@"kf5_ticket_status_Closed");
            break;
            
        default:
            break;
    }
}

- (void)updateFrame{
    // 是否有新回复,需要动态获取
    _newComment = [KFTicketManager hasNewCommentWithTicket:_ticket];
    
    CGSize contentSize = [KFHelper sizeWithText:_content font:KF5Helper.KF5TitleFont maxSize:CGSizeMake(KF5SCREEN_WIDTH - KF5Helper.KF5HorizSpacing * 3, KF5Helper.KF5TitleFont.lineHeight * 2)];
    _contentFrame = CGRectMake(KF5Helper.KF5HorizSpacing, KF5Helper.KF5DefaultSpacing, contentSize.width, contentSize.height);
    
    CGSize timeSize = [KFHelper sizeWithText:_time font:KF5Helper.KF5NameFont];
    _timeFrame = CGRectMake(CGRectGetMinX(_contentFrame), CGRectGetMaxY(_contentFrame) + KF5Helper.KF5DefaultSpacing, timeSize.width, timeSize.height);
    
    CGSize statusSize = [KFHelper sizeWithText:_status font:KF5Helper.KF5NameFont];
    _statusFrame = CGRectMake(KF5SCREEN_WIDTH - KF5Helper.KF5HorizSpacing * 2 - statusSize.width, CGRectGetMinY(_timeFrame), statusSize.width, statusSize.height);
    
    _cellHeight = KF5Helper.KF5DefaultSpacing + contentSize.height + KF5Helper.KF5DefaultSpacing + timeSize.height + KF5Helper.KF5DefaultSpacing;
    
    _pointViewFrame = CGRectMake((CGRectGetMinX(_contentFrame) - KF5Helper.KF5TicketPointViewWitdh)/2, (_cellHeight - KF5Helper.KF5TicketPointViewWitdh)/2, KF5Helper.KF5TicketPointViewWitdh, KF5Helper.KF5TicketPointViewWitdh);
}



@end
