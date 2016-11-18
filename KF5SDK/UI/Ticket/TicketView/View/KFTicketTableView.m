//
//  KFTicketTableView.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFTicketTableView.h"

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
        self.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mark - tableView代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    KFCommentModel *commentModel = self.commentModelArray[indexPath.row];
    return commentModel.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *refresscellID = @"cellrefresscellid";
    
    KFTicketViewCell *cell = [tableView dequeueReusableCellWithIdentifier:refresscellID];
    if (cell == nil) {
        cell = [[KFTicketViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:refresscellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellDelegate = self.cellDelegate;
    }
    KFCommentModel *commentModel = self.commentModelArray[indexPath.row];
    cell.commentModel = commentModel;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.superview)[self.superview endEditing:YES];
}

#pragma mark 向下滚动
- (void)scrollViewBottomHasMainQueue:(BOOL)hasMainQueue{
    if (self.contentSize.height > self.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
        
        if (hasMainQueue) {
            dispatch_async(dispatch_get_main_queue(), ^{// 调用线程会影响外部包裹的动画
                [self setContentOffset:offset animated:YES];
            });
        }else{
            [UIView animateWithDuration:0.25f animations:^{
                [self setContentOffset:offset];
            }];
        }
    }
}
- (void)scrollViewBottomWithAfterTime:(int16_t)afterTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self scrollViewBottomHasMainQueue:NO];
    });
}

@end
