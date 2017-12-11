//
//  KFSystemMessageCell.m
//  Pods
//
//  Created by admin on 16/10/31.
//
//

#import "KFSystemMessageCell.h"
#import "KFHelper.h"
#import "KFLabel.h"

@interface KFSystemMessageCell()

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
        systemMessageLabel.linkTextAttributes = @{NSForegroundColorAttributeName:KF5Helper.KF5OtherURLColor};
        __weak typeof(self)weakSelf = self;
        systemMessageLabel.linkTapBlock = ^(KFLabel *label, NSDictionary *value) {
            if ([weakSelf.cellDelegate respondsToSelector:@selector(cell:clickLabelWithInfo:)]) {
                [weakSelf.cellDelegate cell:weakSelf clickLabelWithInfo:value];
            }
        };
        [self.contentView addSubview:systemMessageLabel];
        _systemMessageLabel = systemMessageLabel;
    }
    return self;
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    _systemMessageLabel.attributedText = messageModel.systemText;
    _systemMessageLabel.frame = messageModel.systemFrame;
    _backgroundLayer.frame = messageModel.systemBackgroundFrame;
}


@end
