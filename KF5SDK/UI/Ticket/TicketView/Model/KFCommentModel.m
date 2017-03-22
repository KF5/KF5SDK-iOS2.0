//
//  KFCommentModel.m
//  Pods
//
//  Created by admin on 16/11/4.
//
//

#import "KFCommentModel.h"
#import "KFContentLabelHelp.h"
#import "KFHelper.h"

@interface KFCommentModel()

@property (nullable, nonatomic, strong) NSAttributedString *text;

@end

@implementation KFCommentModel

- (instancetype)initWithComment:(KFComment *)comment{
    self = [super init];
    if (self) {
        _comment = comment;
        [self setupData];
        [self updateFrame];
    }
    return self;
}

- (void)setupData{
    // 内容
    _text = [KFContentLabelHelp baseMessageWithString:_comment.content labelHelpHandle:KFLabelHelpHandleHttp|KFLabelHelpHandlePhone|KFLabelHelpHandleATag font:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5TitleColor urlColor:KF5Helper.KF5OtherURLColor];
    
    // 附件
    _attachments = _comment.attachments;
    // 时间
    _timeText = [NSDate kf5_stringFromDate:[NSDate dateWithTimeIntervalSince1970:_comment.created]];
    // 头像
    _headerImage = _comment.messageFrom == KFMessageFromMe ? KF5Helper.endUserImage : KF5Helper.agentImage;
    // 昵称
    _name = _comment.author_name;
}

- (void)updateFrame{
    // 内容
    CGFloat maxWidth = KF5SCREEN_WIDTH - KF5Helper.KF5HorizSpacing * 2;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxWidth, MAXFLOAT)];
    _textLayout = [YYTextLayout layoutWithContainer:container text:_text];
    CGSize textSize = _textLayout.textBoundingSize;
    
    _textFrame = CGRectMake(KF5Helper.KF5HorizSpacing, KF5Helper.KF5VerticalSpacing, maxWidth, textSize.height);
    // 附件,如果没有附件,则与内容的上间距为0
    if (_attachments.count == 0) {
        _attViewFrame = CGRectMake(CGRectGetMinX(_textFrame), CGRectGetMaxY(_textFrame), maxWidth, 0);
    }else{
        NSInteger row = (int)(_attachments.count - 1) / 3 + 1;
        _attViewFrame = CGRectMake(CGRectGetMinX(_textFrame), CGRectGetMaxY(_textFrame)+ KF5Helper.KF5DefaultSpacing, maxWidth, maxWidth / 3 * row);
    }
    // 时间
    CGSize timeSize = [KFHelper sizeWithText:_timeText font:KF5Helper.KF5NameFont maxSize:CGSizeMake(200, KF5Helper.KF5TimeFont.lineHeight)];
    _timeFrame = CGRectMake(CGRectGetMinX(_textFrame), CGRectGetMaxY(_attViewFrame)+KF5Helper.KF5DefaultSpacing, timeSize.width, timeSize.height);
    CGSize nameSize =  [KFHelper sizeWithText:_name font:KF5Helper.KF5NameFont maxSize:CGSizeMake(120, KF5Helper.KF5TimeFont.lineHeight)];;
    // 头像
    CGFloat imageLength = 20;
    _headerFrame = CGRectMake(KF5SCREEN_WIDTH - KF5Helper.KF5HorizSpacing - nameSize.width - 5 - 20, CGRectGetMidY(_timeFrame) - imageLength/2, imageLength, imageLength);
    // 昵称
    _nameFrame = CGRectMake(CGRectGetMaxX(_headerFrame) + 5, CGRectGetMinY(_timeFrame), nameSize.width, nameSize.height);
    
    _cellHeight = CGRectGetMaxY(_nameFrame)+ KF5Helper.KF5VerticalSpacing;
    // loadView
    _loadViewFrame = CGRectMake(0, _cellHeight / 2 - 10, 20, 20);
}

@end
