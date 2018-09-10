//
//  KFHttpTool.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import <Foundation/Foundation.h>
#import "KFDispatcher.h"

@interface KFFileModel : NSObject
/**
 文件二进制数据
 */
@property (nonnull, nonatomic, strong) NSData *fileData;

/**
 文件名称,在一次上传中,不能使用相同的fileName
 */
@property (nullable, nonatomic, copy) NSString *fileName;

/**
 文件类型,默认为image/jpeg
 */
@property (nullable, nonatomic, copy) NSString *mimeType;

@end

@interface KFHttpTool : NSObject

/**
 设置超时时间,默认30s
 */
+ (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

#pragma mark - 用户接口
/**
 用户创建

 @param params 参数,如下
 @{
    @"email":@"",  // 用户的邮箱,选其一
    @"phone":@"",  // 用户的手机号,选其一
    @"name":@""    // 用户的昵称,选填
 };
 @warning   email和phone只能选其一
 */
+ (nullable NSURLSessionDataTask *)createUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 用户登录

 @param params 参数,如下
 @{
    @"email":@"",  // 用户的邮箱,选其一
    @"phone":@""   // 用户的手机号,选其一
 };
 @warning   email和phone只能选其一,两者都填默认优先使用手机号验证用户,如果手机号没有查找到用户,则使用邮箱验证用户
 */
+ (nullable NSURLSessionDataTask *)loginUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取用户信息
 @param params 参数,如下:
 @{
    @"userToken":@""    // 用户唯一标示,可通过创建或登录用户获得,必填
 };
 */
+ (nullable NSURLSessionDataTask *)getUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 更新用户信息

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"email":@"",       // 邮箱,选填
    @"phone":@"",       // 手机号,选填
    @"name":@""         // 昵称,选填
    @"user_fields":@"",      // 用户自定义字段(选填,除非必要,不建议使用),字符串格式如:'[{"name":"field_xxx","value":"value"},{"name":"field_xxx","value":"18"}]',需要将数组转成JSON字符串使用,选填
    @"organization_id":@"",  // 公司组织字段(选填,除非必要,不建议使用)
 };
 
 @warning   @"user_fields"中,提交的name(field_xxx)需要查看kf5后台用户自定义字段的设置里获取对应的字段参数
            @"organization_id"提交的值,必须是系统中存在的organization_id,如果不存在,则会提交失败
 */
+ (nullable NSURLSessionDataTask *)updateUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 保存deviceToken

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"deviceToken":@""  // 用户deviceToken,必填
 };
 */
+ (nullable NSURLSessionDataTask *)saveTokenWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 删除deviceToken
 
 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"deviceToken":@""  // 用户deviceToken,必填
 };
 */
+ (nullable NSURLSessionDataTask *)deleteTokenWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;


#pragma mark - 文档接口
/**
 获取文档分区列表

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"per_page":@(),    // 每页的数量,默认30,选填
    @"page":@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocCategoriesListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档分类列表
 
 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"category_id":@(),  // 分区的id,如果为空,获取所有的分类,选填
    @"per_page":@(),     // 每页的数量,默认30,选填
    @"page":@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocForumListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档列表

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"forum_id":@(),     // 分类的id,如果为空,获取所有的文档列表,选填
    @"per_page":@(),     // 每页的数量,默认30,选填
    @"page":@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocPostListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档内容

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"post_id":@(),      // 文档的id,必填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocumentWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 搜索文档

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"query":@"",       // 搜索关键字,必填
    @"full_search":@()   // 是否开启全文搜索,0或1,默认不开启,选填
 };
 */
+ (nullable NSURLSessionDataTask *)searchDocumentWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

#pragma mark - 工单接口
/**
 获取工单列表

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"per_page":@(),     // 每页工单的数量,默认30,选填
    @"page":@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getTicketListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取工单内容

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"ticket_id":@(),    // 工单的id,必填
    @"per_page":@(),     // 每页工单的数量,默认30,选填
    @"page":@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取工单详情

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"ticket_id":@()     // 工单的id,必填
 };
 */
+ (nullable NSURLSessionDataTask *)getTicketDetailMessageWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 回复工单

 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"ticket_id":@(),    // 工单的id,必填
    @"content":@"",     // 回复内容,必填
    @"uploads":@[]      // 附件token数组,选填
 };
 */
+ (nullable NSURLSessionDataTask *)updateTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 工单满意度评价
 
 @param params 参数,如下:
 @{
    @"userToken":@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    @"ticket_id":@(),    // 工单的id,必填
    @"rating":@(),      // 满意度,必填
    @"content":@""      // 满意度评价内容,选填
 };
 */
+ (nullable NSURLSessionDataTask *)ratingTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^)(NSDictionary * _Nullable result, NSError * _Nullable error))completion;
/**
 创建工单

 @param params 参数,如下:
 @{
    @"userToken":@"",       // 用户唯一标示,可通过创建或登录用户获得,必填
    @"title":@"",           // 工单的标题,必填
    @"content":@"",         // 回复内容,必填
    @"uploads":@[],         // 附件token数组,选填
    @"custom_fields":@""     // 自定义字段,如字符串'[{"name":"field_123","value":"手机端"},{"name":"field_321","value":"IOS"}]',需要将数组转成JSON字符串使用,选填
 };
 
 @warning   @"custom_fields"中,提交的name(field_xxx)需要查看kf5后台工单自定义字段的设置里获取对应的字段参数
 */
+ (nullable NSURLSessionDataTask *)createTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取自定义字段
 */
+ (nullable NSURLSessionDataTask *)getCustomFieldsWithCompletion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

#pragma mark - 上传文件接口
/**
 工单上传文件

 @param userToken  用户唯一标示,可通过创建或登录用户获得,必填
 @param fileModels 文件数组,必填
 @warning 文件大小根据您KF5平台的套餐决定,所以请开发者自行压缩,详细请见http://www.kf5.com/product/pricing
 */
+ (nullable NSURLSessionDataTask *)uploadWithUserToken:(nonnull NSString *)userToken fileModels:(nonnull NSArray <KFFileModel *>*)fileModels uploadProgress:(nullable void (^)(NSProgress *_Nullable progress))uploadProgressBlock completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

@end
