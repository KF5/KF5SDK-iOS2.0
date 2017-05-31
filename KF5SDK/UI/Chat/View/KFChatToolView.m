//
//  KFChatToolView.m
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import "KFChatToolView.h"
#import "KFHelper.h"
#import "KFTextView.h"
#import "KFFaceBoardView.h"
#import "KFRecordView.h"

/**输入框最大高度*/
static const CGFloat kKF5MaxHeight = 130;
/**按钮的宽度*/
static const CGFloat kKF5ChatToolBtnWidth  = 28;
/**转接客服的按钮宽度*/
static CGFloat kKF5ChatToolDefaultTextViewHeight = 35.5;


@interface KFChatToolView()<KFTextViewDelegate>

/**表情视图*/
@property (nonatomic, strong) KFFaceBoardView *faceBoardView;

@end

@implementation KFChatToolView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = KF5Helper.KF5ChatToolViewBackgroundColor;
        
        [self setupView];
    }
    return self;
}

+ (CGFloat)defaultHeight{
    return kKF5ChatToolDefaultTextViewHeight + KF5Helper.KF5ChatToolTextViewTopSpacing * 2;
}

- (void)setupView{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = KF5Helper.KF5ChatToolViewLineColor;
    [self addSubview:lineView];
    
    // 语音按钮
    UIButton * voiceBtn = [[UIButton alloc]initWithFrame:CGRectMake(KF5Helper.KF5DefaultSpacing, 0, kKF5ChatToolBtnWidth, kKF5ChatToolBtnWidth)];
    voiceBtn.center = CGPointMake(voiceBtn.center.x, KFChatToolView.defaultHeight/2);
    voiceBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [voiceBtn setImage:KF5Helper.chatTool_voice forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceBtn];
    self.voiceBtn = voiceBtn;
    
    // 图片按钮
    CGFloat pictureBtnX = self.frame.size.width - kKF5ChatToolBtnWidth - KF5Helper.KF5DefaultSpacing;
    UIButton * pictureBtn = [[UIButton alloc]initWithFrame:CGRectMake(pictureBtnX, 0, kKF5ChatToolBtnWidth, kKF5ChatToolBtnWidth)];
    pictureBtn.center = CGPointMake(pictureBtn.center.x, KFChatToolView.defaultHeight/2);
    pictureBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [pictureBtn setImage:KF5Helper.chatTool_picture forState:UIControlStateNormal];
    [pictureBtn addTarget:self action:@selector(clickPictureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pictureBtn];
    self.pictureBtn = pictureBtn;
    
    // 表情按钮
    CGFloat faceBtnX = pictureBtnX - kKF5ChatToolBtnWidth - KF5Helper.KF5DefaultSpacing;
    UIButton * faceBtn = [[UIButton alloc]initWithFrame:CGRectMake(faceBtnX, 0, kKF5ChatToolBtnWidth, kKF5ChatToolBtnWidth)];
    faceBtn.center = CGPointMake(faceBtn.center.x, KFChatToolView.defaultHeight/2);
    faceBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [faceBtn setImage:KF5Helper.chatTool_face forState:UIControlStateNormal];
    [faceBtn addTarget:self action:@selector(clickFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:faceBtn];
    self.faceBtn = faceBtn;
    
    // 转接人工客服按钮
    UIButton * transferBtn = [[UIButton alloc]initWithFrame:CGRectMake(KF5Helper.KF5DefaultSpacing, 0, 63, kKF5ChatToolDefaultTextViewHeight)];
    transferBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    transferBtn.titleLabel.font = KF5Helper.KF5TitleFont;
    transferBtn.backgroundColor = self.backgroundColor;
    transferBtn.layer.borderColor = [KF5Helper.KF5ChatToolTextViewBorderColor CGColor];
    transferBtn.layer.borderWidth = 0.5;
    transferBtn.layer.cornerRadius = 5.0;
    transferBtn.center = CGPointMake(transferBtn.center.x, KFChatToolView.defaultHeight/2);
    [transferBtn setTitle:KF5Localized(@"kf5_ai_to_agent") forState:UIControlStateNormal];
    [transferBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColor forState:UIControlStateNormal];
    [transferBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColorH forState:UIControlStateHighlighted];
    [transferBtn addTarget:self action:@selector(clickTransferBtn:) forControlEvents:UIControlEventTouchUpInside];
    transferBtn.hidden = YES;
    [self addSubview:transferBtn];
    self.transferBtn = transferBtn;
    
    // 文本输入框
    CGFloat textViewX = CGRectGetMaxX(voiceBtn.frame) + KF5Helper.KF5DefaultSpacing;
    CGFloat textViewWidth = CGRectGetMinX(faceBtn.frame) - textViewX - KF5Helper.KF5DefaultSpacing;
    KFTextView *textView = [[KFTextView alloc]initWithFrame:CGRectMake(textViewX, KF5Helper.KF5ChatToolTextViewTopSpacing, textViewWidth, kKF5ChatToolDefaultTextViewHeight)];
    textView.maxTextHeight = kKF5MaxHeight;
    textView.placeholderTextColor = KF5Helper.KF5ChatToolPlaceholderTextColor;
    textView.layer.borderColor = [KF5Helper.KF5ChatToolTextViewBorderColor CGColor];
    textView.font = KF5Helper.KF5ChatTextFont;
    textView.layer.borderWidth = 0.5;
    textView.layer.cornerRadius = 5.0;
    textView.backgroundColor = KF5Helper.KF5ChatToolTextViewBackgroundColor;
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;
    textView.textDelegate = self;
    textView.showsHorizontalScrollIndicator = NO;
    [self addSubview:textView];
    self.textView = textView;
    
    // 说话按钮
    UIButton *speakBtn = [[UIButton alloc]initWithFrame:textView.frame];
    [speakBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [speakBtn addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [speakBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [speakBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [speakBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragInside];
    [speakBtn setTitle:KF5Localized(@"kf5_hold_to_speak") forState:UIControlStateNormal];
    [speakBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColor forState:UIControlStateNormal];
    [speakBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColorH forState:UIControlStateHighlighted];
    speakBtn.backgroundColor = self.backgroundColor;
    speakBtn.layer.borderColor = [KF5Helper.KF5ChatToolTextViewBorderColor CGColor];
    speakBtn.layer.borderWidth = 0.5;
    speakBtn.layer.cornerRadius = 5.0;
    speakBtn.hidden = YES;
    [self addSubview:speakBtn];
    self.speakBtn = speakBtn;
    
    // 表情视图
    self.faceBoardView = [[KFFaceBoardView alloc]init];
    __weak KFChatToolView *weakSelf = self;
    [self.faceBoardView setSendBlock:^() {
        if ([weakSelf.delegate respondsToSelector:@selector(chatToolView:shouldSendContent:)]) {
            [weakSelf.delegate chatToolView:weakSelf shouldSendContent:weakSelf.textView.text];
        }
        // 清空textView
        [weakSelf.textView cleanText];
    }];
    [self.faceBoardView setDeleteBlock:^() {
        [weakSelf.textView deleteBackward];
    }];
    // 点击表情
    [self.faceBoardView setClickBlock:^(NSString * _Nonnull text) {
        [weakSelf.textView insertText:text];
    }];
    
    [self addObserver:self forKeyPath:@"textView.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"textView.frame"]) {
        self.speakBtn.kf5_x = self.textView.kf5_x;
        self.speakBtn.kf5_w = self.textView.kf5_w;
    }
}

- (void)updateFrame{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (self.chatToolViewType) {
            case KFChatStatusNone:{
                if (self.assignAgentWhenSendedMessage) {
                    [self layoutForQueueView];
                }else{
                    [self layoutForChattingView];
                }
            }
                break;
                
            case KFChatStatusChatting:// 是人工客服,则隐藏"转人工客服"按钮
                [self layoutForChattingView];
                break;
                
            case KFChatStatusAIAgent:// 是机器人客服,隐藏语音按钮,图片按钮,表情按钮
                [self layoutForAIView];
                break;
                
            case KFChatStatusQueue:// 当前为排队状态
                [self layoutForQueueView];
                break;
                
            default:
                break;
        }
    });
    
    self.textView.kf5_h = self.textView.textHeight;
    
    CGFloat maxY = CGRectGetMaxY(self.frame);
    self.kf5_h = self.textView ? self.textView.kf5_h + KF5Helper.KF5ChatToolTextViewTopSpacing * 2 : KFChatToolView.defaultHeight;
    self.kf5_y = maxY - self.kf5_h;

}

- (void)layoutForChattingView{
    self.textView.kf5_x = CGRectGetMaxX(self.voiceBtn.frame) + KF5Helper.KF5DefaultSpacing;
    self.textView.kf5_w = CGRectGetMinX(self.faceBtn.frame) - self.textView.kf5_x - KF5Helper.KF5DefaultSpacing;
    
    self.voiceBtn.hidden = NO;
    self.faceBtn.hidden = NO;
    self.pictureBtn.hidden = NO;
    self.transferBtn.hidden = YES;
    self.speakBtn.hidden = YES;
    self.textView.hidden = NO;
    self.textView.placeholderText = nil;
    [self.textView setEditable:YES];
}

- (void)layoutForAIView{
    self.textView.kf5_x = CGRectGetMaxX(self.transferBtn.frame) + KF5Helper.KF5DefaultSpacing;
    self.textView.kf5_w = self.frame.size.width - self.textView.kf5_x - KF5Helper.KF5DefaultSpacing;
    
    self.voiceBtn.hidden = YES;
    self.faceBtn.hidden = YES;
    self.pictureBtn.hidden = YES;
    self.transferBtn.hidden = NO;
    // 隐藏语音按钮
    if (self.voiceBtn.tag == 1) [self clickVoiceBtn:self.voiceBtn];
    
    self.textView.placeholderText = nil;
    [self.textView setEditable:YES];
}

- (void)layoutForQueueView{
    self.textView.kf5_x = KF5Helper.KF5DefaultSpacing;
    self.textView.kf5_w = self.frame.size.width - self.textView.kf5_x - KF5Helper.KF5DefaultSpacing;
    
    self.voiceBtn.hidden = YES;
    self.faceBtn.hidden = YES;
    self.pictureBtn.hidden = YES;
    self.transferBtn.hidden = YES;
    // 隐藏语音按钮
    if (self.voiceBtn.tag == 1) [self clickVoiceBtn:self.voiceBtn];
    // 如果有这条消息,则不能再编辑内容
    if ([KFHelper hasChatQueueMessage]) {
        [self.textView resignFirstResponder];
        self.textView.placeholderText = KF5Localized(@"kf5_describe_the_problem");
        [self.textView setEditable:NO];
    }else{
        self.textView.placeholderText = KF5Localized(@"kf5_input_some_text");
        [self.textView setEditable:YES];
    }
}

- (void)setChatToolViewType:(KFChatStatus)chatToolViewType{
    _chatToolViewType = chatToolViewType;
    [self updateFrame];
}

#pragma mark - 录音操作
//按下操作---开始录音
-(void)recordButtonTouchDown {
    BOOL isShowRecordView = YES;
    if ([self.delegate respondsToSelector:@selector(chatToolViewStartVoice:)]) {
        isShowRecordView  = [self.delegate chatToolViewStartVoice:self];
    }
    if(isShowRecordView) [self showRecordView];
}
//按钮外抬起操作---录音停止
-(void)recordButtonTouchUpOutside {
    [self removeRecordView];
    if ([self.delegate respondsToSelector:@selector(chatToolViewCancelVoice:)])
        [self.delegate chatToolViewCancelVoice:self];
}
//按钮内抬起操作---录音停止
-(void)recordButtonTouchUpInside {
    [self removeRecordView];
    
    if ([self.delegate respondsToSelector:@selector(chatToolViewCompleteVoice:)])
        [self.delegate chatToolViewCompleteVoice:self];
}
//手指划出按钮---提示松手停止录音
-(void)recordDragOutside {
    [self recordView].dragSide = kKF5DragSideOut;
}
//手指划入按钮---取消提示
-(void)recordDragInside {
    [self recordView].dragSide = kKF5DragSideIn;
}
//录音显示的提示view
- (KFRecordView *)recordView{
    UIView *superView =  self.superview;
    KFRecordView *recordView = [superView viewWithTag:kKF5RecordViewTag];
    if ([recordView isKindOfClass:[KFRecordView class]]) {
        return recordView;
    }
    return nil;
}
/**移除RecordView*/
- (void)removeRecordView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            [self recordView].hidden = YES;
        }];
    });
}
/** 显示RecordView*/
- (void)showRecordView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            [self recordView].hidden = NO;
        }];
    });
}

#pragma mark - 按钮点击事件
// 点击语音按钮
- (void)clickVoiceBtn:(UIButton *)btn{
    if (self.faceBtn.tag == 1) {
        [self clickFaceBtn:self.faceBtn];
    }
    
    self.speakBtn.hidden = btn.tag;
    self.textView.hidden = !btn.tag;
    
    if (!btn.tag) { // 初始状态
        
        if ([self.delegate respondsToSelector:@selector(chatToolViewWithClickVoiceAction:)]) {
            BOOL canSend = [self.delegate chatToolViewWithClickVoiceAction:self];
            if (!canSend) return;
        }
        
        // 1. 改变图片
        [btn setImage:KF5Helper.chatTool_keyBoard forState:UIControlStateNormal];
        // 3. 改变toolView高度
        [self kf5_textViewDidChange:self.textView];
        // 4. 关闭键盘
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
            self.textView.tag = 1;
        }else{
            self.textView.tag = 0;
        }
        
        
    }else{
        [btn setImage:KF5Helper.chatTool_voice forState:UIControlStateNormal];
        
        [self kf5_textViewDidChange:self.textView];
        
        if (self.textView.tag) {
            [self.textView becomeFirstResponder];
        }
    }
    
    btn.tag = !btn.tag;
}
// 点击表情按钮
- (void)clickFaceBtn:(UIButton *)btn{
    if (self.voiceBtn.tag == 1) {
        [self clickVoiceBtn:self.voiceBtn];
    }
    
    if (btn.tag == 0) { // 为0,显示表情
        [btn setImage:KF5Helper.chatTool_keyBoard forState:UIControlStateNormal];
        self.textView.inputView = self.faceBoardView;
    }else{ // 为1,显示键盘
        [btn setImage:KF5Helper.chatTool_face forState:UIControlStateNormal];
        self.textView.inputView = nil;
    }
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder])
        [self.textView becomeFirstResponder];
    
    btn.tag = !btn.tag;
}
// 点击图片按钮
- (void)clickPictureBtn:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(chatToolViewWithAddPictureAction:)]) {
        [self.delegate chatToolViewWithAddPictureAction:self];
    }
}
// 点击转接人工客服按钮
- (void)clickTransferBtn:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(chatToolViewWithTransferAction:)]) {
        [self.delegate chatToolViewWithTransferAction:self];
    }
}

#pragma mark - textViewDelegate
- (void)kf5_textViewDidChange:(KFTextView *)textView{
    // 计算 text view 的高度
    [UIView animateWithDuration:0.1f animations:^{
        textView.kf5_h = textView.textHeight;
        CGFloat maxY = CGRectGetMaxY(self.frame);
        self.kf5_h = !textView.hidden ? textView.kf5_h + KF5Helper.KF5ChatToolTextViewTopSpacing * 2 : KFChatToolView.defaultHeight;
        self.kf5_y = maxY - self.kf5_h;
    }];
}

- (BOOL)kf5_textView:(KFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self.delegate respondsToSelector:@selector(chatToolView:didChangeReplacementText:)]){
        BOOL canSend = [self.delegate chatToolView:self didChangeReplacementText:text];
        if (!canSend) return NO;
    }
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        if ([self.delegate respondsToSelector:@selector(chatToolView:shouldSendContent:)])
            [self.delegate chatToolView:self shouldSendContent:textView.text];
        // 清空textView
        [textView cleanText];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"textView.frame"];
}

@end
