//
//  KFChatVoiceManager.m
//  Pods
//
//  Created by admin on 16/3/19.
//
//

#import "KFChatVoiceManager.h"
#import "KFHelper.h"
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

@property (nonatomic,weak) KFMessageModel *currentPlayingMessageModel;

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
- (instancetype)init{
    self = [super init];
    if (self) {
        _messageList = [NSMutableSet set];
    }
    return self;
}

#pragma mark - 音频相关
#pragma mark 开始录制音频
-(void)startVoiceRecord{
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
        // 删除文件
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:filePath];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:filePath error:&err];
        }
        
        meterObserver.audioQueue = nil;
    };
    recorder.receiveCancleBlock = ^{
        meterObserver.audioQueue = nil;
        // 删除文件
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:filePath];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:filePath error:&err];
        }
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        
        meterObserver.audioQueue = nil;
        
        if ([weakSelf.delegate respondsToSelector:@selector(chatVoiceManager:recordVoice:error:)]) {
            [weakSelf.delegate chatVoiceManager:weakSelf recordVoice:nil error:error];
        }
        
        // 删除文件
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:filePath];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:filePath error:&err];
        }
        
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
- (void)playVoiceWithMessageModel:(KFMessageModel *)messageModel completion:(nullable void (^)(NSError * _Nullable))completion{
    if ([self.player isPlaying]) [self.player stopPlaying];
    
    messageModel.isPlaying = YES;
    
    if (messageModel.message.local_path.length == 0) {
        messageModel.isPlaying = NO;
        [[NSNotificationCenter defaultCenter]postNotificationName:KFChatVoiceStopPlayNotification object:messageModel];
        if (completion)completion(nil);
        return;
    }
    
    self.currentPlayingMessageModel = messageModel;
    
    MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
    AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
    amrReader.filePath = messageModel.message.local_path;
    player.fileReaderDelegate = amrReader;
    __weak KFMessageModel *weakMessageModel = messageModel;
    player.receiveErrorBlock = ^(NSError *error){
        weakMessageModel.isPlaying = NO;
        [[NSNotificationCenter defaultCenter]postNotificationName:KFChatVoiceStopPlayNotification object:weakMessageModel];
        if (completion)completion(error);
    };
    player.receiveStoppedBlock = ^{
        weakMessageModel.isPlaying = NO;
        [[NSNotificationCenter defaultCenter]postNotificationName:KFChatVoiceStopPlayNotification object:weakMessageModel];
        if (completion)completion(nil);
    };
    self.player = player;
    self.amrReader = amrReader;
    [player startPlaying];
}

#pragma mark  停止音频播放
-(void)stopVoicePlayingMessage{
    [self.player stopPlaying];
}
#pragma mark 获取音频时长
+ (double)voiceDurationWithlocalPath:(NSString *)localPath{
    return [AmrPlayerReader durationOfAmrFilePath:localPath];
}

- (BOOL)isPlayingWithMessageModel:(KFMessageModel *)messageModel{
    return self.currentPlayingMessageModel == messageModel  && self.player.isPlaying;
}

#pragma mark - 下载相关
- (void)downloadDataWithMessageModel:(KFMessageModel *)messageModel{
    if (messageModel.message.url.length == 0 || messageModel.message.local_path.length > 0 || [self.messageList containsObject:messageModel]){
        return;
    }
    
    NSString *local_path = [self voicePathWithURL:messageModel.message.url];
    if (local_path.length > 0) {
        messageModel.message.local_path = local_path;
        messageModel.voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:local_path];
        [messageModel updateFrame];
        [[NSNotificationCenter defaultCenter]postNotificationName:KFChatVoiceDidDownloadNotification object:messageModel];
        return;
    }
    [self.messageList addObject:messageModel];
    
    __weak typeof(self)weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:messageModel.message.url]] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSURL *localURL= [[[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:[NSString stringWithFormat:@"KF5SDK/%@",[KFHelper md5HexDigest:messageModel.message.url]]];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:localURL error:nil];
            messageModel.message.local_path = localURL.path;
            messageModel.voiceLength = [KFChatVoiceManager voiceDurationWithlocalPath:messageModel.message.local_path];
            [messageModel updateFrame];
            [[NSNotificationCenter defaultCenter]postNotificationName:KFChatVoiceDidDownloadNotification object:messageModel];
        }
        [weakSelf.messageList removeObject:messageModel];
    }];
    [downloadTask resume];
}

- (NSString *)voicePathWithURL:(NSString *)urlString{
    if (urlString.length == 0) return nil;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *md5 = [KFHelper md5HexDigest:urlString];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"KF5SDK"] stringByAppendingPathComponent:md5];
    //判断沙盒下是否存在
    if ([fm fileExistsAtPath:filePath]) {
        return filePath;
    }else{
        return nil;
    }
}


@end
