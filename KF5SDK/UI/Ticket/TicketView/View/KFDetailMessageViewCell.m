//
//  KFDetailMessageViewCell.m
//  Pods
//
//  Created by admin on 16/11/9.
//
//

#import "KFDetailMessageViewCell.h"

#import "KFHelper.h"

@interface KFDetailMessageViewCell()

@property (nonatomic, strong) NSNumber *cellHeight;
/**
 *  详细信息项
 */
@property (nonatomic, strong) NSDictionary *detailMessageDcit;

@end

@implementation KFDetailMessageViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    // 标题
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = KF5Helper.KF5TitleFont;
    titleLabel.textColor = KF5Helper.KF5TitleColor;
    titleLabel.numberOfLines = 0;
    self.titleLabel = titleLabel;
    [self.contentView addSubview:titleLabel];
    
    // 内容
    UILabel *contentLabel = [[UILabel alloc]init];
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.font = KF5Helper.KF5TitleFont;
    contentLabel.textColor = KF5Helper.KF5NameColor;
    contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail ;
    self.contentLabel = contentLabel;
    [self.contentView addSubview:contentLabel];
}

- (void)setTicketFieldModel:(KFTicketFieldModel *)ticketFieldModel{
    _titleLabel.text = ticketFieldModel.title;
    _titleLabel.frame = ticketFieldModel.titleFrame;
    
    _contentLabel.text = ticketFieldModel.content;
    _contentLabel.frame = ticketFieldModel.contentFrame;
}

@end
