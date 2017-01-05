//
//  KFTicketHeaderView.m
//  Pods
//
//  Created by admin on 16/12/30.
//
//

#import "KFTicketHeaderView.h"
#import "KFHelper.h"

@interface KFTicketHeaderView()

@property (nullable, nonatomic, weak) UILabel *titleLabel;
@property (nullable, nonatomic, weak) UIImageView *accessoryView;

@end

@implementation KFTicketHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = KF5Helper.KF5BgColor;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = KF5Localized(@"kf5_rate");
        titleLabel.font = KF5Helper.KF5TitleFont;
        titleLabel.textColor = KF5Helper.KF5BlueColor;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UILabel *ratingLabel = [[UILabel alloc] init];
        ratingLabel.textAlignment = NSTextAlignmentCenter;
        ratingLabel.font = KF5Helper.KF5NameFont;
        ratingLabel.textColor = [UIColor whiteColor];
        ratingLabel.backgroundColor = KF5Helper.KF5SatifiedColor;
        ratingLabel.layer.cornerRadius = 3;
        ratingLabel.layer.masksToBounds = YES;
        ratingLabel.hidden = YES;
        [self addSubview:ratingLabel];
        _ratingLabel = ratingLabel;
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:self.arrowImage];
        accessoryView.contentMode = UIViewContentModeCenter;
        [self addSubview:accessoryView];
        _accessoryView = accessoryView;
    }
    return self;
}

- (UIImage *)arrowImage{
    static UIImage *arrowImage = nil;
    if (arrowImage ==nil) {
        arrowImage = [UIImage kf5_drawArrowImageWithColor:KF5Helper.KF5BlueColor size:CGSizeMake(13, 21)];
    }
    return arrowImage;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake( KF5Helper.KF5DefaultSpacing, 0, 200, self.frame.size.height);
    
    CGFloat accessoryWidth = 13;
    self.accessoryView.frame = CGRectMake(self.frame.size.width - accessoryWidth - KF5Helper.KF5MiddleSpacing, 0, accessoryWidth, self.frame.size.height);
    
    CGSize ratingSize = [KFHelper sizeWithText:self.ratingLabel.text font:self.ratingLabel.font];
    CGFloat ratingWidth = ratingSize.width + KF5Helper.KF5MiddleSpacing;
    CGFloat ratingHeight = ratingSize.height + KF5Helper.KF5DefaultSpacing;
    self.ratingLabel.frame = CGRectMake(self.accessoryView.frame.origin.x - ratingWidth - KF5Helper.KF5MiddleSpacing, (self.frame.size.height - ratingHeight)/2, ratingWidth, ratingHeight);
    
    self.ratingLabel.hidden = !self.ratingLabel.text.length;
}


@end
