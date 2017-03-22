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

@interface KFTicketViewCell()<KFImageViewDelegate,KFLabelDelegate>

@end

@implementation KFTicketViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            self.contentView.frame = self.bounds;
            self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        }
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
        
    }
    return self;
}

- (void)setupView{
    // 内容
    KFLabel *commentLabel = [[KFLabel alloc]init];
    commentLabel.labelDelegate = self;
    [commentLabel addGestureRecognizer: [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)]];
    commentLabel.numberOfLines = 0;
    [self.contentView addSubview:commentLabel];
    self.commentLabel = commentLabel;
    
    // 附件
    KFImageView *photoImageView = [[KFImageView alloc]init];
    photoImageView.delegate = self;
    [self.contentView addSubview:photoImageView];
    self.photoImageView = photoImageView;
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc]init];
    self.timeLabel = timeLabel;
    timeLabel.font = KF5Helper.KF5NameFont;
    timeLabel.textColor = KF5Helper.KF5NameColor;
    [self.contentView addSubview:timeLabel];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:headImageView];
    self.headImageView = headImageView;
    
    // 昵称
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.textColor = KF5Helper.KF5NameColor;
    nameLabel.font = KF5Helper.KF5NameFont;
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    // loadingView
    KFLoadView *loadView = [[KFLoadView alloc]init];
    loadView.status = KFMessageStatusSuccess;
    [self.contentView addSubview:loadView];
    self.loadView = loadView;
    
}

- (void)setCommentModel:(KFCommentModel *)commentModel{
    _commentModel = commentModel;
    
    _commentLabel.textLayout = commentModel.textLayout;
    _commentLabel.frame = commentModel.textFrame;
    
    _photoImageView.frame = commentModel.attViewFrame;
    [_photoImageView setAttachments:commentModel.attachments];
    
    _timeLabel.text = commentModel.timeText;
    _timeLabel.frame = commentModel.timeFrame;
    
    _headImageView.image = commentModel.headerImage;
    _headImageView.frame = commentModel.headerFrame;
    
    _nameLabel.text = commentModel.name;
    _nameLabel.frame = commentModel.nameFrame;
    
    _loadView.frame = commentModel.loadViewFrame;
    _loadView.status = commentModel.comment.messageStatus;
}

/**
 *  长按出现复制菜单
 */
-(void)longTap:(UILongPressGestureRecognizer *)longTap{
    UIView *superView = self.superview.superview.superview;
    KFTicketToolView *toolView = [superView viewWithTag:kKF5TicketToolViewTag];
    if ([toolView isKindOfClass:[KFTicketToolView class]]) {
        if ([toolView.textView isFirstResponder]) {
            toolView.textView.inputNextResponder = self;
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
    [[UIPasteboard generalPasteboard]setString:(self.commentModel.comment.content)];
    [KFProgressHUD showTitleToView:self.superview title:KF5Localized(@"kf5_copied") hideAfter:0.7];
}

#pragma mark KFImageView的代理
- (void)imageViewLookWithIndex:(NSInteger)index{
    
    if ([self.cellDelegate respondsToSelector:@selector(ticketCell:clickImageWithIndex:)]) {
        [self.cellDelegate ticketCell:self clickImageWithIndex:index];
    }
}
#pragma mark KFLabel的代理
- (void)clickLabelWithInfo:(NSDictionary *)info{
    if ([self.cellDelegate respondsToSelector:@selector(ticketCell:clickLabelWithInfo:)]) {
        [self.cellDelegate ticketCell:self clickLabelWithInfo:info];
    }
}

@end
