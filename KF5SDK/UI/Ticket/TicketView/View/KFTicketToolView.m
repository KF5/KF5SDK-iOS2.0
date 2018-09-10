//
//  KFTicketToolView.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFTicketToolView.h"
#import "KFCategory.h"

static const CGFloat kKF5MaxHeight = 130;

@interface KFCloseView: UIView
@end

@interface KFTicketToolView()<KFTextViewDelegate>

@property (nonatomic,strong) NSLayoutConstraint *heightLayout;

@end

@implementation KFTicketToolView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self layoutView];
        self.userInteractionEnabled = YES;
        _type = KFTicketToolTypeInputText;
    }
    return self;
}

- (void)setupView{
    self.backgroundColor = KF5Helper.KF5BgColor;
    // 1.附件视图
    KFAttView *attView = [[KFAttView alloc]init];
    attView.hidden = YES;
    attView.backgroundColor = KF5Helper.KF5BgColor;
    [self addSubview:attView];
    _attView = attView;
    
    __weak typeof(self)weakSelf = self;
    attView.closeViewBlock = ^{
        weakSelf.type = KFTicketToolTypeInputText;
    };
    attView.addImageBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(toolViewAddAttachment:)])
            [weakSelf.delegate toolViewAddAttachment:weakSelf];
    };
    
    // 2.输入视图
    KFTicketInputView *inputView = [[KFTicketInputView alloc]init];
    [inputView.attBtn addTarget:self action:@selector(att:) forControlEvents:UIControlEventTouchUpInside];
    inputView.textView.textDelegate = self;
    [self addSubview:inputView];
    _inputView = inputView;
    
    // 3.关闭视图
    KFCloseView *closeView = [[KFCloseView alloc]init];
    closeView.hidden = YES;
    [self addSubview:closeView];
    _closeView = closeView;
}

- (void)layoutView {
    [_attView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing/2);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing/2);
        make.right.kf_equalTo(self.kf5_left);
        make.width.kf_equalTo(self);
    }];
    
    [_inputView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self);
        make.bottom.kf_equalTo(self);
        make.left.kf_equalTo(self);
        make.width.kf_equalTo(self);
    }];
    
    [_closeView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self);
        make.bottom.kf_equalTo(self);
        make.left.kf_equalTo(self);
        make.right.kf_equalTo(self);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.heightLayout) {
        self.heightLayout = [[KFAutoLayoutMaker alloc] initWithFirstItem:self firstAttribute:NSLayoutAttributeHeight].kf_equal(self.frame.size.height).active;
        self.heightLayout.active = NO;
    }
}

- (void)setType:(KFTicketToolType)type{
    if (type == _type) return;
    
    _type = type;
    
    self.closeView.hidden = type != KFTicketToolTypeClose;
    self.heightLayout.active = type != KFTicketToolTypeInputText;
    
    if (type == KFTicketToolTypeClose){
        self.backgroundColor = [UIColor whiteColor];
        return;
    }
    if (type == KFTicketToolTypeAddImage) {
        self.attView.hidden = NO;
        // 如果点击添加附件按钮时,记录下键盘的状态,tag = 1 为键盘在弹出,等关闭附件添加控件时,再恢复状态
        if ([self.inputView.textView isFirstResponder]) {
            self.attView.tag = 1;
            [self.inputView.textView resignFirstResponder];
        }
    }else {
        self.inputView.hidden = NO;
        // 点击关闭附件按钮时,恢复键盘状态,tag = 1 为键盘在弹出,弹出键盘
        if (self.attView.tag) {
            [self.inputView.textView becomeFirstResponder];
            self.attView.tag = 0;
        }
    }
    [self.attView kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing/2);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing/2);
        make.width.kf_equalTo(self);
        if (type == KFTicketToolTypeAddImage) {
            make.left.kf_equalTo(self.kf5_left);
        }else{
            make.right.kf_equalTo(self.kf5_left);
        }
    }];
    [self.inputView kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self);
        make.bottom.kf_equalTo(self);
        make.width.kf_equalTo(self);
        if (type == KFTicketToolTypeAddImage) {
            make.left.kf_equalTo(self.kf5_right);
        }else{
            make.left.kf_equalTo(self.kf5_left);
        }
    }];

    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.attView.hidden = type != KFTicketToolTypeAddImage;
        self.inputView.hidden = type != KFTicketToolTypeInputText;
    }];
}

#pragma mark - 按钮点击事件
- (void)att:(UIButton *)btn{
    self.type = KFTicketToolTypeAddImage;
}

#pragma mark - textViewDelegate
- (BOOL)kf5_textView:(KFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        if ([self.delegate respondsToSelector:@selector(toolView:senderMessage:)])
            [self.delegate toolView:self senderMessage:textView.text];
        
        [textView cleanText];
        self.attView.images = nil;
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }else{
        if ([self.delegate respondsToSelector:@selector(toolViewWithTextDidChange:)]) {
            [self.delegate toolViewWithTextDidChange:self];
        }
    }
    return YES;
}

@end

@implementation KFCloseView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UILabel *closeLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5NameColor];
        [self addSubview:closeLabel];
        closeLabel.layer.cornerRadius = 3;
        closeLabel.layer.masksToBounds = YES;
        closeLabel.backgroundColor = KF5Helper.KF5BgColor;
        closeLabel.text = KF5Localized(@"kf5_ticket_closed");
        closeLabel.textAlignment = NSTextAlignmentCenter;
        
        [closeLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5ChatToolTextViewTopSpacing);
            make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5VerticalSpacing);
            make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5ChatToolTextViewTopSpacing);
            make.right.kf_equalTo(self).kf_offset(-KF5Helper.KF5VerticalSpacing);
        }];
    }
    return self;
}
@end

@implementation KFTicketInputView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = KF5Helper.KF5BgColor;
        // 附件按钮
        UIButton *attBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [attBtn setImage:KF5Helper.ticketTool_openAtt forState:UIControlStateNormal];
        [self addSubview:attBtn];
        _attBtn = attBtn;
        // 输入框
        KFTextView *textView = [[KFTextView alloc]init];
        textView.layer.borderColor = KF5Helper.KF5BgColor.CGColor;
        textView.layer.borderWidth = 1.5;
        textView.layer.cornerRadius = 5.0;
        textView.maxTextHeight = kKF5MaxHeight;
        textView.returnKeyType = UIReturnKeySend;
        textView.enablesReturnKeyAutomatically = YES;
        textView.showsVerticalScrollIndicator = NO;
        textView.showsHorizontalScrollIndicator = NO;
        [self addSubview:textView];
        _textView = textView;
        
        [attBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.left.kf_equalTo(self);
            make.width.kf_equal(30);
            make.height.kf_equal(30);
            make.centerY.kf_equalTo(self);
        }];
        
        [textView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.left.kf_equalTo(attBtn.kf5_right);
            make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5ChatToolTextViewTopSpacing);
            make.right.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing);
            make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5ChatToolTextViewTopSpacing).priority(UILayoutPriorityDefaultHigh);
            textView.heightLayout = make.height.kf_equal(textView.textHeight).active;
        }];
    }
    return self;
}

@end
