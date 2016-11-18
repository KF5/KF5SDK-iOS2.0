//
//  KFChatViewCell.m
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import "KFChatViewCell.h"

@implementation KFChatViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
