//
//  KFTicketFieldModel.m
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import "KFTicketFieldModel.h"
#import "KFHelper.h"

@implementation KFTicketFieldModel

- (instancetype)initWithTicketFieldDict:(NSDictionary *)ticketFieldDict{
    self = [super init];
    if (self) {
        _ticketFieldDict = ticketFieldDict;
        _title = [ticketFieldDict kf5_stringForKeyPath:@"name"];
        _content = [ticketFieldDict kf5_stringForKeyPath:@"value"];
        [self updateFrame];
    }
    return self;
}

- (void)updateFrame{
    CGFloat maxWidth = (KF5SCREEN_WIDTH - KF5Helper.KF5HorizSpacing * 2 - KF5Helper.KF5MiddleSpacing)/2;
    CGSize titleSize = [KFHelper sizeWithText:_title font:KF5Helper.KF5TitleFont maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
    CGSize contentSize = [KFHelper sizeWithText:_content font:KF5Helper.KF5TitleFont maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
    
    CGFloat maxHeight = MAX(titleSize.height, contentSize.height);
    
    _titleFrame = CGRectMake(KF5Helper.KF5HorizSpacing, KF5Helper.KF5VerticalSpacing, maxWidth, maxHeight);
    _contentFrame = CGRectMake(CGRectGetMaxX(_titleFrame)+KF5Helper.KF5MiddleSpacing, CGRectGetMinY(_titleFrame), maxWidth, maxHeight);
    
    _cellHeight = KF5Helper.KF5VerticalSpacing * 2 + maxHeight;
}

@end
