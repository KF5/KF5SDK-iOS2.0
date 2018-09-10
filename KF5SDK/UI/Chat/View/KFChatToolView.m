//
//  KFChatToolView.m
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import "KFChatToolView.h"
#import "KFCategory.h"
#import "KFTextView.h"
#import "KFFaceBoardView.h"
#import "KFRecordView.h"

/**输入框最大高度*/
static const CGFloat kKF5MaxHeight = 130;
/**按钮的宽度*/
static const CGFloat kKF5ChatToolBtnWidth  = 28;
/**转接客服的按钮宽度*/
static CGFloat kKF5ChatToolDefaultTextViewHeight = 35.5;

typedef NS_ENUM(NSInteger,KFChatShowType){//键盘与工具视图的显示状态
    KFChatShowTypeDefault = 0,
    KFChatShowTypeKeyBoard,
    KFChatShowTypeVoice,
    KFChatShowTypeFaceView
};

@interface KFChatToolView()<KFTextViewDelegate>

/**表情视图*/
@property (nonatomic, strong) KFFaceBoardView *faceBoardView;

@property (nonatomic,strong) NSLayoutConstraint *heightLayout;

@property (nonatomic, assign) KFChatShowType showType;

@end

@implementation KFChatToolView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = KF5Helper.KF5ChatToolViewBackgroundColor;
        
        [self setupView];
        [self layoutView];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)statusBarOrientationChange:(NSNotification *)notification{
    if (self.showType == KFChatShowTypeFaceView) {
        self.showType = KFChatShowTypeDefault;
        [self.textView resignFirstResponder];
    }
    self.textView.inputView = nil;
    self.faceBoardView = nil;
}

- (void)setupView{
    // 语音按钮
    UIButton * voiceBtn = [[UIButton alloc]init];
    [voiceBtn setImage:KF5Helper.chatTool_voice forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceBtn];
    self.voiceBtn = voiceBtn;
    
    // 图片按钮
    UIButton * pictureBtn = [[UIButton alloc]init];
    [pictureBtn setImage:KF5Helper.chatTool_picture forState:UIControlStateNormal];
    [pictureBtn addTarget:self action:@selector(clickPictureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pictureBtn];
    self.pictureBtn = pictureBtn;
    
    // 表情按钮
    UIButton * faceBtn = [[UIButton alloc]init];
    [faceBtn setImage:KF5Helper.chatTool_face forState:UIControlStateNormal];
    [faceBtn addTarget:self action:@selector(clickFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:faceBtn];
    self.faceBtn = faceBtn;
    
    // 转接人工客服按钮
    UIButton * transferBtn = [[UIButton alloc]init];
    transferBtn.titleLabel.font = KF5Helper.KF5TitleFont;
    transferBtn.backgroundColor = self.backgroundColor;
    transferBtn.layer.borderColor = [KF5Helper.KF5ChatToolTextViewBorderColor CGColor];
    transferBtn.layer.borderWidth = 0.5;
    transferBtn.layer.cornerRadius = 5.0;
    [transferBtn setTitle:KF5Localized(@"kf5_ai_to_agent") forState:UIControlStateNormal];
    [transferBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColor forState:UIControlStateNormal];
    [transferBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColorH forState:UIControlStateHighlighted];
    [transferBtn addTarget:self action:@selector(clickTransferBtn:) forControlEvents:UIControlEventTouchUpInside];
    transferBtn.hidden = YES;
    [self addSubview:transferBtn];
    self.transferBtn = transferBtn;
    
    // 文本输入框
    KFTextView *textView = [[KFTextView alloc]init];
    textView.canEmoji = YES;
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
    UIButton *speakBtn = [[UIButton alloc]init];
    [speakBtn addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    [speakBtn addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside];
    [speakBtn addTarget:self action:@selector(recordComplete) forControlEvents:UIControlEventTouchUpInside];
    [speakBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [speakBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragInside];
    [speakBtn addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchCancel];
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
}

- (KFFaceBoardView *)faceBoardView{
    if (!_faceBoardView) {
        // 表情视图
        _faceBoardView = [[KFFaceBoardView alloc]init];
        __weak KFChatToolView *weakSelf = self;
        [_faceBoardView setSendBlock:^() {
            if ([weakSelf.delegate respondsToSelector:@selector(chatToolView:shouldSendContent:)]) {
                [weakSelf.delegate chatToolView:weakSelf shouldSendContent:weakSelf.textView.text];
            }
            // 清空textView
            [weakSelf.textView cleanText];
        }];
        [_faceBoardView setDeleteBlock:^() {
            [weakSelf.textView deleteBackward];
        }];
        // 点击表情
        [_faceBoardView setClickBlock:^(NSString * _Nonnull text) {
            [weakSelf.textView insertText:text];
        }];
    }
    return _faceBoardView;
}

- (void)layoutView{
    [self.voiceBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.width.kf_equal(kKF5ChatToolBtnWidth);
        make.height.kf_equal(kKF5ChatToolBtnWidth);
        make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.centerY.kf_equalTo(self.speakBtn);
    }];
    
    [self.textView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5ChatToolTextViewTopSpacing).priority(UILayoutPriorityDefaultHigh);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5ChatToolTextViewTopSpacing);
        make.left.kf_equalTo(self.voiceBtn.kf5_right).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.right.kf_equalTo(self.faceBtn.kf5_left).kf_offset(-KF5Helper.KF5DefaultSpacing);
        self.textView.heightLayout = make.height.kf_equal(self.textView.textHeight).active;
    }];
    
    [self.faceBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.width.kf_equalTo(self.voiceBtn);
        make.height.kf_equalTo(self.voiceBtn);
        make.centerY.kf_equalTo(self.voiceBtn);
        make.right.kf_equalTo(self.pictureBtn.kf5_left).kf_offset(-KF5Helper.KF5DefaultSpacing);
    }];

    [self.pictureBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.width.kf_equalTo(self.voiceBtn);
        make.height.kf_equalTo(self.voiceBtn);
        make.centerY.kf_equalTo(self.voiceBtn);
        make.right.kf_equalTo(self.kf5_right).kf_offset(-KF5Helper.KF5DefaultSpacing);
    }];
    [self.transferBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.height.kf_equal(kKF5ChatToolDefaultTextViewHeight);
        make.width.kf_equal(63);
        make.centerY.kf_equalTo(self.voiceBtn);
    }];
    [self.speakBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self.textView);
        make.bottom.kf_equalTo(self.textView);
        make.right.kf_equalTo(self.textView);
        make.height.kf_equal(self.textView.textHeight);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.heightLayout) {
        self.heightLayout = [[KFAutoLayoutMaker alloc] initWithFirstItem:self firstAttribute:NSLayoutAttributeHeight].kf_equal(self.frame.size.height).priority(UILayoutPriorityDefaultHigh).active;
        self.heightLayout.active = NO;
    }
}

#pragma mark 聊天状态
- (void)layoutForChattingView{
    [self.textView kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5ChatToolTextViewTopSpacing).priority(UILayoutPriorityDefaultHigh);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5ChatToolTextViewTopSpacing);
        make.left.kf_equalTo(self.voiceBtn.kf5_right).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.right.kf_equalTo(self.faceBtn.kf5_left).kf_offset(-KF5Helper.KF5DefaultSpacing);
        self.textView.heightLayout = make.height.kf_equal(self.textView.textHeight).active;
    }];
    
    self.voiceBtn.hidden = self.faceBtn.hidden = self.pictureBtn.hidden = self.textView.hidden = NO;
    self.transferBtn.hidden = self.speakBtn.hidden = YES;
    self.textView.placeholderText = nil;
    [self.textView setEditable:YES];
}
#pragma mark 机器人客服状态
- (void)layoutForAIView{
    
    [self.textView kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5ChatToolTextViewTopSpacing).priority(UILayoutPriorityDefaultHigh);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5ChatToolTextViewTopSpacing);
        make.left.kf_equalTo(self.transferBtn.kf5_right).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.right.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing);
        self.textView.heightLayout = make.height.kf_equal(self.textView.textHeight).active;
    }];
    
    self.voiceBtn.hidden = self.faceBtn.hidden = self.pictureBtn.hidden = YES;
    self.transferBtn.hidden = NO;
    // 隐藏语音按钮
    if (self.voiceBtn.tag == 1) [self clickVoiceBtn:self.voiceBtn];
    
    self.textView.placeholderText = nil;
    [self.textView setEditable:YES];
}
#pragma mark 分配前先输入内容状态
- (void)layoutForAfterQueueView{
    // 只有输入框
    [self.textView kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5ChatToolTextViewTopSpacing);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5ChatToolTextViewTopSpacing);
        make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.right.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing);
        self.textView.heightLayout = make.height.kf_equal(self.textView.textHeight).active;
    }];
    self.voiceBtn.hidden = self.faceBtn.hidden = self.pictureBtn.hidden = self.transferBtn.hidden = YES;
    // 隐藏语音按钮
    if (self.voiceBtn.tag == 1) [self clickVoiceBtn:self.voiceBtn];
    self.textView.placeholderText = KF5Localized(@"kf5_input_some_text");
    [self.textView setEditable:YES];
}

- (void)setChatToolViewType:(KFChatStatus)chatToolViewType{
    _chatToolViewType = chatToolViewType;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.chatToolViewType == KFChatStatusNone) {
            if (self.assignAgentWhenSendedMessage) {
                [self layoutForAfterQueueView];
            }else{
                [self layoutForChattingView];
            }
        }else if (self.chatToolViewType == KFChatStatusChatting || self.chatToolViewType == KFChatStatusQueue){
            [self layoutForChattingView];
        }else if (self.chatToolViewType == KFChatStatusAIAgent){
            [self layoutForAIView];
        }
    });
}

#pragma mark - 录音操作
//按下操作---开始录音
-(void)recordStart {
    [self recordView].dragSide = kKF5DragSideNone;
    if ([KFHelper canRecordVoice]) {
        [self showRecordView];
        if ([self.delegate respondsToSelector:@selector(chatToolViewStartVoice:)]) {
            [self.delegate chatToolViewStartVoice:self];
        }
    }
}
//按钮外抬起操作---录音取消
-(void)recordCancel {
    [self removeRecordView];
    if ([self.delegate respondsToSelector:@selector(chatToolViewCancelVoice:)])
        [self.delegate chatToolViewCancelVoice:self];
}
//按钮内抬起操作---录音停止
-(void)recordComplete {
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
    if ([recordView isKindOfClass:[KFRecordView class]]) return recordView;
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

- (void)setShowType:(KFChatShowType)showType{
    if (_showType == showType)return;
    _showType = showType;
    
    [self.voiceBtn setImage:showType == KFChatShowTypeVoice ? KF5Helper.chatTool_keyBoard : KF5Helper.chatTool_voice forState:UIControlStateNormal];
    [self.faceBtn setImage:showType == KFChatShowTypeFaceView ? KF5Helper.chatTool_keyBoard : KF5Helper.chatTool_face forState:UIControlStateNormal];
    self.speakBtn.hidden = showType != KFChatShowTypeVoice;
    self.textView.hidden = showType == KFChatShowTypeVoice;
    self.voiceBtn.tag = showType == KFChatShowTypeVoice;
    self.faceBtn.tag = showType == KFChatShowTypeFaceView;
    [self.heightLayout setActive:showType == KFChatShowTypeVoice];
    if (showType == KFChatShowTypeDefault || showType == KFChatShowTypeVoice) {
        [self.textView resignFirstResponder];
    }else{
        self.textView.inputView = showType == KFChatShowTypeFaceView ? self.faceBoardView : nil;
        [self.textView reloadInputViews];
        [self.textView becomeFirstResponder];
    }
}

#pragma mark - 按钮点击事件
// 点击语音按钮
- (void)clickVoiceBtn:(UIButton *)btn{
    if (btn.tag == 0) {
        if ([self.delegate respondsToSelector:@selector(chatToolViewWithClickVoiceAction:)]) {
            BOOL canSend = [self.delegate chatToolViewWithClickVoiceAction:self];
            if (!canSend) return;
        }
    }
    self.showType = btn.tag == 0 ? KFChatShowTypeVoice : KFChatShowTypeKeyBoard;
}
// 点击表情按钮
- (void)clickFaceBtn:(UIButton *)btn{
    self.showType = btn.tag == 0 ? KFChatShowTypeFaceView : KFChatShowTypeKeyBoard;
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
