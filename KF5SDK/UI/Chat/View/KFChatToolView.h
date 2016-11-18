//
//  KFChatToolView.h
//  Pods
//
//  Created by admin on 16/10/20.
//
//

#import <UIKit/UIKit.h>
#import  <KF5SDK/KFDispatcher.h>

@class KFTextView;
@class KFChatToolView;

@protocol KFChatTooViewDelegate <NSObject>

/**
 添加图片按钮点击事件
 */
- (void)chatToolViewWithAddPictureAction:(nonnull KFChatToolView *)chatToolView;
/**
 转接人工客服点击事件
 */
- (void)chatToolViewWithTransferAction:(nonnull KFChatToolView *)chatToolView;
/**
 textView需要发送信息
 */
- (void)chatToolView:(nonnull KFChatToolView *)chatToolView shouldSendContent:(nullable NSString  *)content;
/**
 开始录音

 @return 返回是否显示录音view
 */
- (BOOL)chatToolViewStartVoice:(nonnull KFChatToolView *)chatToolView;
/**
 取消录音
 */
- (void)chatToolViewCancelVoice:(nonnull KFChatToolView *)chatToolView;
/**
 完成录音
 */
- (void)chatToolViewCompleteVoice:(nonnull KFChatToolView *)chatToolView;
/**
 点击语音图标按钮点击事件
 */
- (BOOL)chatToolViewWithClickVoiceAction:(nonnull KFChatToolView *)chatToolView;
/**
 textView输入监听
 */
- (BOOL)chatToolView:(nonnull KFChatToolView *)chatToolView didChangeReplacementText:(nullable NSString *)text;

@end


@interface KFChatToolView : UIView
/**
 语音按钮
 */
@property (nullable, nonatomic, weak) UIButton *voiceBtn;
/**
 输入框
 */
@property (nullable, nonatomic, weak) KFTextView *textView;
/**
 说话按钮
 */
@property (nullable, nonatomic, weak) UIButton *speakBtn;
/**
 表情按钮
 */
@property (nullable, nonatomic, weak) UIButton *faceBtn;
/**
 图片按钮
 */
@property (nullable, nonatomic, weak) UIButton *pictureBtn;
/**
 转接人工客服
 */
@property (nullable, nonatomic, weak) UIButton *transferBtn;
/**
 工具条显示方式
 */
@property (nonatomic, assign) KFChatStatus chatToolViewType;

/**
 代理方法
 */
@property (nullable, nonatomic, weak) id<KFChatTooViewDelegate> delegate;
/**
 标准高度
 */
+ (CGFloat)defaultHeight;
/**
 *  移除recordView
 */
- (void)removeRecordView;

- (void)updateFrame;

@end
