//
//  KFChatVoiceManager.h
//  Pods
//
//  Created by admin on 16/3/19.
//
//

#import <UIKit/UIKit.h>

@class KFMessageModel;
@class KFChatVoiceManager;

UIKIT_EXTERN _Nonnull NSNotificationName const KFChatVoiceDidDownloadNotification;
UIKIT_EXTERN _Nonnull NSNotificationName const KFChatVoiceStopPlayNotification;

@protocol KFChatVoiceManagerDelegate <NSObject>

/**
 *  录音振幅变化
 *
 *  @param amplitude   录音振幅
 */
-(void)chatVoiceManager:(nonnull KFChatVoiceManager *)voiceManager recordingAmplitude:(CGFloat)amplitude;
/**
 录音完成的代理

 @param data 音频数据
 @param error 错误信息,为nil表示为成功
 */
- (void)chatVoiceManager:(nonnull KFChatVoiceManager *)voiceManager recordVoice:(nullable NSData *)data error:(nullable NSError *)error;

@end


@interface KFChatVoiceManager : NSObject
/**
 *  单例
 */
+ (nonnull instancetype)sharedChatVoiceManager;

/**
 代理
 */
@property (nullable, nonatomic, weak) id<KFChatVoiceManagerDelegate> delegate;

#pragma mark - 音频相关
/**
 *  开始录制音频
 */
-(void)startVoiceRecord;
/**
 *  取消录制音频
 */
- (void)cancleVoiveRecord;
/**
 *  停止录制音频
 */
-(void)stopVoiceRecord;
/**
 *  播放音频消息
 *
 *  @param messageModel 消息模型
 *  @param completion 成功或失败的回调
 *
 @warning 通过KFChatVoiceDidDownloadNotification获取下载完成通知
 */
- (void)playVoiceWithMessageModel:(nonnull KFMessageModel *)messageModel  completion:(nullable void (^)(NSError  * _Nullable error))completion;
/**
 *  停止音频播放
 */
-(void)stopVoicePlayingMessage;
/**
 获取音频时长

 @param localPath 本地语音路径
 @return 时长
 */
+ (double)voiceDurationWithlocalPath:(nonnull NSString *)localPath;
/**
 判断是否是正在播放的文件

 @param messageModel 消息模型
 @return 是否正在播放
 */
- (BOOL)isPlayingWithMessageModel:(nonnull KFMessageModel *)messageModel;

#pragma mark - 下载相关

/**
 下载音频

 @param messageModel 消息模型
 @warning 通过KFChatVoiceDidDownloadNotification获取下载完成通知
 */
- (void)downloadDataWithMessageModel:(nonnull KFMessageModel *)messageModel;

@end
