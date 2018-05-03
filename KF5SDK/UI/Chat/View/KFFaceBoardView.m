//
//  KFFaceBoardView.m
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/24.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "KFFaceBoardView.h"
#import "KFHelper.h"

static const NSInteger  kPageControlHeight = 40;
static const NSInteger  kNumFaceForRow = 4;

#define kColumnNumber   ([UIScreen mainScreen].bounds.size.width >= 568 ? 16 : 8)

static NSString *cellID = @"KFPreviewCell";

@interface KFFaceBoardViewCell: UICollectionViewCell
@property (nonatomic,copy) NSString *title;
@property (nonatomic,weak) UIButton *faceBtn;
@property (nonatomic,copy) void (^clickBtn)(NSString *title);
@end

@interface KFFaceBoardView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,weak) UICollectionView *faceView;
@property (nonatomic,weak) KFFacePageControl *facePageControl;
@property (nonatomic,strong) NSMutableArray *emojis;

@property (nonatomic,strong) NSLayoutConstraint *faceViewHeightLayout;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation KFFaceBoardView

- (instancetype)initWithFrame:(CGRect)frame{
    UIEdgeInsets safeInserts = [UIApplication sharedApplication].keyWindow.rootViewController.view.kf5_safeAreaInsets;
    frame.size.width = [UIScreen mainScreen].bounds.size.width  - safeInserts.left - safeInserts.right;
    frame.size.height = ceil((frame.size.width / kColumnNumber) * kNumFaceForRow) + kPageControlHeight + safeInserts.bottom;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
        _emojis = [NSMutableArray arrayWithArray:[@"😄,😞,😠,😭,😊,😁,😃,😩,😌,😆,😉,😨,😚,😘,😋,😢,😳,😝,😡,😵,😅,😒,😔,😫,😍,😂,😖,😰,😜,😏,😱,delete,😤,🐶,🐯,🙈,😪,🐱,🐥,🙉,😣,🐭,🐮,🙊,😓,🐹,🐷,🐒,😷,🐰,🐽,🐔,🌙,🐻,🐸,🐧,⭐️,🐼,🐙,🐦,💤,🐨,🐵,delete" componentsSeparatedByString:@","]];
        
        UICollectionView *faceView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewLayout alloc]init]];
        faceView.backgroundColor = self.backgroundColor;
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.delegate = self;
        faceView.dataSource = self;
        faceView.pagingEnabled = YES;
        faceView.scrollsToTop = NO;
        faceView.alwaysBounceHorizontal = YES;
        faceView.contentOffset = CGPointZero;
        [faceView registerClass:[KFFaceBoardViewCell class] forCellWithReuseIdentifier:cellID];
        [self addSubview:faceView];
        _faceView = faceView;
        
        KFFacePageControl *facePageControl = [[KFFacePageControl alloc] init];
        [facePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
        facePageControl.numberOfPages = [self numberOfPages];
        [self addSubview:facePageControl];
        _facePageControl = facePageControl;
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.titleLabel.font = KF5Helper.KF5TitleFont;
        sendBtn.backgroundColor = KF5Helper.KF5BlueColor;
        sendBtn.layer.borderColor = [KF5Helper.KF5ChatToolTextViewBorderColor CGColor];
        sendBtn.layer.borderWidth = 0.5;
        sendBtn.layer.cornerRadius = 8.0;
        [sendBtn setTitle:KF5Localized(@"kf5_send") forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setTitleColor:KF5Helper.KF5ChatToolViewSpeakBtnTitleColorH forState:UIControlStateHighlighted];
        [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBtn];

        [faceView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            self.faceViewHeightLayout = make.height.kf_equal(0).active;
            make.left.kf_equalTo(self.kf5_safeAreaLayoutGuideLeft);
            make.right.kf_equalTo(self.kf5_safeAreaLayoutGuideRight);
            make.bottom.kf_equalTo(facePageControl.kf5_top);
        }];
        
        [facePageControl kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.left.kf_equalTo(faceView);
            make.height.kf_equal(kPageControlHeight);
            make.right.kf_equalTo(faceView);
            make.bottom.kf_equalTo(self.kf5_safeAreaLayoutGuideBottom);
        }];
        
        [sendBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.width.kf_equal(60);
            make.height.kf_equal(35);
            make.centerY.kf_equalTo(facePageControl);
            make.right.kf_equalTo(faceView).kf_offset(-KF5Helper.KF5DefaultSpacing);
        }];

    }
    return self;
}

- (void)pageChange:(KFFacePageControl *)sender {
    [self.faceView setContentOffset:CGPointMake(sender.currentPage*self.frame.size.width, 0) animated:YES];
    sender.currentPage = sender.currentPage;
}
- (void)sendMessage:(UIButton *)btn{
    if (self.sendBlock) self.sendBlock();
}
#pragma mark - UICollectionViewDataSource && Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offSetWidth = scrollView.contentOffset.x + self.frame.size.width * 0.5;
    NSInteger currentIndex = offSetWidth / self.frame.size.width;
    if (currentIndex < self.emojis.count && self.currentIndex != currentIndex) {
        self.currentIndex = currentIndex;
        [self.facePageControl setCurrentPage:currentIndex];
    }
}

- (NSInteger)numberOfPages{
    return ceil(((CGFloat)self.emojis.count) / (kColumnNumber * kNumFaceForRow));
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emojis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KFFaceBoardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.title = self.emojis[indexPath.row];
    if ([cell.title isEqualToString:@"delete"]) {
        [cell.faceBtn setImage:KF5Helper.chat_faceDelete forState:UIControlStateNormal];
        [cell.faceBtn setTitle:nil forState:UIControlStateNormal];
    }else{
        [cell.faceBtn setImage:nil forState:UIControlStateNormal];
        [cell.faceBtn setTitle:cell.title forState:UIControlStateNormal];
    }
    __weak typeof(self)weakSelf = self;
    cell.clickBtn = ^(NSString *title) {
        if ([title isEqualToString:@"delete"]) {
            if (weakSelf.deleteBlock) {
                weakSelf.deleteBlock();
            }
        }else{
            if (weakSelf.clickBlock) {
                weakSelf.clickBlock(title);
            }
        }
    };
    return cell;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat sideLength =  self.faceView.frame.size.width / kColumnNumber;
    CGFloat faceViewHeight = ceil(sideLength * kNumFaceForRow);
    if (self.faceViewHeightLayout.constant != faceViewHeight) {
        self.faceViewHeightLayout.constant = faceViewHeight;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(sideLength, sideLength);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.faceView.collectionViewLayout = layout;
        [self.faceView setContentOffset:CGPointZero animated:YES];
        
        self.facePageControl.numberOfPages = [self numberOfPages];
        [self.emojis replaceObjectAtIndex:31 withObject:KF5ViewLandscape ? @"👏" : @"delete"];
        [self.faceView reloadData];
    }
}
@end

@implementation KFFaceBoardViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [faceBtn addTarget:self action:@selector(clickFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:faceBtn];
        _faceBtn = faceBtn;
        [faceBtn kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.top.kf_equalTo(self.contentView);
            make.left.kf_equalTo(self.contentView);
            make.bottom.kf_equalTo(self.contentView);
            make.right.kf_equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)clickFaceBtn:(UIButton *)btn{
    if (self.clickBtn) {
        self.clickBtn(self.title);
    }
}

@end


@implementation KFFacePageControl
- (id)initWithFrame:(CGRect)aFrame {
    if (self = [super initWithFrame:aFrame]) {
        self.currentPage = 0;
    }
    return self;
}
-(void) updateDots {
    for (int i = 0; i < [self.subviews count]; i++){
        UIView *view = [self.subviews objectAtIndex:i];
        if (i == self.currentPage) {
            view.backgroundColor = [UIColor blackColor];
        }else{
            view.backgroundColor = KF5Helper.KF5TimeColor;
        }
    }
}
- (void)setNumberOfPages:(NSInteger)numberOfPages{
    [super setNumberOfPages:numberOfPages];
    self.currentPage = 0;
}
-(void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    [self updateDots];
}
@end
