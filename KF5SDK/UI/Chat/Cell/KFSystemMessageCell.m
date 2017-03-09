//
//  KFSystemMessageCell.m
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import "KFSystemMessageCell.h"
#import "KFHelper.h"

@interface KFSystemMessageCell()<KFLabelDelegate>

@end

@implementation KFSystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CALayer *backgroundLayer = [CALayer layer];
        backgroundLayer.cornerRadius = 5.0;
        backgroundLayer.backgroundColor = KF5Helper.KF5ChatSystemCellTimeLabelBackgroundColor.CGColor;
        [self.contentView.layer addSublayer:backgroundLayer];
        _backgroundLayer = backgroundLayer;
        
        KFLabel *systemMessageLabel = [[KFLabel alloc] init];
        systemMessageLabel.labelDelegate = self;
        systemMessageLabel.numberOfLines = 0;
        [self.contentView addSubview:systemMessageLabel];
        _systemMessageLabel = systemMessageLabel;
    }
    return self;
}

- (void)clickLabelWithInfo:(NSDictionary *)info{
    if ([self.cellDelegate respondsToSelector:@selector(cell:clickLabelWithInfo:)]) {
        [self.cellDelegate cell:self clickLabelWithInfo:info];
    }
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    _systemMessageLabel.textLayout = messageModel.systemTextLayout;
    _systemMessageLabel.frame = messageModel.systemFrame;
    _backgroundLayer.frame = messageModel.systemBackgroundFrame;
}


@end
