//
//  KFDispatcher.h
//  Pods
//
//  Created by admin on 16/10/19.
//
//

#ifndef KFDispatcher_h
#define KFDispatcher_h

#import <Foundation/Foundation.h>

static NSString * _Nonnull const KF5Email        = @"email";
static NSString * _Nonnull const KF5Phone        = @"phone";
static NSString * _Nonnull const KF5Name         = @"name";
static NSString * _Nonnull const KF5UserToken    = @"userToken";
static NSString * _Nonnull const KF5DeviceToken  = @"deviceToken";
static NSString * _Nonnull const KF5PerPage      = @"per_page";
static NSString * _Nonnull const KF5Page         = @"page";
static NSString * _Nonnull const KF5CategoryId   = @"category_id";
static NSString * _Nonnull const KF5ForumId      = @"forum_id";
static NSString * _Nonnull const KF5PostId       = @"post_id";
static NSString * _Nonnull const KF5Query        = @"query";
static NSString * _Nonnull const KF5TicketId     = @"ticket_id";
static NSString * _Nonnull const KF5Title        = @"title";
static NSString * _Nonnull const KF5Content      = @"content";
static NSString * _Nonnull const KF5Uploads      = @"uploads";
static NSString * _Nonnull const KF5CustomFields = @"custom_fields";
static NSString * _Nonnull const KF5Rating       = @"rating";
static NSString * _Nonnull const KF5FullSearch   = @"full_search";
static NSString * _Nonnull const KF5UserFields   = @"user_fields";
static NSString * _Nonnull const KF5OrganizationId = @"organization_id";


/**
 *  消息发送状态
 */
typedef NS_ENUM(NSInteger,KFMessageStatus) {
    KFMessageStatusSending = 0,
    KFMessageStatusSuccess,
    KFMessageStatusFailure,
    KFMessageStatusRecalling
};
/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger,KFMessageType) {
    KFMessageTypeText = 0,
    KFMessageTypeImage,
    KFMessageTypeVoice,
    KFMessageTypeSystem,
    KFMessageTypeOther,
    KFMessageTypeCustom,
    KFMessageTypeCard
};
/**
 *  消息来自于
 */
typedef NS_ENUM(NSInteger,KFMessageFrom) {
    KFMessageFromMe = 0,
    KFMessageFromOther
};
/**
 *  聊天客服角色
 */
typedef NS_ENUM(NSInteger,KFAgentRole) {
    KFAgentRoleAgent = 0,    // 人工客服
    KFAgentRoleAI            // 机器人客服
};

/**
 *  当前对话状态
 */
typedef NS_ENUM(NSInteger,KFChatStatus) {
    KFChatStatusNone = 0,
    KFChatStatusAIAgent,    // 正在和机器人对话
    KFChatStatusChatting,   // 正在进行对话
    KFChatStatusQueue       // 正在排队
};

/**
 *  错误类型
 */
typedef NS_ENUM(NSInteger,KFErrorCode) {
    KFErrorCodeNone                 = 0,     // 没有错误
    KFErrorCodeDeprecated           = 1000,  // 过期方法错误提醒
    KFErrorCodeAgentOffline         = 1001,  // 没有客服在线
    KFErrorCodeAgentBusy            = 1002,  // 客服忙碌
    KFErrorCodeNotInServiceTime     = 1003,  // 不在服务时间
    KFErrorCodeQueueError           = 1004,  // 排队失败
    KFErrorCodeQueueTooLong         = 1005,  // 排队人数过多,超出限制
    KFErrorCodeSocketContentError   = 5000,  // 服务器连接失败
    KFErrorCodeSocketTimeOut        = 303,   // 服务器请求超时
    KFErrorCodeParamError           = 40000, // 参数错误
    KFErrorCodeNetWorkOff           = 40001, // 网络断开
    KFErrorCodeSocketError          = 40002, // 服务器请求失败
    KFErrorCodeSocketOff            = 30001, // 与服务器断开连接
    KFErrorCodeRecordTimeShort      = 20000, // 录音时间过短
    
    KFErrorCodeSignError            = 20003, // SIGN验证失败
    KFErrorCodeAppIdNotFound        = 10005, // appid参数未获取到
    KFErrorCodeUserTokenError       = 20004, // userToken验证失败
    KFErrorCodeUserTokenNil         = 20006, // userToken参数未找到
    KFErrorCodeEmailorPhoneNil      = 10009, // 请传递邮箱或手机参数
    KFErrorCodeUserEmailError       = 20210, // 邮箱参数格式不正确
    KFErrorCodeUserPhoneError       = 20220, // 手机参数格式不正确
    KFErrorCodeUserRegistered       = 20200, // 该邮箱或手机号已被注册
    KFErrorCodeUserNone             = 10050, // 用户不存在
    KFErrorCodeUserStop             = 20106, // 该用户已被暂停
    KFErrorCodeUserOverCreatedNum   = 90000, // 创建用户超过限制
    
    KFErrorCodeDeviceTokenNil       = 20007, // deviceToken参数没有找到
    KFErrorCodeDeviceTokenError     = 20010, // devictToken不能为空
    
    KFErrorCodeTicketNoFound        = 30000, // 工单不存在
    KFErrorCodeTicketNoPermission   = 30005, // 没有权限查看工单
    KFErrorCodeTitleorContentNil    = 10010, // 标题或内容不能为空
    KFErrorCodeCommentNoFound       = 50000, // 回复不存在或者已被删除
    
    KFErrorCodeCategoryNoFound      = 60000, // 分区不存在或已被删除
    KFErrorCodeForumNoFound         = 70000, // 分类不存在或已被删除
    KFErrorCodeDocNoFound           = 80000, // 文档不存在或已被删除
    
    KFErrorCodeUploadError          = 40050, // 文件上传失败
    KFErrorCodeUploadSizeOver       = 40100, // 文件大小超过限制
    KFErrorCodeUploadTypeInvalid    = 40101, // 文件类型不支持
    
};


#endif /* KFDispatcher_h */
