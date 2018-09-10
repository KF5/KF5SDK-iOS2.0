//
//  KFTicketListTableViewCell.m
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import "KFTicketListViewCell.h"
#import "KFCategory.h"
#import "KFTicketManager.h"

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
        make.centerX.kf_equalTo(superview.kf5_left).kf_offset(KF5Helper.KF5HorizSpacing/2);
        make.centerY.kf_equalTo(superview.kf5_centerY);
        make.height.kf_equal(KF5Helper.KF5TicketPointViewWitdh);
        make.width.kf_equal(KF5Helper.KF5TicketPointViewWitdh);
    }];
    
    [_contentLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.top.kf_equalTo(superview).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.left.kf_equalTo(superview).kf_offset(KF5Helper.KF5HorizSpacing);
        make.right.kf_equalTo(superview);
    }];

    [_timeLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.left.kf_equalTo(self.contentLabel);
        make.top.kf_equalTo(self.contentLabel.kf5_bottom).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.bottom.kf_equalTo(superview).kf_offset(-KF5Helper.KF5DefaultSpacing);
    }];
    
    [_statusLabel kf5_makeConstraints:^(KFAutoLayout *make) {
        make.centerY.kf_equalTo(self.timeLabel);
        make.left.kf_greaterThanOrEqualTo(self.timeLabel.kf5_right).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.right.kf_equalTo(self.contentLabel);
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
