//
//  KFCreateTicketView.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import <UIKit/UIKit.h>
#import "KFTextView.h"
#import "KFImageView.h"

@class KFCreateTicketView;

@protocol KFCreateTicketViewDelegate <NSObject>

/**
 点击添加附件
 */
- (void)createTicketViewWithAddAttachmentAction:(KFCreateTicketView *)view;

/**
 返回偏移量高度
 */
- (CGFloat)createTicketViewWithOffsetTop:(KFCreateTicketView *)view;

@end

@interface KFCreateTicketView : UIScrollView

- (instancetype)initWithFrame:(CGRect)frame viewDelegate:(id<KFCreateTicketViewDelegate>)viewDelegate;

/// 输入框
@property (nonatomic, strong) KFTextView *textView;
/// 添加附件按钮
@property (nonatomic, weak) UIButton *attBtn;
/// 图片视图
@property (nonatomic, weak) KFImageView *photoImageView;

- (void)updateFrame;

@end
