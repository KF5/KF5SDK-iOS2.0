//
//  KFCardMessageCell.m
//  Pods
//
//  Created by admin on 2017/9/5.
//
//

#import "KFCardMessageCell.h"
#import "UIImageView+WebCache.h"

@interface KFCardMessageCell()

@property (nullable, nonatomic, copy) NSString *linkUrl;

@end

@implementation KFCardMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *headerImageView = [[UIImageView alloc] init];
        self.headerImageView = headerImageView;
        [self.contentView addSubview:headerImageView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 2;
        titleLabel.textColor = KF5Helper.KF5ChatCardCellTitleLabelTextColor;
        titleLabel.font = KF5Helper.KF5TitleFont;
        self.titleLabel = titleLabel;
        [self.contentView addSubview:titleLabel];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.font = KF5Helper.KF5ContentFont;
        priceLabel.textColor = KF5Helper.KF5ChatCardCellPriceLabelTextColor;
        self.priceLabel = priceLabel;
        [self.contentView addSubview:priceLabel];
        
        UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        linkBtn.titleLabel.font = KF5Helper.KF5TitleFont;
        [linkBtn setTitleColor:KF5Helper.KF5ChatCardCellLinkBtnTextColor forState:UIControlStateNormal];
        linkBtn.backgroundColor = KF5Helper.KF5ChatCardCellLinkBtnBackgroundColor;
        [linkBtn addTarget:self action:@selector(clickLinkBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.linkBtn = linkBtn;
        [self.contentView addSubview:linkBtn];
        self.backgroundColor = KF5Helper.KF5ChatCardCellBackgroundColor;
    }
    return self;
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    NSString *imgUrl = messageModel.cardDict[@"img_url"];
    NSString *title = messageModel.cardDict[@"title"];
    NSString *description = messageModel.cardDict[@"price"];
    NSString *link_title = messageModel.cardDict[@"link_title"];
    self.linkUrl = messageModel.cardDict[@"link_url"];
    
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:KF5Helper.placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    self.titleLabel.text = title;
    self.priceLabel.text = description;
    [self.linkBtn setTitle:link_title forState:UIControlStateNormal];
    
    self.headerImageView.frame = messageModel.cardImageFrame;
    self.titleLabel.frame = messageModel.cardTitleFrame;
    self.priceLabel.frame = messageModel.cardPriceFrame;
    self.linkBtn.frame = messageModel.cardLinkBtnFrame;
    self.linkBtn.layer.cornerRadius = CGRectGetHeight(self.linkBtn.frame) / 2;
}

- (void)clickLinkBtn:(UIButton *)linkBtn{
    if ([self.cellDelegate respondsToSelector:@selector(cell:clickCardLinkWithUrl:)]) {
        [self.cellDelegate cell:self clickCardLinkWithUrl:self.linkUrl];
    }
}


@end
