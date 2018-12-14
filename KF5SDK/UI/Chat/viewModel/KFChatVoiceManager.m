//
//  KFChatVoiceManager.m
//  Pods
//
//  Created by admin on 16/3/19.
//
//

#import "KFChatVoiceManager.h"
#import "KFCategory.h"
#import "MLAudioMeterObserver.h"
#import "MLAudioPlayer.h"
#import "AmrPlayerReader.h"
#import "AmrRecordWriter.h"
#import "KFMessageModel.h"

NSString * const KFChatVoiceDidDownloadNotification = @"KF5ChatVoiceDidDownloadNotification";
NSString * const KFChatVoiceStopPlayNotification = @"KF5ChatVoiceStopPlayNotification";

@interface KFChatVoiceManager()

@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;
@property (nonatomic, strong) AmrPlayerReader *amrReader;
@property (nonatomic, strong) MLAudioPlayer *player;

@property (nonatomic, strong) NSMutableSet <KFMessageModel *>*messageList;

@end

@implementation KFChatVoiceManager

static KFChatVoiceManager *sharedManager = nil;
+ (instancetype)sharedChatVoiceManager{
    if (sharedManager == nil) {
        sharedManager = [[self alloc]init];
    }
    return sharedManager;
}
+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super allocWithZone:zone];
    });
    return sharedManager;
}

- (NSMutableSet<KFMessageModel *> *)messageList{
    if (_messageList == nil) {
        _messageList = [NSMutableSet set];
    }
    return _messageList;
}

#pragma mark - 音频相关
#pragma mark 开始录制音频
-(void)startVoiceRecord{
    
    [self stopVoicePlayingMessage];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"KF5SDK"];
    AmrRecordWriter *amrWriter = [[AmrRecordWriter alloc]init];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",[KFHelper md5HexDigest:[NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970]]]];
    amrWriter.filePath = filePath;
    amrWriter.maxSecondCount = 62;
    
    __weak typeof(self)weakSelf = self;
    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
    meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
        
        if ([weakSelf.delegate respondsToSelector:@selector(chatVoiceManager:recordingAmplitude:)]) {
            [weakSelf.delegate chatVoiceManager:weakSelf recordingAmplitude:[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]];
        }
        
    };
    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
        if ([weakSelf.delegate respondsToSelector:@selector(chatVoiceManager:recordVoice:error:)]) {
            [weakSelf.delegate chatVoiceManager:weakSelf recordVoice:nil error:error];
        }
    };
    
    MLAudioRecorder *recorder = [[MLAudioRecorder alloc]init];
    
    // 录音完成的处理
    void (^completion)(void) = ^{
        // 删除文件
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:filePath];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:filePath error:&err];
        }
        
        weakSelf.meterObserver.audioQueue = nil;
        weakSelf.recorder = nil;
        weakSelf.meterObserver = nil;
        weakSelf.amrWriter = nil;
    };
    
    recorder.receiveStoppedBlock = ^{
        if ([AmrPlayerReader durationOfAmrFilePath:filePath] < 1) {
            NSError *error = [[NSError alloc] initWithDomain:KF5Localized(@"录音时间过短") code:KFErrorCodeRecordTimeShort userInfo:@{NSLocalizedDescriptionKey:@"录音时间过短,不能发送"}];
            if ([weakSelf.delegate respondsToSelector:@selector(chatVoiceManager:recordVoice:error:)]) {
                [weakSelf.delegate chatVoiceManager:weakSelf recordVoice:nil error:error];
            }
        }else{
            if ([weakSelf.delegate respondsToSelector:@selector(chatVoiceManager:recordVoice:error:)]) {
                NSData *data = [NSData dataWithContentsOfFile:amrWriter.filePath];
                [weakSelf.delegate chatVoiceManager:weakSelf recordVoice:data error:nil];
            }
        }
        completion();
    };
    recorder.receiveCancleBlock = ^{
        completion();
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        
        if ([weakSelf.delegate respondsToSelector:@selector(chatVoiceManager:recordVoice:error:)]) {
            [weakSelf.delegate chatVoiceManager:weakSelf recordVoice:nil error:error];
        }
        completion();
    };
    
    recorder.bufferDurationSeconds = 0.25;
    recorder.fileWriterDelegate = amrWriter;
    
    [recorder startRecording];
    
    meterObserver.audioQueue = recorder->_audioQueue;
    
    self.recorder = recorder;
    self.meterObserver = meterObserver;
    self.amrWriter = amrWriter;
}

#pragma mark 取消录制音频
- (void)cancleVoiveRecord{
    [self.recorder cancleRecording];
}

#pragma mark 停止录制音频
-(void)stopVoiceRecord{
    [self.recorder stopRecording];
}

#pragma mark 播放音频消息
- (void)playVoiceWithMessageModel:(KFMessageModel *)messageModel{
    
    // 播放完成的处理
    __weak typeof(self) weakself = self;
    void (^playCompletion)(NSError *error) = ^(NSError *error){
        weakself.player = nil;
        weakself.amrReader = nil;
        [weakself notificationWithName:KFChatVoiceStopPlayNotification model:weakself.currentPlayingMessageModel error:error];
       weakself.currentPlayingMessageModel = nil;
    };
    
    if ([self.player isPlaying]) [self.player stopPlaying];
    self.currentPlayingMessageModel = messageModel;
    if (messageModel.message.local_path.length == 0) {
        playCompletion(nil);
        return;
    }
    
    MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
    AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
    amrReader.filePath = messageModel.message.local_path;
    player.fileReaderDelegate = amrReader;
    
    player.receiveErrorBlock = ^(NSError *error){
        playCompletion(error);
    };
    player.receiveStoppedBlock = ^{
        playCompletion(nil);
    };
    self.player = player;
    self.amrReader = amrReader;
    [player startPlaying];
}

#pragma mark  停止音频播放
-(void)stopVoicePlayingMessage{
    if ([self.player isPlaying]) [self.player stopPlaying];
}
#pragma mark 获取音频时长
+ (double)voiceDurationWithlocalPath:(NSString *)localPath{
    return [AmrPlayerReader durationOfAmrFilePath:localPath];
}

- (BOOL)isPlayingWithMessageModel:(KFMessageModel *)messageModel{
    return [messageModel isEqual:self.currentPlayingMessageModel] && self.player.isPlaying;
}

#pragma mark - 下载相关
- (void)downloadDataWithMessageModel:(KFMessageModel *)messageModel{
    if (messageModel.message.url.length == 0 || messageModel.message.local_path.length > 0 || [self.messageList containsObject:messageModel]){
        return;
    }
    
    NSString *local_path = [self filePathWithString:messageModel.message.url];
    if ([ [NSFileManager defaultManager] fileExistsAtPath:local_path]) {
        messageModel.message.local_path = local_path;
        messageModel.voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:local_path];
        dispatch_async(dispatch_get_main_queue(), ^{
            [messageModel updateFrame];
            [self  notificationWithName:KFChatVoiceDidDownloadNotification model:messageModel error:nil];
        });
        return;
    }
    [self.messageList addObject:messageModel];
    
    __weak typeof(self)weakSelf = self;
    [[[NSURLSession sharedSession] downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:messageModel.message.url]] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [weakSelf.messageList removeObject:messageModel];
            if (!error) {
                NSURL *localURL = [NSURL fileURLWithPath:local_path];
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:localURL error:nil];
                messageModel.message.local_path = localURL.path;
                messageModel.voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:messageModel.message.local_path];
            }else{
                messageModel.voiceLength = 0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [messageModel updateFrame];
                [weakSelf  notificationWithName:KFChatVoiceDidDownloadNotification model:messageModel error:error];
            });
    }] resume];
}

- (NSString *)voicePathWithURL:(NSString *)urlString{
    if (urlString.length == 0) return nil;
    
    NSString *filePath = [self filePathWithString:urlString];
    //判断沙盒下是否存在
    if ([ [NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }else{
        return nil;
    }
}
#pragma mark 其他
- (NSString *)filePathWithString:(NSString *)string {
    return  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"KF5SDK"] stringByAppendingPathComponent:[KFHelper md5HexDigest:string]];
}

- (void)notificationWithName:(NSString *)name model:(KFMessageModel *)model error:(NSError *)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    if (model) dict[@"model"] = model;
    if (error) dict[@"error"] = error;
    [[NSNotificationCenter defaultCenter]postNotificationName:name object: dict];
}

@end
