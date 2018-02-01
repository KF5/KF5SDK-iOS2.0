//
//  KFTicketListTableViewCell.m
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import "KFTicketListViewCell.h"
#import "KFHelper.h"
#import "KFTicketManager.h"

#import "KFAutoLayout.h"

@implementation KFTicketListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *pointView = [[UIView alloc]init];
        pointView.layer.masksToBounds = YES;
        pointView.layer.cornerRadius = KF5Helper.KF5TicketPointViewWitdh / 2;
        pointView.backgroundColor = KF5Helper.KF5TicketPointColor;
        pointView.hidden = YES;
        [self.contentView addSubview:pointView];
        _pointView = pointView;
        
        UILabel *contentLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5TitleColor];
        contentLabel.numberOfLines = 2;
        [self.contentView addSubview:contentLabel];
        _contentLabel = contentLabel;
        
        UILabel *timeLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:KF5Helper.KF5NameColor];
        [self.contentView addSubview:timeLabel];
        _timeLabel = timeLabel;
        
        UILabel *statusLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:KF5Helper.KF5NameColor];
        [self.contentView addSubview:statusLabel];
        _statusLabel = statusLabel;
        
        [self layoutView];
        
    }
    return self;
}

- (void)layoutView{
    UIView *superview = self.contentView;
    [_pointView kf5_makeConstraints:^(KFAutoLayout *make) {
        make.centerX.equalTo(superview.kf5_left).offset(KF5Helper.KF5HorizSpacing/2);
        make.centerY.equalTo(superview.kf5_centerY);
        make.height.kf_equal(KF5Helper.KF5TicketPointViewWitdh);
        make.width.kf_equal(KF5Helper.KF5TicketPointViewWitdh);
    }];
    
    [_contentLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.top.equalTo(superview).offset(KF5Helper.KF5DefaultSpacing);
        make.left.equalTo(superview).offset(KF5Helper.KF5HorizSpacing);
        make.right.equalTo(superview);
    }];

    [_timeLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.left.equalTo(_contentLabel);
        make.top.equalTo(_contentLabel.kf5_bottom).offset(KF5Helper.KF5DefaultSpacing);
        make.bottom.equalTo(superview).offset(-KF5Helper.KF5DefaultSpacing);
    }];
    
    [_statusLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.centerY.equalTo(_timeLabel);
        make.left.greaterThanOrEqualTo(_timeLabel.kf5_right).offset(KF5Helper.KF5DefaultSpacing);
        make.right.equalTo(_contentLabel);
    }];
}

- (void)setTicket:(KFTicket *)ticket{
    _ticket = ticket;
    
    self.contentLabel.text = ticket.ticket_description;
    self.timeLabel.text = [NSDate dateWithTimeIntervalSince1970:ticket.created_at].kf5_string;
    self.statusLabel.text = ticket.statusString;
    self.pointView.hidden = ![KFTicketManager hasNewCommentWithTicket:ticket];
}

@end
