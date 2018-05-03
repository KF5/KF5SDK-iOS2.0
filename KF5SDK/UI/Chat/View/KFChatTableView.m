//
//  KFChatTableView.m
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import "KFChatTableView.h"
#import "KFHelper.h"

static NSString *kChatMessageVoiceCellID = @"chatMessageVoiceCellID";
static NSString *kChatMessageTextCellID = @"chatMessageTextCellID";
static NSString *kChatMessageImageCellID = @"chatMessageImageCellID";
static NSString *kChatMessageSystemCellID = @"chatMessageSystemCellID";
static NSString *kChatMessageCardCellID = @"chatMessageCardCellID";
static NSString *kChatMessageQueueCellID = @"chatMessageQueueCellID";

#define KFContentInsetTop  KF5Helper.KF5VerticalSpacing

@interface KFChatTableView()<UITableViewDataSource,UITableViewDelegate>

//是否正在刷新
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign,getter=isCanRefresh) BOOL canRefresh;

@end

@implementation KFChatTableView

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
        
        [self setContentInset:UIEdgeInsetsMake(KFContentInsetTop, 0, 0, 0)];
        self.delegate = self;
        self.dataSource = self;
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.canRefresh = YES;
    }
    return self;
}

#pragma mark - tableView代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    KFMessageModel *messageModel = self.messageModelArray[indexPath.row];
    return messageModel.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KFMessageModel *messageModel = self.messageModelArray[indexPath.row];
    
    KFChatViewCell *cell = nil;
    switch (messageModel.message.messageType) {
        case KFMessageTypeText:
        case KFMessageTypeCustom:{
            cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageTextCellID];
            if (!cell) {
                cell = [[KFTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChatMessageTextCellID];
            }
        }
            break;
        case KFMessageTypeImage:{
            cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageImageCellID];
            if (!cell) {
                cell = [[KFImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChatMessageImageCellID];
            }
        }
            break;
        case KFMessageTypeVoice:{
            cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageVoiceCellID];
            if (!cell) {
                cell = [[KFVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChatMessageVoiceCellID];
            }
        }
            break;
        case KFMessageTypeSystem:{
            cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageSystemCellID];
            if (!cell) {
                cell = [[KFSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChatMessageSystemCellID];
            }
        }
            break;
        case KFMessageTypeCard:{
            cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageCardCellID];
            if (!cell) {
                cell = [[KFCardMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChatMessageCardCellID];
            }
        }
            break;
        default:{
            cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageTextCellID];
            if (!cell) {
                cell = [[KFTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChatMessageTextCellID];
            }
        }
            break;
    }
    cell.cellDelegate = self.tableDelegate;
    cell.messageModel = messageModel;
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.superview)[self.superview endEditing:NO];
    scrollView.tag = 1;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    scrollView.tag = 0;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    scrollView.tag = 1;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    scrollView.tag = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag) {
        CGFloat offSetTop = 0;
        if ([self.tableDelegate respondsToSelector:@selector(tableViewWithOffsetTop:)]) {
            offSetTop = [self.tableDelegate tableViewWithOffsetTop:self];
        }
        if (!self.isRefreshing && self.isCanRefresh && (scrollView.contentOffset.y <= -(KFContentInsetTop + offSetTop))) {
            self.refreshing = YES;
            [self refreshHeaderData];
        }
    }
}

- (void)refreshHeaderData{
    UIActivityIndicatorView *loadingView =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:loadingView];
    [loadingView startAnimating];
    [loadingView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.width.kf_equal(20);
        make.height.kf_equal(20);
        make.centerX.kf_equalTo(self.kf5_centerX);
        make.centerY.kf_equalTo(self.kf5_top).kf_offset(-KFContentInsetTop/2);
    }];
    
    if ([self.tableDelegate respondsToSelector:@selector(tableViewWithRefreshData:)]) {
        [self.tableDelegate tableViewWithRefreshData:self];
    }
}
- (void)endRefreshing{
    self.refreshing = NO;
    NSEnumerator *subviewsEnum = [self.subviews reverseObjectEnumerator];
    for (UIView *view in subviewsEnum) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}
- (void)endRefreshingWithNoMoreData{
    self.canRefresh = NO;
    [self endRefreshing];
}

#pragma mark 向下滚动
- (void)scrollViewBottomWithAnimated:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger rowCount = [self numberOfRowsInSection:0];
        if (rowCount > 1) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
            [self layoutIfNeeded];
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    });
}
- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self scrollViewBottomWithAnimated:YES];
    });
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    for (KFMessageModel *model in self.messageModelArray) {
        [model updateFrame];
    }
    [self reloadData];
    [self scrollViewBottomWithAnimated:YES];
}

@end
