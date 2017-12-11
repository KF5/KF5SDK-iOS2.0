//
//  KFMessageModel.m
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import "KFMessageModel.h"
#import "KFHelper.h"
#import "KFContentLabelHelp.h"
#import "KFChatVoiceManager.h"

// 时间标记,用于计算是否显示cell时间
static double KF5TimeStamp = 0;
static double KF5MaxImageWidth = 100;
static double KF5MaxImageHeight = 200;

BOOL isShowTime(double time){
    BOOL show = KF5TimeStamp == 0 ? YES : ( fabs(time - KF5TimeStamp) > 60);
    if (show) KF5TimeStamp = time;
    return show;
}

@interface KFMessageModel()

@end

@implementation KFMessageModel

- (instancetype)initWithMessage:(KFMessage *)message{
    self = [super init];
    if (self) {
        _message = message;
        [self setupData];
        [self updateFrame];
    }
    return self;
}

- (void)setupData{
    
    if (self.isContentMessage) {
        _showTime = isShowTime(_message.created);
        if (_showTime) {
           _timeText =  [NSDate kf5_stringForDisplayFromDate:[NSDate dateWithTimeIntervalSince1970:_message.created]];
        }
        
        if (_message.messageType == KFMessageTypeCard) {
            _cardDict = [KFHelper dictWithJSONString: self.message.content];
            return;
        }
        if (_message.messageFrom == KFMessageFromMe) {
            _headerImage = KF5Helper.endUserImage;
            _messageViewBgImage = KF5Helper.chat_ctnMeBg;
            _messageViewBgImageH = KF5Helper.chat_ctnMeBgH;
        }else{
            _headerImage = KF5Helper.agentImage;
            _messageViewBgImage = KF5Helper.chat_ctnOtherBg;
            _messageViewBgImageH = KF5Helper.chat_ctnOtherBgH;
        }
        UIFont *font = KF5Helper.KF5TitleFont;
        UIColor *color = _message.messageFrom == KFMessageFromMe ? [UIColor whiteColor] : KF5Helper.KF5TitleColor;

        if (_message.messageType == KFMessageTypeText) {
            _text = [KFContentLabelHelp baseMessageWithString:_message.content font:font color:color];
        }if (_message.messageType == KFMessageTypeCustom){
            _text = [KFContentLabelHelp customMessageWithJSONString:_message.content font:font color:color];
        }else if(_message.messageType == KFMessageTypeOther){
            _text = [KFContentLabelHelp documentStringWithString:_message.content urlString:_message.url font:font color:color];
        }else if (_message.messageType == KFMessageTypeImage){
            if (_message.local_path.length > 0)
                _image = [[UIImage imageWithContentsOfFile:_message.local_path] kf5_imageScalingForSize:CGSizeMake(KF5MaxImageWidth, KF5MaxImageHeight)];
        }else if (_message.messageType == KFMessageTypeVoice){
            if (_message.local_path.length > 0) {
                _voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:_message.local_path];
            }else{
                if (_message.url.length > 0) {
                    [[KFChatVoiceManager sharedChatVoiceManager]downloadDataWithMessageModel:self];
                }
            }
        }
    }else{
        _systemText = [KFContentLabelHelp systemMessageWithString:_message.content font:KF5Helper.KF5TimeFont color:[UIColor whiteColor]];
    }
}

- (void)updateFrame{
    
    CGFloat screenWidth = KFHelper.safe_mainFrame.size.width;
    
    if (self.isContentMessage) {
        if (_showTime) {
            CGSize timeSize = [KFHelper sizeWithText:_timeText font:KF5Helper.KF5TimeFont maxSize:CGSizeMake(screenWidth, MAXFLOAT)];
            _timeFrame = CGRectMake(0, 0, screenWidth, timeSize.height);
        }
        if (_message.messageType == KFMessageTypeCard) {
            [self updateCardFrame:screenWidth];
            return;
        }
        
        _headerFrame = CGRectMake(KF5Helper.KF5MiddleSpacing, CGRectGetMaxY(_timeFrame) + KF5Helper.KF5DefaultSpacing, KF5Helper.KF5ChatCellHeaderHeight, KF5Helper.KF5ChatCellHeaderHeight);
        
        CGSize messageSize = CGSizeZero;
        
        if (_message.messageType == KFMessageTypeImage){
            CGFloat scaleFactor = MIN(KF5MaxImageWidth/_message.imageWidth, KF5MaxImageHeight/_message.imageHeight);
            scaleFactor = scaleFactor > 1 ? 1 :scaleFactor;
            messageSize = CGSizeMake(_message.imageWidth *scaleFactor, _message.imageHeight*scaleFactor);
            if (CGSizeEqualToSize(messageSize, CGSizeZero)) {
                messageSize = CGSizeMake(100, 100);
            }
        }else if(_message.messageType == KFMessageTypeVoice){
            CGFloat width = (_voiceLength > 60 ? 60 : _voiceLength) / 60.0 * 170;
            messageSize = CGSizeMake(width < 50 ? 50 : width, 15);
        }else{
            messageSize = [self.text boundingRectWithSize:CGSizeMake(screenWidth-160, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        }
        
        _messageBgViewFrame = CGRectMake(CGRectGetMaxX(_headerFrame) +KF5Helper.KF5DefaultSpacing, CGRectGetMinY(_headerFrame), messageSize.width + KF5Helper.KF5ChatCellMessageBtnInsterLeftRight * 2 + KF5Helper.KF5ChatCellMessageBtnArrowWidth,messageSize.height + KF5Helper.KF5ChatCellMessageBtnInsterTopBottom * 2);
        
        _messageViewFrame = CGRectMake(CGRectGetMinX(_messageBgViewFrame) + KF5Helper.KF5ChatCellMessageBtnInsterLeftRight + KF5Helper.KF5ChatCellMessageBtnArrowWidth, CGRectGetMinY(_messageBgViewFrame) + KF5Helper.KF5ChatCellMessageBtnInsterTopBottom, messageSize.width, messageSize.height);
        
        _loadViewFrame = CGRectMake(CGRectGetMaxX(_messageBgViewFrame) + KF5Helper.KF5DefaultSpacing, CGRectGetMidY(_messageBgViewFrame) - 10, 20,20);
        
        _cellHeight = ceilf(CGRectGetMaxY(_messageBgViewFrame) + KF5Helper.KF5DefaultSpacing);
        
        if (_message.messageFrom == KFMessageFromMe) {
            _headerFrame.origin.x = screenWidth - CGRectGetMaxX(_headerFrame);
            _messageBgViewFrame.origin.x = screenWidth - CGRectGetMaxX(_messageBgViewFrame);
            _messageViewFrame.origin.x = screenWidth - CGRectGetMaxX(_messageViewFrame);
            _loadViewFrame.origin.x = screenWidth - CGRectGetMaxX(_loadViewFrame);
        }
    }else{
        CGSize systemSize = [self.systemText boundingRectWithSize:CGSizeMake(screenWidth-100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        _systemFrame = CGRectMake((screenWidth - systemSize.width) / 2 , 5, systemSize.width, systemSize.height);
        _systemBackgroundFrame = CGRectMake(_systemFrame.origin.x - 5, _systemFrame.origin.y - 5, _systemFrame.size.width + 10, _systemFrame.size.height + 10);
        
        _cellHeight = ceilf(CGRectGetMaxY(_systemBackgroundFrame) + KF5Helper.KF5DefaultSpacing);
    }
}
#pragma mark 卡片消息的frame
- (void)updateCardFrame:(CGFloat)screenWidth{
    _cardImageFrame = CGRectMake(KF5Helper.KF5MiddleSpacing, KF5Helper.KF5MiddleSpacing, 60, 60);
    CGFloat x = CGRectGetMaxX(_cardImageFrame) + KF5Helper.KF5DefaultSpacing;
    CGFloat width = screenWidth - x - KF5Helper.KF5MiddleSpacing;
    _cardTitleFrame = CGRectMake(x, CGRectGetMinY(_cardImageFrame), width, 40);
    _cardPriceFrame = CGRectMake(x, CGRectGetMaxY(_cardTitleFrame), width, 20);
    
    CGFloat maxWidth = screenWidth - KF5Helper.KF5MiddleSpacing * 4;
    
    CGSize size = [KFHelper sizeWithText:_cardDict[@"link_title"] font:KF5Helper.KF5TitleFont];
    CGFloat linkWidth = MAX(80, MIN(maxWidth, size.width)) + KF5Helper.KF5MiddleSpacing * 2;
    _cardLinkBtnFrame = CGRectMake((screenWidth - linkWidth) / 2, CGRectGetMaxY(_cardImageFrame) + KF5Helper.KF5DefaultSpacing, linkWidth, 30);
    
    _cellHeight = CGRectGetMaxY(_cardLinkBtnFrame) + KF5Helper.KF5MiddleSpacing;
}


- (BOOL)isContentMessage{
    return _message.messageType != KFMessageTypeSystem;
}

@end
