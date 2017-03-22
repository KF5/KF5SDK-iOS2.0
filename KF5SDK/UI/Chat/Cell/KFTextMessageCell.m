//
//  KFTextMessageCell.m
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import "KFTextMessageCell.h"
#import "KFHelper.h"
#import "KFChatToolView.h"
#import "KFTextView.h"

@interface KFTextMessageCell()<KFLabelDelegate>

@end

@implementation KFTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        KFLabel *messageLabel = [[KFLabel alloc] init];
        messageLabel.labelDelegate = self;
        messageLabel.numberOfLines = 0;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(chatMessageBtnLongTap:)];
        [messageLabel addGestureRecognizer:longPress];
        
        [self.contentView addSubview:messageLabel];
        _messageLabel = messageLabel;
    }
    return self;
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    [super setMessageModel:messageModel];
    
    self.messageLabel.textLayout = messageModel.textLayout;
    self.messageLabel.frame = messageModel.messageViewFrame;
}

#pragma mark - messageLabelDelegate
- (void)clickLabelWithInfo:(NSDictionary *)info{
    if ([self.cellDelegate respondsToSelector:@selector(cell:clickLabelWithInfo:)]) {
        [self.cellDelegate cell:self clickLabelWithInfo:info];
    }
}

#pragma mark - 长按赋值
- (void)chatMessageBtnLongTap:(UILongPressGestureRecognizer *)longTap{
    // 避免多次调用,和messageType必须是text
    if (longTap.state != UIGestureRecognizerStateBegan)
        return;
    
    // 菜单已经打开不需重复操作
    UIMenuController *menu=[UIMenuController sharedMenuController];
    if (menu.isMenuVisible)
        return;
    
    UIView *superView =  self.superview.superview.superview;
    KFChatToolView *toolView = [superView viewWithTag:kKF5ChatToolViewTag];
    if ([toolView isKindOfClass:[KFChatToolView class]]) {
        if ([toolView.textView isFirstResponder]) {
            toolView.textView.inputNextResponder = self;
        }else{
            [self becomeFirstResponder];
        }
    }else{
        [self becomeFirstResponder];
    }
    
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:KF5Localized(@"kf5_copy") action:@selector(copyItem:)];
    [menu setMenuItems:@[copy]];
    [menu setTargetRect:self.messageBgView.frame inView:self.contentView];
    [menu setMenuVisible:YES animated:YES];
    self.messageBgView.highlighted = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(copyBtnWillHidden) name:UIMenuControllerWillHideMenuNotification object:nil];
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
    if (self.messageModel.message.messageType == KFMessageTypeOther) {
        [[UIPasteboard generalPasteboard]setString:self.messageModel.message.url?:@""];
    }else if(self.messageModel.message.messageType == KFMessageTypeCustom){
        [[UIPasteboard generalPasteboard]setString:self.messageModel.textLayout.text.string?:@""];
    }else{
        [[UIPasteboard generalPasteboard]setString:self.messageModel.message.content?:@""];
    }
}

- (void)copyBtnWillHidden{
    UIView *superView =  self.superview.superview.superview;
    KFChatToolView *toolView = [superView viewWithTag:kKF5ChatToolViewTag];
    if ([toolView isKindOfClass:[KFChatToolView class]]) {
        toolView.textView.inputNextResponder = nil;
    }
    self.messageBgView.highlighted = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
