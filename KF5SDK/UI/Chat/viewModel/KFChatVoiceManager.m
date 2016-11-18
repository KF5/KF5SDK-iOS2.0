//
//  KFChatVoiceManager.m
//  Pods
//
//  Created by admin on 16/3/19.
//
//

#import "KFChatVoiceManager.h"
#import "AFURLSessionManager.h"
#import "KFHelper.h"
#import <KF5SDK/KFDispatcher.h>
#import "MLAudioMeterObserver.h"
#import "MLAudioPlayer.h"
#import "AmrPlayerReader.h"
#import "AmrRecordWriter.h"

@interface KFChatVoice : NSObject
@property (nonnull, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, strong) void (^completionBlock)(NSString *local_path, NSError *error);
@end
@implementation KFChatVoice

- (instancetype)initWithURL:(NSString *)url completion:(void (^)(NSString *local_path,NSError *error))completion
{
    self = [super init];
    if (self) {
        _url = url;
        _completionBlock = completion;
    }
    return self;
}

@end

@interface KFChatVoiceManager()

@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;
@property (nonatomic, strong) AmrPlayerReader *amrReader;
@property (nonatomic, strong) MLAudioPlayer *player;


@property (nonatomic, strong) NSMutableSet <KFChatVoice *>*messageList;

/**正在播放的语音*/
@property (nonnull, nonatomic, copy) NSString *localPath;

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
- (void)playVoiceWithLocalPath:(NSString *)localPath completion:(void (^)(NSError *))completion{
    if ([self.player isPlaying]) [self.player stopPlaying];
    
    _localPath = localPath;
    
    MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
    AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
    amrReader.filePath = localPath;
    player.fileReaderDelegate = amrReader;
    player.receiveErrorBlock = ^(NSError *error){
        if (completion)completion(error);
    };
    player.receiveStoppedBlock = ^{
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

- (BOOL)isPlayingWithlocalPath:(NSString *)localPath{
    return [localPath isEqualToString:_localPath] && self.player.isPlaying;
}

#pragma mark - 下载相关
- (void)downloadDataWithURL:(NSString *)url completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion{
    if (url.length == 0){
        NSError *error = [NSError errorWithDomain:@"url不能为空" code:0 userInfo:nil];
        if(completion)completion(nil,error);
        return;
    }
    __block BOOL hasOldVoice = NO;
    [self.messageList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(KFChatVoice *voice, BOOL * _Nonnull stop) {
        if ([voice.url isEqualToString:url]) {// 如果存在旧的voice说明正在下载中,替换里面的message和completion
            voice.url = url;
            voice.completionBlock = completion;
            *stop = YES;
            hasOldVoice = YES;
        }
    }];
    
    if (hasOldVoice){
        return;
    }
    
    NSString *local_path = [self voicePathWithURL:url];
    if (local_path.length >0) {// 如果能再找地址,说明之前已经下载过,直接返回
        if (completion) completion(local_path,nil);
        return;
    }
    
    [self.messageList addObject:[[KFChatVoice alloc] initWithURL:url completion:completion]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __weak typeof(self)weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *localURL= [downloadURL URLByAppendingPathComponent:[NSString stringWithFormat:@"KF5SDK/%@",[KFHelper md5HexDigest:url]]];
        return localURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        __block KFChatVoice *oldVoice = nil;
        [weakSelf.messageList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(KFChatVoice *voice, BOOL * _Nonnull stop) {
            if ([voice.url isEqualToString:url]) {
                voice.completionBlock(filePath.path,error);
                oldVoice = voice;
                *stop = YES;
            }
        }];
        if (oldVoice) {
            [weakSelf.messageList removeObject:oldVoice];
        }
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
