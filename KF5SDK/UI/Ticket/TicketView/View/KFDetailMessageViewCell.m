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
        [self setupView];
        [self layoutView];
    }
    return self;
}

- (void)setupView{
    // 标题
    UILabel *titleLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5TitleColor];
    titleLabel.numberOfLines = 0;
    _titleLabel = titleLabel;
    [self.contentView addSubview:titleLabel];
    
    // 内容
    UILabel *contentLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5NameColor];
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentLabel = contentLabel;
    [self.contentView addSubview:contentLabel];
}

- (void)layoutView{
    UIView *superView = self.contentView;
    [_titleLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(superView).kf_offset(KF5Helper.KF5MiddleSpacing);
        make.left.kf_equalTo(superView).kf_offset(KF5Helper.KF5HorizSpacing);
        make.right.kf_greaterThanOrEqualTo(self.contentLabel.kf5_left).kf_offset(-KF5Helper.KF5DefaultSpacing);
        make.bottom.kf_equalTo(superView).kf_offset(-KF5Helper.KF5MiddleSpacing);
    }];
    [_contentLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.centerY.kf_equalTo(self.titleLabel);
        make.right.kf_equalTo(superView).kf_offset(-KF5Helper.KF5HorizSpacing);
    }];
}

- (void)setTicketFieldDict:(NSDictionary *)ticketFieldDict{
    _ticketFieldDict = ticketFieldDict;
    _titleLabel.text = [ticketFieldDict kf5_stringForKeyPath:@"name"];
    _contentLabel.text = [ticketFieldDict kf5_stringForKeyPath:@"value"];
}

@end
