//
//  KFFaceBoardView.m
//  Pods
//
//  Created by admin on 16/10/21.
//
//

#import "KFFaceBoardView.h"
#import "KFHelper.h"



@interface KF5FaceButton : UIButton
@property (nonatomic, assign) NSInteger buttonIndex;
@end

@interface KF5PageControl : UIPageControl
@end


@interface KFFaceBoardView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *faceView;
@property (nonatomic, strong) KF5PageControl *facePageControl;
@property (nonatomic, strong) NSArray *faceMap;

@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation KFFaceBoardView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    CGFloat screenWidth = KF5Min;
    if (KF5ViewLandscape) screenWidth = KF5Max;
    // 行数
    int numFaceForRow  = 4;
    // 列数
    int numFaceForCol = 8;
    if (KF5SCREEN_WIDTH > 568)  numFaceForCol = 16;
    // 一页的数量
    int numFaceForPage = numFaceForRow * numFaceForCol;
    
    // 每个表情的高度,(当横屏时,也用竖屏时的高度)
    CGFloat faceHeight = KF5Min / ((KF5Min > 568) ? 16 : 8);
    
    // 每个表情的宽度(注意:高度和宽度可能不一致)
    CGFloat faceWidth = screenWidth / numFaceForCol;
    
    // 表情视图高度
    CGFloat faceViewHeight = faceHeight * numFaceForRow;
    
    // pageControl的高度
    CGFloat pageControlHeight = 40;
    
    self.frame = CGRectMake(0, 0, screenWidth, faceViewHeight + pageControlHeight);
 
    self.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
    
    NSString *emoji = @"😄,😊,😌,😚,😳,😅,😍,😜,😞,😁,😆,😘,😝,😒,😂,😏,😠,😃,😉,😋,😡,😔,😖,😱,😭,😫,😨,😢,😵,😩,😰,😲,😤,😪,😣,😓,😷,🌙,⭐️,💤,🐶,🐱,🐭,🐹,🐰,🐻,🐼,🐨,🐯,🐥,🐮,🐷,🐽,🐸,🐙,🐵,🙈,🙉,🙊,🐒,🐔,🐧,🐦,🐤";
    _faceMap = [emoji componentsSeparatedByString:@","];
    int count =(int)_faceMap.count;
    
    //表情盘
    _faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, faceViewHeight)];
    _faceView.pagingEnabled = YES;
    _faceView.contentSize = CGSizeMake(((count -2)/numFaceForPage+1)*screenWidth, faceViewHeight);
    _faceView.showsHorizontalScrollIndicator = NO;
    _faceView.showsVerticalScrollIndicator = NO;
    _faceView.delegate = self;
    
    for (int i = 0; i< count; i++) {
        
        int col = ((i%numFaceForPage)%numFaceForCol);
        int row = ((i%numFaceForPage)/numFaceForCol);
        NSString *faceString = _faceMap[i];
        KF5FaceButton *btn = [KF5FaceButton buttonWithType:UIButtonTypeCustom];
        btn.buttonIndex = i;
        if ((i+1) % numFaceForPage == 0) {
            //删除键
            [btn setImage:KF5Helper.chat_faceDelete forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [btn addTarget:self action:@selector(faceButton:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:23.f];
            [btn setTitle:faceString forState:UIControlStateNormal];
        }
        //计算每一个表情按钮的坐标和在哪一屏
        btn.frame = CGRectMake(col*faceWidth+(i/numFaceForPage*screenWidth), row*faceHeight, faceWidth, faceHeight);
        [_faceView addSubview:btn];
    }
    _facePageControl = [[KF5PageControl alloc]initWithFrame:CGRectMake((screenWidth-100)/2, faceViewHeight, 100, pageControlHeight)];
    _facePageControl.center = CGPointMake(screenWidth / 2, _facePageControl.center.y);
    [_facePageControl addTarget:self
                         action:@selector(pageChange:)
               forControlEvents:UIControlEventValueChanged];
    
    _facePageControl.numberOfPages = (count - 2)/numFaceForPage + 1;
    [_facePageControl setCurrentPage:_facePageControl.currentPage];
    [self addSubview:_facePageControl];
    
    //添加键盘View
    [self addSubview:_faceView];
    //发送键
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // 转接人工客服按钮
    _sendBtn.titleLabel.font = KF5Helper.KF5TitleFont;
    _sendBtn.backgroundColor = KF5Helper.KF5BlueColor;
    _sendBtn.layer.borderColor = [KF5Helper.KF5ChatToolTextViewBorderColor CGColor];
    _sendBtn.layer.borderWidth = 0.5;
    _sendBtn.layer.cornerRadius = 8.0;
    [_sendBtn setTitle:KF5Localized(@"kf5_send") forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColorH forState:UIControlStateHighlighted];
    
    [_sendBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat backW = 60;
    CGFloat backX =  screenWidth - backW - 10;
    
    _sendBtn.frame = CGRectMake(backX, faceViewHeight, backW, pageControlHeight - 5);
    [self addSubview:_sendBtn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
}

- (void)sendMessage{
    if (self.sendBlock) self.sendBlock();
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_facePageControl setCurrentPage:_faceView.contentOffset.x/self.frame.size.width];
    [_facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    [_faceView setContentOffset:CGPointMake(_facePageControl.currentPage*self.frame.size.width, 0) animated:YES];
    [_facePageControl setCurrentPage:_facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    int i = (int)((KF5FaceButton*)sender).buttonIndex;
    if (i < self.faceMap.count) {
        if (_clickBlock)
            _clickBlock(self.faceMap[i]);
    }

}

- (void)backFace{
    if (_deleteBlock) {
        _deleteBlock();
    }
}

- (void)layoutViews{
    CGFloat screenWidth = KF5Min;
    if (KF5ViewLandscape) screenWidth = KF5Max;
    
    // 行数
    int numFaceForRow  = 4;
    // 列数
    int numFaceForCol = 8;
    if (KF5SCREEN_WIDTH > 568)  numFaceForCol = 16;
    // 一页的数量
    int numFaceForPage = numFaceForRow * numFaceForCol;
    
    // 每个表情的高度,(当横屏时,也用竖屏时的高度)
    CGFloat faceHeight = KF5Min / ((KF5Min > 568) ? 16 : 8);
    
    // 每个表情的宽度(注意:高度和宽度可能不一致)
    CGFloat faceWidth = screenWidth / numFaceForCol;
    
    // 表情视图高度
    CGFloat faceViewHeight = faceHeight * numFaceForRow;
    
    // pageControl的高度
    CGFloat pageControlHeight = 40;
    
    self.frame = CGRectMake(0, 0, screenWidth, faceViewHeight + pageControlHeight);
    
    //表情盘
    _faceView.frame=CGRectMake(0, 0, screenWidth, faceViewHeight);
    _faceView.contentSize = CGSizeMake(((_faceMap.count -2)/numFaceForPage+1)*screenWidth, faceViewHeight);
    //表情布局
    for (int i = 0; i<_faceView.subviews.count; i++) {
        int col = (((i)%numFaceForPage)%numFaceForCol);
        int row = (((i)%numFaceForPage)/numFaceForCol);
        KF5FaceButton *btn = _faceView.subviews[i];
        
        if (i == 31) {
            if (numFaceForPage == 32) {
                [btn setTitle:nil forState:UIControlStateNormal];
                [btn setImage:KF5Helper.chat_faceDelete forState:UIControlStateNormal];
                [btn removeTarget:self action:@selector(faceButton:) forControlEvents:UIControlEventTouchUpInside];
                [btn addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [btn setImage:nil forState:UIControlStateNormal];
                [btn removeTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
                [btn addTarget:self action:@selector(faceButton:) forControlEvents:UIControlEventTouchUpInside];
                btn.titleLabel.font = [UIFont systemFontOfSize:23.f];
                [btn setTitle:_faceMap[i] forState:UIControlStateNormal];
            }
        }
        //计算每一个表情按钮的坐标和在哪一屏
        btn.frame = CGRectMake(col*faceWidth+(i/numFaceForPage*screenWidth), row*faceHeight, faceWidth, faceHeight);
    }
    
    _facePageControl.numberOfPages = (_faceMap.count - 2)/numFaceForPage + 1;
    _facePageControl.currentPage = 0;
    
    //删除键
    CGFloat backW = 60;
    CGFloat backX =  screenWidth - backW - 10;
    _sendBtn.frame = CGRectMake(backX, faceViewHeight, backW, 30);
}

- (void)statusBarOrientationChange:(NSNotification *)notification{
    [self layoutViews];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end



@implementation KF5FaceButton
@end

@implementation KF5PageControl

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self setCurrentPage:1];
    return self;
}
-(void) updateDots{
    for (int i = 0; i < [self.subviews count]; i++){
        UIView *view = [self.subviews objectAtIndex:i];
        if (i == self.currentPage) {
            view.backgroundColor = KF5Helper.KF5ChatFaceViewPageControlSelectColor;
        }else{
            view.backgroundColor = KF5Helper.KF5ChatFaceViewPageControlNormalColor;
        }
    }
}
-(void)setCurrentPage:(NSInteger)page{
    [super setCurrentPage:page];
    [self updateDots];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.center = CGPointMake(self.superview.center.x, self.center.y);
}

@end
