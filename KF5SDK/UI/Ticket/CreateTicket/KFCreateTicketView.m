//
//  KFCreateTicketView.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFCreateTicketView.h"
#import "KFHelper.h"
#import "KFAutoLayout.h"

static CGFloat kAttBtnLength = 30;

@interface KFCreateTicketView()

@end

@implementation KFCreateTicketView

- (instancetype)init{
    self = [super init];
    if (self) {

        // 文本框
        KFTextView *textView = [[KFTextView alloc] init];
        textView.canEmoji = NO;
        textView.placeholderText = KF5Localized(@"kf5_edittext_hint");
        [self addSubview:textView];
        _textView = textView;
        
        // 图片
        KFSudokuView *photoImageView = [[KFSudokuView alloc]init];
        [self addSubview:photoImageView];
        _photoImageView = photoImageView;
        
        // 添加图片按钮
        UIButton *attBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [attBtn setImage:KF5Helper.ticket_createAtt forState:UIControlStateNormal];
        [attBtn addTarget:self action:@selector(addAtt:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:attBtn];
        _attBtn = attBtn;
        
        [self layoutView];
        [self configureView];
    }
    return self;
}

- (void)configureView{
    
    [self addObserver:self forKeyPath:@"photoImageView.items" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self)weakSelf = self;
    _photoImageView.clickCellBlock = ^(KFSudokuViewCell *cell) {
        [[KFHelper alertWithMessage:KF5Localized(@"kf5_delete_this_image") confirmHandler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *items = [NSMutableArray arrayWithArray:weakSelf.photoImageView.items];
            [items removeObject:cell.item];
            weakSelf.photoImageView.items = items;
        }]showToVC:nil];
    };
    
}

- (void)layoutView{
    
    [_textView kf5_makeConstraints:^(KFAutoLayout *make) {
        make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.right.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing);
        self.textView.heightLayout = make.height.kf_equal(self.textView.textHeight).active;
    }];
    
    [_photoImageView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self.textView);
        make.right.kf_equalTo(self.textView);
        make.top.kf_equalTo(self.textView.kf5_bottom).kf_offset(KF5Helper.KF5DefaultSpacing);
    }];
    
    [_attBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
        make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing);
        // scrollView需要使用这个计算contentSize
        make.top.kf_greaterThanOrEqualTo(self.photoImageView);
        make.width.kf_equal(kAttBtnLength);
        make.height.kf_equal(kAttBtnLength);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"photoImageView.items"]) {
        if (self.photoImageView.items.count > 0 && self.attBtn.tag == 0) {
            [self.attBtn kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
                make.left.kf_equalTo(self).kf_offset(KF5Helper.KF5DefaultSpacing);
                make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5DefaultSpacing);
                make.top.kf_equalTo(self.photoImageView.kf5_bottom).kf_offset(KF5Helper.KF5DefaultSpacing);
                make.width.kf_equal(kAttBtnLength);
                make.height.kf_equal(kAttBtnLength);
            }];
            self.attBtn.tag = 1;
        }
    }
}

// 添加附件
- (void)addAtt:(UIButton *)btn{
    if (self.clickAttBtn) {
        self.clickAttBtn();
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     [self.textView becomeFirstResponder];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"photoImageView.items"];
}

@end
