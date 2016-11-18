//
//  KFCreateTicketView.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFCreateTicketView.h"
#import "KFHelper.h"

static const CGFloat kKF5MinTextHeight = 60;

@interface KFCreateTicketView()<KFTextViewDelegate,KFImageViewDelegate,UIScrollViewDelegate>

@property (nullable, nonatomic, weak) id<KFCreateTicketViewDelegate> viewDelegate;

@end

@implementation KFCreateTicketView

- (instancetype)initWithFrame:(CGRect)frame viewDelegate:(id<KFCreateTicketViewDelegate>)viewDelegate{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 文本框
        KFTextView *textView = [[KFTextView alloc] init];
        textView.font = KF5Helper.KF5TitleFont;
        textView.placeholderText = KF5Localized(@"kf5_edittext_hint");
        textView.placeholderTextColor = KF5Helper.KF5CreateTicketPlaceholderTextColor;
        textView.textDelegate = self;
        textView.scrollEnabled = NO;
        [self addSubview:textView];
        _textView = textView;
        
        // 图片
        KFImageView *photoImageView = [[KFImageView alloc]init];
        photoImageView.delegate = self;
        [self addSubview:photoImageView];
        _photoImageView = photoImageView;
        
        // 添加图片按钮
        UIButton *attBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [attBtn setImage:KF5Helper.ticket_createAtt forState:UIControlStateNormal];
        [attBtn addTarget:self action:@selector(addAtt:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:attBtn];
        _attBtn = attBtn;
        
        self.alwaysBounceVertical = YES;
        self.delegate = self;
        _viewDelegate = viewDelegate;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [self addGestureRecognizer:tap];
        
        [self addObserver:self forKeyPath:@"photoImageView.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self updateFrame];
    }
    return self;
}

- (void)updateFrame{
    // textView
    CGFloat textHeight = _textView.textHeight;
    textHeight = textHeight<kKF5MinTextHeight?kKF5MinTextHeight:textHeight;
    _textView.frame = CGRectMake(KF5Helper.KF5DefaultSpacing, KF5Helper.KF5DefaultSpacing, self.kf5_w - KF5Helper.KF5DefaultSpacing * 2, textHeight);
    // photoImageView的frame改变,就会通知改变attBtn的frame,以及self.contentSize
    _photoImageView.kf5_w = _textView.kf5_w;
    
    _photoImageView.frame = CGRectMake(_textView.kf5_x, CGRectGetMaxY(_textView.frame), _textView.kf5_w, _photoImageView.imageViewHeight);
    
    [_photoImageView updateFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (([keyPath isEqualToString:@"photoImageView.frame"] || [keyPath isEqualToString:@"frame"]) && !CGRectEqualToRect(((NSValue *)change[NSKeyValueChangeNewKey]).CGRectValue, ((NSValue *)change[NSKeyValueChangeOldKey]).CGRectValue)) {
        // attBtn
        CGSize attBtnSize = [_attBtn imageForState:UIControlStateNormal].size;
        attBtnSize = CGSizeMake(attBtnSize.width + KF5Helper.KF5DefaultSpacing, attBtnSize.height + KF5Helper.KF5DefaultSpacing);
        CGFloat attBtnOrignY = 0;
        if (self.photoImageView.kf5_h == 0) {
            attBtnOrignY = CGRectGetHeight(self.frame) - attBtnSize.height - self.offsetTop;
            attBtnOrignY = attBtnOrignY < CGRectGetMaxY(_photoImageView.frame)?CGRectGetMaxY(_photoImageView.frame):attBtnOrignY;
        }else{
            attBtnOrignY = CGRectGetMaxY(_photoImageView.frame);
        }
        _attBtn.frame = CGRectMake(0, attBtnOrignY, attBtnSize.width, attBtnSize.height);
        self.contentSize = CGSizeMake(self.kf5_w, CGRectGetMaxY(_attBtn.frame));
    }
}

- (CGFloat)offsetTop{
    if ([self.viewDelegate respondsToSelector:@selector(createTicketViewWithOffsetTop:)]) {
        CGFloat height = [self.viewDelegate createTicketViewWithOffsetTop:self];
        return height;
    }
    return 0;
}

#pragma mark - KFTextViewDelegate
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
    [self updateFrame];
}

// 添加附件
- (void)addAtt:(UIButton *)btn{
    if ([self.viewDelegate respondsToSelector:@selector(createTicketViewWithAddAttachmentAction:)]) {
        [self.viewDelegate createTicketViewWithAddAttachmentAction:self];
    }
}

// 点击屏幕弹出键盘
- (void)tapView:(UITapGestureRecognizer *)tap{
    [self.textView becomeFirstResponder];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"photoImageView.frame"];
    [self removeObserver:self forKeyPath:@"frame"];
}

@end
