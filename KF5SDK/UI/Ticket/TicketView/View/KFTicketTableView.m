//
//  KFTicketTableView.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFTicketTableView.h"
#import "KFCategory.h"

@interface KFTicketHeaderView : UIView
- (instancetype)initWithTitle:(NSString *)title ratingText:(NSString *)ratingText;
@end

@interface KFTicketTableView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation KFTicketTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = YES;
        
        // Remove touch delay (since iOS 8)
        UIView *wrapView = self.subviews.firstObject;
        // UITableViewWrapperView
        if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
            for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
                // UIScrollViewDelayedTouchesBeganGestureRecognizer
                if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                    gesture.enabled = NO;
                    break;
                }
            }
        }
        self.delegate = self;
        self.dataSource = self;
        self.estimatedRowHeight = 61;

        self.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return self;
}

- (void)setRatingModel:(KFRatingModel *)ratingModel{
    _ratingModel = ratingModel;
    
    if (!ratingModel) {self.tableHeaderView = nil;return;}
    
    KFTicketHeaderView *headerView = [[KFTicketHeaderView alloc] initWithTitle:KF5Localized(@"kf5_rate")
 ratingText:[KFRatingModel stringForRatingScore:ratingModel.ratingScore]];
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHeaderView)]];
    self.tableHeaderView = headerView;
}

- (void)clickHeaderView{
    if ([self.cellDelegate respondsToSelector:@selector(ticketTableView:clickHeaderViewWithRatingModel:)]) {
        [self.cellDelegate ticketTableView:self clickHeaderViewWithRatingModel:self.ratingModel];
    }
}

#pragma mark - tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *refresscellID = @"cellrefresscellid";
    
    KFTicketViewCell *cell = [tableView dequeueReusableCellWithIdentifier:refresscellID];
    if (cell == nil) {
        cell = [[KFTicketViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:refresscellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellDelegate = self.cellDelegate;
    }
    KFComment *comment = self.commentList[indexPath.row];
    cell.comment = comment;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.superview)[self.superview endEditing:YES];
}

#pragma mark 向下滚动
- (void)scrollViewBottomWithAnimated:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger rowCount = [self numberOfRowsInSection:0];
        if (rowCount > 1) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    });
}
- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self scrollViewBottomWithAnimated:YES];
    });
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self scrollViewBottomWithAnimated:YES];
}

@end


@implementation KFTicketHeaderView

- (instancetype)initWithTitle:(NSString *)title ratingText:(NSString *)ratingText{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 44)];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = KF5Helper.KF5BgColor;
        
        UILabel *titleLabel = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5BlueColor];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        UILabel *ratingLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:[UIColor whiteColor]];
        ratingLabel.text = ratingText;
        ratingLabel.textAlignment = NSTextAlignmentCenter;
        ratingLabel.backgroundColor = KF5Helper.KF5SatifiedColor;
        ratingLabel.layer.cornerRadius = 3;
        ratingLabel.layer.masksToBounds = YES;
        ratingLabel.hidden = !ratingText.length;
        [self addSubview:ratingLabel];
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage kf5_drawArrowImageWithColor:KF5Helper.KF5BlueColor size:CGSizeMake(13, 21)]];
        accessoryView.contentMode = UIViewContentModeCenter;
        [self addSubview:accessoryView];
        
        [titleLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.left.kf_equalTo(self.kf5_safeAreaLayoutGuideLeft).kf_offset(KF5Helper.KF5HorizSpacing);
            make.width.kf_equal(200);
            make.top.kf_equalTo(self);
            make.bottom.kf_equalTo(self);
        }];
        
        [accessoryView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.right.kf_equalTo(self.kf5_safeAreaLayoutGuideRight).kf_offset(-KF5Helper.KF5HorizSpacing);
            make.centerY.kf_equalTo(titleLabel);
        }];
        
        [ratingLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            CGSize ratingSize = [KFHelper sizeWithText:ratingLabel.text font:ratingLabel.font];
            make.right.kf_equalTo(accessoryView.kf5_left).kf_offset(-KF5Helper.KF5MiddleSpacing);
            make.centerY.kf_equalTo(titleLabel);
            make.width.kf_equal(ratingSize.width + KF5Helper.KF5MiddleSpacing);
            make.height.kf_equal(ratingSize.height + KF5Helper.KF5DefaultSpacing);
        }];
    }
    return self;
}

@end
