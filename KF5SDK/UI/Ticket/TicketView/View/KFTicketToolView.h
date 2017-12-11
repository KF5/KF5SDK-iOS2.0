//
//  KFTicketToolView.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import <UIKit/UIKit.h>
#import "KFAttView.h"
#import "KFTextView.h"

typedef NS_ENUM(NSInteger,KFTicketToolType) {
    KFTicketToolTypeInputText = 0,  // 文本输入状态
    KFTicketToolTypeAddImage,       // 添加图片状态
    KFTicketToolTypeClose           // 关闭状态(禁止填写新回复)
};

@class KFTicketToolView;
@class KFTicketInputView;

@protocol KFTicketToolViewDelegate <NSObject>

///发送消息
- (void)toolView:(nonnull KFTicketToolView *)toolView senderMessage:(nullable NSString *)message;
///添加图片
- (void)toolViewAddAttachment:(nonnull KFTicketToolView *)toolView;///添加图片
- (void)toolViewWithTextDidChange:(nonnull KFTicketToolView *)toolView;

@end

@interface KFTicketToolView : UIView

@property (nullable, nonatomic, weak) id<KFTicketToolViewDelegate> delegate;

///输入视图
@property (nullable, nonatomic, weak) KFTicketInputView *inputView;
///关闭视图
@property (nullable, nonatomic, weak) UIView *closeView;
///添加图片视图
@property (nullable, nonatomic, weak) KFAttView *attView;
///工具条状态
@property (nonatomic, assign) KFTicketToolType type;

@end

@interface KFTicketInputView: UIView
///输入框
@property (nullable, nonatomic, weak) KFTextView *textView;
///附件按钮
@property (nullable, nonatomic, weak) UIButton *attBtn;
@end
