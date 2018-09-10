//
//  KFMessage.h
//  Pods
//
//  Created by admin on 16/10/19.
//
//

#import <UIKit/UIKit.h>
#import "KFDispatcher.h"

@interface KFMessage : NSObject

/**
 消息的id
 */
@property (nonatomic, assign) NSInteger message_id;
/**
 发送人的id
 */
@property (nonatomic, assign) NSInteger user_id;
/**
 发送人的昵称
 */
@property (nullable, nonatomic, copy) NSString *name;
/**
 发送人
 */
@property (nonatomic, assign) KFMessageFrom messageFrom;
/**
 消息类型
 */
@property (nonatomic, assign) KFMessageType messageType;
/**
 消息内容
 */
@property (nullable, nonatomic, copy) NSString *content;
/**
 图片或语音的url
 */
@property (nullable, nonatomic, copy) NSString *url;
/**
 图片或语音的本地路径
 */
@property (nullable, nonatomic, copy) NSString *local_path;
/**
 消息创建时间
 */
@property (nonatomic, assign) double created;
/**
 消息发送状态
 */
@property (nonatomic, assign) KFMessageStatus messageStatus;
/**
 传输标记
 */
@property (nonatomic, assign) long long timestamp;
/**
 图片的宽度
 */
@property (nonatomic, assign) CGFloat imageWidth;
/**
 图片的高度
 */
@property (nonatomic, assign) CGFloat imageHeight;
/**
 是否撤回
 */
@property (nonatomic, assign) BOOL recalled;

@property (nonatomic, assign) BOOL is_read;

@end
