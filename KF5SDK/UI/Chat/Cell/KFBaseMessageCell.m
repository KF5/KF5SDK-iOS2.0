//
//  KFBaseMessageCell.m
//  Pods
//
//  Created by admin on 16/10/27.
//
//

#import "KFBaseMessageCell.h"
#import "KFHelper.h"
#import "KFLoadView.h"

@implementation KFBaseMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 时间显示
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.font = KF5Helper.KF5TimeFont;
        timeLabel.textColor = KF5Helper.KF5TimeColor;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:timeLabel];
        _timeLabel = timeLabel;
        
        //  头像
        UIImageView *headerImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:headerImageView];
        _headerImageView = headerImageView;
        
        // 内容背景
        UIImageView *messageBgView = [[UIImageView alloc]init];
        [self.contentView addSubview:messageBgView];
        _messageBgView = messageBgView;
        
        // loadView的处理
        KFLoadView *loadView = [[KFLoadView alloc]init];
        __weak typeof(self)weakSelf = self;
        [loadView setClickFailureBtnBlock:^{
            if ([weakSelf.cellDelegate respondsToSelector:@selector(cell:reSendMessageWithMessageModel:)]) {
                [weakSelf.cellDelegate cell:weakSelf reSendMessageWithMessageModel:weakSelf.messageModel];
            }
        }];
        loadView.hidden = YES;
        [self.contentView addSubview:loadView];
        _loadView = loadView;
    }
    return self;
}

- (void)setMessageModel:(KFMessageModel *)messageModel{
    
    if (self.messageModel && self.messageModel.message.messageStatus != KFMessageStatusSuccess) {
        @try {[self.messageModel removeObserver:self forKeyPath:@"message.messageStatus"];
        } @catch (NSException *exception) {}
    }
    
    [super setMessageModel:messageModel];
    
    _timeLabel.text = messageModel.timeText;
    _timeLabel.frame = messageModel.timeFrame;
    
    _headerImageView.image = messageModel.headerImage;
    _headerImageView.frame = messageModel.headerFrame;
    
    _messageBgView.image = messageModel.messageViewBgImage;
    _messageBgView.highlightedImage = messageModel.messageViewBgImageH;
    _messageBgView.frame = messageModel.messageBgViewFrame;
    
    _loadView.frame = messageModel.loadViewFrame;
    _loadView.status = messageModel.message.messageStatus;
    if (self.messageModel && self.messageModel.message.messageStatus != KFMessageStatusSuccess) {
            [self.messageModel addObserver:self forKeyPath:@"message.messageStatus" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(![keyPath isEqualToString:@"message.messageStatus"])return;
    _loadView.status = self.messageModel.message.messageStatus;
    if (self.messageModel.message.messageStatus == KFMessageStatusSuccess) {
        @try {[self.messageModel removeObserver:self forKeyPath:@"message.messageStatus"];
        } @catch (NSException *exception) {}
    }
}

- (void)dealloc{
    if (self.messageModel && self.messageModel.message.messageStatus != KFMessageStatusSuccess){
        @try {[self.messageModel removeObserver:self forKeyPath:@"message.messageStatus"];
        } @catch (NSException *exception) {}
    }
}

@end
