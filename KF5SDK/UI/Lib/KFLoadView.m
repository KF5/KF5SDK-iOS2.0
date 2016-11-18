//
//  KFLoadView.m
//  Pods
//
//  Created by admin on 16/11/1.
//
//

#import "KFLoadView.h"
#import "KFHelper.h"

@interface KFLoadView()

@property (nullable, nonatomic, weak) UIActivityIndicatorView *loadingView;

@property (nullable, nonatomic, weak) UIButton *failureBtn;

@end

@implementation KFLoadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
         UIActivityIndicatorView *loadingView =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidden = YES;
        [self addSubview:loadingView];
        _loadingView = loadingView;
        
        UIButton *failureBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        failureBtn.hidden = YES;
        [failureBtn setImage:KF5Helper.failedImage forState:UIControlStateNormal];
        [failureBtn addTarget:self action:@selector(clickFailureBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:failureBtn];
        _failureBtn = failureBtn;
    }
    return self;
}

- (void)clickFailureBtn{
    if (self.clickFailureBtnBlock)
        self.clickFailureBtnBlock();
}

- (void)setStatus:(KFMessageStatus)status{
    _status = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case KFMessageStatusSending:{
                self.hidden = NO;
                [self.loadingView startAnimating];
                self.loadingView.hidden = NO;
                self.failureBtn.hidden = YES;
            }
                break;
            case KFMessageStatusFailure:{
                self.hidden = NO;
                [self.loadingView stopAnimating];
                self.loadingView.hidden = YES;
                self.failureBtn.hidden = NO;
            }
                break;
            default:
                [self.loadingView stopAnimating];
                self.hidden = YES;
                break;
        }
    });
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.failureBtn.frame = self.bounds;
    self.loadingView.frame = self.bounds;
}

@end
