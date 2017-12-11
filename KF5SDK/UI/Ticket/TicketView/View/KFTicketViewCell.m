//
//  KFTicketViewCell.m
//  Pods
//
//  Created by admin on 16/11/4.
//
//

#import "KFTicketViewCell.h"
#import "KFHelper.h"
#import "KFTicketToolView.h"
#import "KFProgressHUD.h"
#import "KFContentLabelHelp.h"

@interface KFTicketViewCell()

@end

@implementation KFTicketViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
        [self layoutView];
    }
    return self;
}

- (void)setupView{
    // 内容
    KFLabel *commentLabel = [[KFLabel alloc]init];
    commentLabel.linkTextAttributes = @{NSForegroundColorAttributeName:KF5Helper.KF5OtherURLColor};
    __weak typeof(self)weakSelf = self;
    commentLabel.linkTapBlock = ^(KFLabel *label, NSDictionary *value) {
        if ([weakSelf.cellDelegate respondsToSelector:@selector(ticketCell:clickLabelWithInfo:)]) {
            [weakSelf.cellDelegate ticketCell:weakSelf clickLabelWithInfo:value];
        }
    };
    commentLabel.commonLongPressBlock = ^(KFLabel *label) {
        [weakSelf longPressToCopyText];
    };
    [self.contentView addSubview:commentLabel];
    self.commentLabel = commentLabel;

    // 附件
    KFSudokuView *photoImageView = [[KFSudokuView alloc]init];
    photoImageView.clickCellBlock = ^(KFSudokuViewCell * _Nonnull cell) {
        if ([weakSelf.cellDelegate respondsToSelector:@selector(ticketCell:clickImageWithIndex:)]) {
            [weakSelf.cellDelegate ticketCell:weakSelf clickImageWithIndex:cell.indexPath.row];
        }
    };
    [self.contentView addSubview:photoImageView];
    self.photoImageView = photoImageView;
    
    // 时间
    UILabel *timeLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:KF5Helper.KF5NameColor];
    self.timeLabel = timeLabel;
    [self.contentView addSubview:timeLabel];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:headImageView];
    self.headImageView = headImageView;
    
    // 昵称
    UILabel *nameLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:KF5Helper.KF5NameColor];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    // loadingView
    KFLoadView *loadView = [[KFLoadView alloc]init];
    loadView.status = KFMessageStatusSuccess;
    [self.contentView addSubview:loadView];
    self.loadView = loadView;
}

- (void)layoutView{
    UIView *superview = self.contentView;
    [self.commentLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.equalTo(superview).offset(KF5Helper.KF5DefaultSpacing);
        make.left.equalTo(superview).offset(KF5Helper.KF5HorizSpacing);
        make.right.equalTo(superview).offset(-KF5Helper.KF5HorizSpacing);
    }];
    
    [self.photoImageView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.equalTo(self.commentLabel);
        make.right.equalTo(self.commentLabel);
        make.top.equalTo(self.commentLabel.kf5_bottom).offset(KF5Helper.KF5DefaultSpacing);
    }];
    
    [self.timeLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.equalTo(self.commentLabel);
        make.right.lessThanOrEqualTo(self.headImageView.kf5_left).offset(-KF5Helper.KF5DefaultSpacing);
        make.top.equalTo(self.photoImageView.kf5_bottom).offset(KF5Helper.KF5DefaultSpacing);
        make.bottom.equalTo(superview).offset(-KF5Helper.KF5DefaultSpacing).priority(UILayoutPriorityDefaultHigh);
    }];
    [self.headImageView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.width.kf_equal(20);
        make.height.kf_equal(20);
        make.centerY.equalTo(self.timeLabel);
        make.right.equalTo(self.nameLabel.kf5_left).offset(-5);
    }];
    
    [self.nameLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.centerY.equalTo(self.timeLabel);
        make.right.equalTo(self.commentLabel.kf5_right);
    }];
    
    [self.loadView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.centerY.equalTo(superview);
        make.left.equalTo(superview);
        make.width.kf_equal(20);
        make.height.kf_equal(20);
    }];
}

- (void)setComment:(KFComment *)comment{
    _comment = comment;
    
    NSAttributedString *text = [KFContentLabelHelp attributedString:_comment.content labelHelpHandle:KFLabelHelpHandleHttp|KFLabelHelpHandlePhone|KFLabelHelpHandleATag font:KF5Helper.KF5TitleFont color:KF5Helper.KF5TitleColor];
    _commentLabel.attributedText = text;
    _photoImageView.items = comment.attachments;
    _timeLabel.text = [NSDate kf5_stringFromDate:[NSDate dateWithTimeIntervalSince1970:comment.created]];
    _headImageView.image = comment.messageFrom == KFMessageFromMe ? KF5Helper.endUserImage : KF5Helper.agentImage;
    _nameLabel.text = comment.author_name;
    _loadView.status = comment.messageStatus;
    
    [self.timeLabel kf5_remakeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.left.equalTo(self.commentLabel);
        make.right.lessThanOrEqualTo(self.headImageView.kf5_left).offset(-KF5Helper.KF5DefaultSpacing);
        CGFloat offset = comment.attachments.count == 0 ? 0 : KF5Helper.KF5DefaultSpacing;
        make.top.equalTo(self.photoImageView.kf5_bottom).offset(offset);
        make.bottom.equalTo(self.contentView).offset(-KF5Helper.KF5DefaultSpacing).priority(500);
    }];
}

/**
 *  长按出现复制菜单
 */
-(void)longPressToCopyText{
    UIView *superView = self.superview.superview.superview;
    KFTicketToolView *toolView = [superView viewWithTag:kKF5TicketToolViewTag];
    if ([toolView isKindOfClass:[KFTicketToolView class]]) {
        if ([toolView.inputView.textView isFirstResponder]) {
            toolView.inputView.textView.inputNextResponder = self;
        }else{
            [self becomeFirstResponder];
        }
    }else{
        [self becomeFirstResponder];
    }
    UIMenuController *menu=[UIMenuController sharedMenuController];
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:KF5Localized(@"kf5_copy") action:@selector(copyItem:)];
    [menu setMenuItems:@[copy]];
    [menu setTargetRect:self.commentLabel.frame inView:self];
    [menu setMenuVisible:YES animated:YES];
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action ==@selector(copyItem:)){
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)copyItem:(id)sender{
    [[UIPasteboard generalPasteboard]setString:(self.comment.content)];
    [KFProgressHUD showTitleToView:self.superview title:KF5Localized(@"kf5_copied") hideAfter:0.7];
}

@end
