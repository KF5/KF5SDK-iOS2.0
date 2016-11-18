//
//  KFTicketListTableViewCell.m
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import "KFTicketListViewCell.h"
#import "KFHelper.h"

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
        self.pointView = pointView;
        
        UILabel *contentLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5TitleColor];
        contentLabel.numberOfLines = 2;
        [self.contentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        UILabel *timeLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:KF5Helper.KF5NameColor];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UILabel *statusLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:KF5Helper.KF5NameColor];
        [self.contentView addSubview:statusLabel];
        self.statusLabel = statusLabel;
    }
    return self;
}

- (void)setTicketModel:(KFTicketModel *)ticketModel{
    _ticketModel = ticketModel;
    
    self.contentLabel.text = ticketModel.content;
    self.contentLabel.frame = ticketModel.contentFrame;
    
    self.timeLabel.text = ticketModel.time;
    self.timeLabel.frame = ticketModel.timeFrame;
    
    self.statusLabel.text = ticketModel.status;
    self.statusLabel.frame = ticketModel.statusFrame;
    
    self.pointView.hidden = !ticketModel.hasNewComment;
    self.pointView.frame = ticketModel.pointViewFrame;
}

@end
