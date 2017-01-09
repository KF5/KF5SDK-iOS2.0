//
//  KFTicketToolView.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFTicketToolView.h"
#import "KFHelper.h"

static CGFloat kKF5ChatToolDefaultTextViewHeight = 35.5;
static const CGFloat kKF5MaxHeight = 130;

@interface KFTicketToolView()<KFTextViewDelegate,KFAttViewDelegate>

@end

@implementation KFTicketToolView


+ (CGFloat)defaultHeight{
    return kKF5ChatToolDefaultTextViewHeight + KF5Helper.KF5ChatToolTextViewTopSpacing * 2;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.userInteractionEnabled = YES;
        [self addObserver:self forKeyPath:@"textView.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)setupView{
    // 1.附件视图
    KFAttView *attView = [[KFAttView alloc]initWithFrame:self.bounds];
    attView.backgroundColor = KF5Helper.KF5BgColor;
    attView.degelate = self;
    [self addSubview:attView];
    self.attView = attView;
    
    // 2.输入视图
    UIView *inputView = [[UIView alloc]initWithFrame:self.bounds];
    inputView.backgroundColor = KF5Helper.KF5BgColor;
    [self addSubview:inputView];
    self.inputView = inputView;
    // 附件按钮
    UIButton *attBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    attBtn.frame = CGRectMake(0, 0, 32, inputView.kf5_h);
    [attBtn setImage:KF5Helper.ticketTool_openAtt forState:UIControlStateNormal];
    [attBtn addTarget:self action:@selector(att:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:attBtn];
    self.attBtn = attBtn;
    // 输入框
    CGFloat textViewX = CGRectGetMaxX(attBtn.frame);
    CGFloat textViewWidth = self.kf5_w - textViewX - KF5Helper.KF5DefaultSpacing;
    KFTextView *textView = [[KFTextView alloc]initWithFrame:CGRectMake(textViewX, KF5Helper.KF5ChatToolTextViewTopSpacing, textViewWidth, kKF5ChatToolDefaultTextViewHeight)];
    textView.layer.borderColor = KF5Helper.KF5BgColor.CGColor;
    textView.layer.borderWidth = 1.5;
    textView.layer.cornerRadius = 5.0;
    textView.maxTextHeight = kKF5MaxHeight;
    textView.font = KF5Helper.KF5TitleFont;
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;
    textView.textDelegate = self;
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    [inputView addSubview:textView];
    self.textView = textView;
    
    // 3.关闭视图
    UIView *closeView = [[UIView alloc]initWithFrame:self.bounds];
    closeView.backgroundColor = [UIColor whiteColor];
    UILabel *closeLabel = [[UILabel alloc]init];
    closeLabel.frame = CGRectMake(0, 0, closeView.kf5_w - KF5Helper.KF5VerticalSpacing * 2, closeView.kf5_h - KF5Helper.KF5ChatToolTextViewTopSpacing * 2);
    closeLabel.center = closeView.center;
    closeLabel.layer.cornerRadius = 3;
    closeLabel.layer.masksToBounds = YES;
    closeLabel.backgroundColor = KF5Helper.KF5BgColor;
    closeLabel.text = KF5Localized(@"kf5_ticket_closed");
    closeLabel.font = KF5Helper.KF5TitleFont;
    closeLabel.textColor = KF5Helper.KF5NameColor;
    closeLabel.textAlignment = NSTextAlignmentCenter;
    closeView.hidden = YES;
    [closeView addSubview:closeLabel];
    [self addSubview:closeView];
    self.closeView = closeView;
}

- (void)updateFrame{
    self.textView.kf5_w = self.kf5_w - CGRectGetMaxX(self.attBtn.frame) - KF5Helper.KF5DefaultSpacing;
    self.textView.kf5_h = self.textView.textHeight;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"textView.frame"] && !CGRectEqualToRect(((NSValue *)change[NSKeyValueChangeNewKey]).CGRectValue, ((NSValue *)change[NSKeyValueChangeOldKey]).CGRectValue)) {
        CGFloat h =  self.textView.kf5_h + KF5Helper.KF5ChatToolTextViewTopSpacing * 2;
        CGFloat y = CGRectGetMaxY(self.frame) - h;
        self.frame = CGRectMake(self.kf5_x, y, self.kf5_w, h);
        self.attView.frame = self.bounds;
        self.inputView.frame = self.bounds;
        self.attBtn.kf5_h = self.kf5_h;
    }
}

- (void)setType:(KFTicketToolType)type{
    _type = type;
    
    switch (type) {
        case KFTicketToolTypeInputText:
            self.closeView.hidden = YES;
            self.textView.kf5_h = self.textView.textHeight;
            
            break;
        case KFTicketToolTypeAddImage:
            self.closeView.hidden = YES;
            self.textView.kf5_h = kKF5ChatToolDefaultTextViewHeight;
            
            break;
        case KFTicketToolTypeClose:
            self.closeView.hidden = NO;
            self.textView.kf5_h = kKF5ChatToolDefaultTextViewHeight;
            break;
            
        default:
            break;
    }
}

#pragma mark - 按钮点击事件
- (void)att:(UIButton *)btn{
    self.type = KFTicketToolTypeAddImage;
    // 如果点击添加附件按钮时,记录下键盘的状态,tag = 1 为键盘在弹出,等关闭附件添加控件时,再恢复状态
    if ([self.textView isFirstResponder]) {
        self.attView.tag = 1;
        [self.textView resignFirstResponder];
    }else{
        self.attView.tag = 0;
    }
    self.attView.frame = CGRectOffset(self.attView.frame, -self.frame.size.width, 0);
    [UIView animateWithDuration:0.3f animations:^{
        self.inputView.frame = CGRectOffset(self.inputView.frame, self.frame.size.width, 0);
        self.attView.frame = CGRectOffset(self.attView.frame, self.frame.size.width, 0);
    }completion:^(BOOL finished) {
        self.inputView.hidden = YES;
    }];
}

#pragma mark - attViewDelegate
- (void)attViewcloseAction:(KFAttView *)attView{
    self.type = KFTicketToolTypeInputText;
    // 点击关闭附件按钮时,恢复键盘状态,tag = 1 为键盘在弹出,弹出键盘
    if (![self.textView isFirstResponder] && attView.tag) {
        [self.textView becomeFirstResponder];
    }
    attView.tag = 0;
    
    self.inputView.hidden = NO;
    self.inputView.kf5_x = self.kf5_w;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.inputView.frame = CGRectOffset(self.inputView.frame, -self.frame.size.width, 0);
        attView.frame = CGRectOffset(attView.frame, -self.frame.size.width, 0);
    }completion:^(BOOL finished) {
        attView.frame = CGRectOffset(attView.frame, self.frame.size.width, 0);
    }];
}
- (void)attViewAddAction:(KFAttView *)attView{
    if ([self.delegate respondsToSelector:@selector(toolViewAddAttachment:)])
        [self.delegate toolViewAddAttachment:self];
}

#pragma mark - textViewDelegate
- (void)kf5_textViewDidChange:(KFTextView *)textView{
    if (textView.text.length > 0) {
        // 禁止系统表情的输入
        NSString *text = [KFHelper disable_emoji:[textView text]];
        if (![text isEqualToString:textView.text]) {
            NSRange textRange = [textView selectedRange];
            textView.text = text;
            [textView setSelectedRange:textRange];
        }
    }
    // 计算 text view 的高度
    [UIView animateWithDuration:0.1f animations:^{
        textView.kf5_h = textView.textHeight;
    }];
}
- (BOOL)kf5_textView:(KFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        if ([self.delegate respondsToSelector:@selector(toolView:senderMessage:)])
            [self.delegate toolView:self senderMessage:self.textView.text];
        
        [self.textView cleanText];
        [self.attView removeImages];
        self.textView.kf5_h = self.textView.textHeight;
        
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"textView.frame"];
}

@end
