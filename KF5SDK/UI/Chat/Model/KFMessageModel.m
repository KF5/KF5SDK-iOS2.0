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

@property (nullable, nonatomic, strong) NSAttributedString *text;
@property (nullable, nonatomic, strong) NSAttributedString *systemText;

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
        UIColor *textColor = nil;
        UIColor *urlColor = nil;
        if (_message.messageFrom == KFMessageFromMe) {
            textColor = [UIColor whiteColor];
            urlColor = KF5Helper.KF5MeURLColor;
        }else{
            textColor = KF5Helper.KF5TitleColor;
            urlColor = KF5Helper.KF5OtherURLColor;
        }
        if (_message.messageType == KFMessageTypeText) {
            _text = [KFContentLabelHelp baseMessageWithString:_message.content labelHelpHandle:KFLabelHelpHandleHttp|KFLabelHelpHandlePhone|KFLabelHelpHandleATag font:font textColor:textColor urlColor:urlColor];
        }if (_message.messageType == KFMessageTypeCustom){
            _text = [KFContentLabelHelp customMessageWithJSONString:_message.content font:font textColor:textColor urlColor:urlColor];
        }else if(_message.messageType == KFMessageTypeOther){
            _text = [KFContentLabelHelp documentStringWithString:_message.content urlString:_message.url font:font urlColor:urlColor];
        }else if (_message.messageType == KFMessageTypeImage){
            if (_message.local_path.length > 0)
                _image = [[UIImage imageWithContentsOfFile:_message.local_path] kf5_imageScalingForSize:CGSizeMake(KF5MaxImageWidth, KF5MaxImageHeight)];
        }else if (_message.messageType == KFMessageTypeVoice){
            if (_message.local_path.length > 0) {
                _voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:_message.local_path];
            }else{
                if (_message.url.length > 0) {
                    __weak typeof(self)weakSelf = self;
                    [[KFChatVoiceManager sharedChatVoiceManager]downloadDataWithURL:_message.url completion:^(NSString * _Nullable local_path, NSError * _Nullable error) {
                        if (error) {
                            weakSelf.message.messageStatus = KFMessageStatusFailure;
                        }else{
                            weakSelf.message.local_path = local_path;
                            weakSelf.voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:local_path];
                            [weakSelf updateFrame];
                        }
                    }];
                }
            }
        }
    }else{
        _systemText = [KFContentLabelHelp systemMessageWithString:_message.content font:KF5Helper.KF5TimeFont textColor:[UIColor whiteColor] urlColor:KF5Helper.KF5OtherURLColor];
    }
}

- (void)updateFrame{
    
    if (self.isContentMessage) {
        if (_showTime) {
            CGSize timeSize = [KFHelper sizeWithText:_timeText font:KF5Helper.KF5TimeFont maxSize:CGSizeMake(KF5SCREEN_WIDTH, MAXFLOAT)];
            _timeFrame = CGRectMake(0, 0, KF5SCREEN_WIDTH, timeSize.height);
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
            YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(KF5SCREEN_WIDTH-160, MAXFLOAT)];
            _textLayout = [YYTextLayout layoutWithContainer:container text:_text];
            messageSize = _textLayout.textBoundingSize;
        }
        
        _messageBgViewFrame = CGRectMake(CGRectGetMaxX(_headerFrame) +KF5Helper.KF5DefaultSpacing, CGRectGetMinY(_headerFrame), messageSize.width + KF5Helper.KF5ChatCellMessageBtnInsterLeftRight * 2 + KF5Helper.KF5ChatCellMessageBtnArrowWidth,messageSize.height + KF5Helper.KF5ChatCellMessageBtnInsterTopBottom * 2);
        
        _messageViewFrame = CGRectMake(CGRectGetMinX(_messageBgViewFrame) + KF5Helper.KF5ChatCellMessageBtnInsterLeftRight + KF5Helper.KF5ChatCellMessageBtnArrowWidth, CGRectGetMinY(_messageBgViewFrame) + KF5Helper.KF5ChatCellMessageBtnInsterTopBottom, messageSize.width, messageSize.height);
        
        _loadViewFrame = CGRectMake(CGRectGetMaxX(_messageBgViewFrame) + KF5Helper.KF5DefaultSpacing, CGRectGetMidY(_messageBgViewFrame) - 10, 20,20);
        
        _cellHeight = ceilf(CGRectGetMaxY(_messageBgViewFrame) + KF5Helper.KF5DefaultSpacing);
        
        if (_message.messageFrom == KFMessageFromMe) {
            _headerFrame.origin.x = KF5SCREEN_WIDTH - CGRectGetMaxX(_headerFrame);
            _messageBgViewFrame.origin.x = KF5SCREEN_WIDTH - CGRectGetMaxX(_messageBgViewFrame);
            _messageViewFrame.origin.x = KF5SCREEN_WIDTH - CGRectGetMaxX(_messageViewFrame);
            _loadViewFrame.origin.x = KF5SCREEN_WIDTH - CGRectGetMaxX(_loadViewFrame);
        }
    }else{
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(KF5SCREEN_WIDTH-100, MAXFLOAT)];
        _systemTextLayout = [YYTextLayout layoutWithContainer:container text:_systemText];
        CGSize systemSize = _systemTextLayout.textBoundingSize;
        
        _systemFrame = CGRectMake((KF5SCREEN_WIDTH - systemSize.width) / 2 , 5, systemSize.width, systemSize.height);
        _systemBackgroundFrame = CGRectMake(_systemFrame.origin.x - 5, _systemFrame.origin.y - 5, _systemFrame.size.width + 10, _systemFrame.size.height + 10);
        
        _cellHeight = ceilf(CGRectGetMaxY(_systemBackgroundFrame) + KF5Helper.KF5DefaultSpacing);
    }
}


- (BOOL)isContentMessage{
    return _message.messageType != KFMessageTypeSystem;
}

@end
