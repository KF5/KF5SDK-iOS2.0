//
//  KFHttpTool.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

#import <Foundation/Foundation.h>

@interface KFFileModel : NSObject
/**
 文件二进制数据
 */
@property (nonnull, nonatomic, strong) NSData *fileData;

/**
 文件名称,默认值为当前的时间戳.jpg,如
 */
@property (nonnull, nonatomic, copy) NSString *fileName;

/**
 文件类型,默认为image/jpeg
 */
@property (nonnull, nonatomic, copy) NSString *mimeType;

@end

@interface KFHttpTool : NSObject

/**
 设置超时时间,默认30s
 */
+ (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

#pragma mark - 用户接口
/**
 用户创建
 
 @param email       用户的邮箱,选其一
 @param phone       用户的手机号,选其一
 @param name        用户的昵称,选填
 @warning   email和phone只能选其一
            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)createUserWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 用户登录
 
 @param email       用户的邮箱,选其一
 @param phone       用户的手机号,选其一
 @warning email和phone只能选其一,两者都填默认优先手机号
          需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)loginUserWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取用户信息
 
 @param userToken   用户唯一标示,可通过创建或登录用户获得,必填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getUserWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 更新用户信息
 
 @param userToken   用户唯一标示,可通过创建或登录用户获得,必填
 @param email       更新邮箱,选填
 @param phone       更新手机号,选填
 @param name        更新昵称,选填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)updateUserWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 保存deviceToken
 
 @param userToken    用户的唯一标示,必填
 @param deviceToken  用户deviceToken,必填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)saveTokenWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 删除deviceToken
 
 @param userToken    用户的唯一标示,必填
 @param deviceToken  用户deviceToken,必填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)deleteTokenWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;


#pragma mark - 文档接口

/**
 获取文档分区列表
 
 @param userToken   用户唯一标示,可通过创建或登录用户获得,必填
 @param per_page    每页的数量,默认30,选填
 @param page        当前请求第几页,默认1,选填
 @warning           需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getDocCategoriesListWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档分类列表
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param category_id  分区的id,如果为空,获取所有的分类,选填
 @param per_page     每页的数量,默认30,选填
 @param page         当前请求第几页,默认1,选填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getDocForumListWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档列表
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param forum_id     分类的id,如果为空,获取所有的文档列表,选填
 @param per_page     每页的数量,默认30,选填
 @param page         当前请求第几页,默认1,选填
 @warning            需将上述参数包装成字典放到params里
 */

+ (nullable NSURLSessionDataTask *)getDocPostListWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档内容
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param post_id      文档的id,必填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getDocumentWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 搜索文档
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param query        搜索关键字,必填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)searchDocumentWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

#pragma mark - 工单接口

/**
 获取工单列表
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param per_page     每页工单的数量,默认30,选填
 @param page         当前请求第几页,默认1,选填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getTicketListWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取工单内容
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param ticket_id    工单的id,必填
 @param per_page     每页工单的数量,默认30,选填
 @param page         当前请求第几页,默认1,选填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getTicketWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取工单详情
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param ticket_id    工单的id,必填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)getTicketDetailMessageWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 回复工单
 
 @param userToken    用户唯一标示,可通过创建或登录用户获得,必填
 @param ticket_id    工单的id,必填
 @param content      回复内容,必填
 @param uploads      附件图片token数组,选填
 @warning            需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)updateTicketWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 创建工单
 
 @param userToken     用户唯一标示,可通过创建或登录用户获得,必填
 @param title         工单标题,必填
 @param content       回复内容,必填
 @param uploads   附件图片token数组,选填
 @param custom_fields 自定义字段,如@[@{@"name":@"field_123",@"value":@"手机端"},@{@"name":@"field_321",@"value":@"IOS"}],需要将数组转成JSONString使用,选填
 @warning 自定义字段的key需要使用获取自定义字段的接口获取
          需将上述参数包装成字典放到params里
 */
+ (nullable NSURLSessionDataTask *)createTicketWithParams:(nullable NSDictionary *)params completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

/**
 获取自定义字段
 */
+ (nullable NSURLSessionDataTask *)getCustomFieldsWithCompletion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

#pragma mark - 上传文件接口
/**
 工单上传文件

 @param userToken           用户唯一标示,可通过创建或登录用户获得,必填
 @param fileModels          文件数组,必填
 @warning 文件大小根据您KF5平台的套餐决定,所以请开发者自行压缩,详细请见http://www.kf5.com/product/pricing
 */
+ (nullable NSURLSessionDataTask *)uploadWithUserToken:(nonnull NSString *)userToken fileModels:(nonnull NSArray <KFFileModel *>*)fileModels uploadProgress:(nullable void (^)(NSProgress *_Nullable progress))uploadProgressBlock completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 IM上传图片

 @param userToken   用户唯一标示,可通过创建或登录用户获得,必填
 @param imageData   图片,必填
 @warning 文件大小根据您KF5平台的套餐决定,所以请开发者自行压缩,详细请见http://www.kf5.com/product/pricing
 */
+ (nullable NSURLSessionDataTask *)chatWithUserToken:(nonnull NSString *)userToken imageData:(nonnull NSData *)imageData uploadProgress:(nullable void (^)(NSProgress *_Nullable progress))uploadProgressBlock completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 IM上传语音

 @param userToken  用户唯一标示,可通过创建或登录用户获得,必填
 @param voice      语音,必填
 @warning 文件大小根据您KF5平台的套餐决定,所以请开发者自行压缩,详细请见http://www.kf5.com/product/pricing
 */
+ (nullable NSURLSessionDataTask *)chatWithUserToken:(nonnull NSString *)userToken voice:(nonnull NSData *)voice uploadProgress:(nullable void  (^)(NSProgress *_Nullable progress))uploadProgressBlock completion:(nonnull void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

@end
