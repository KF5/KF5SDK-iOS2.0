//
//  KFHttpTool.h
//  Pods
//
//  Created by admin on 16/10/9.
//
//

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
 @{ // 注意:KF5Email为静态常量,下同
    KF5Email:@"",  // 用户的邮箱,选其一
    KF5Phone:@"",  // 用户的手机号,选其一
    KF5Name:@""    // 用户的昵称,选填
 };
 @warning   email和phone只能选其一
 */
+ (nullable NSURLSessionDataTask *)createUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 用户登录

 @param params 参数,如下
 @{ // 注意:KF5Email为静态常量,下同
    KF5Email:@"",  // 用户的邮箱,选其一
    KF5Phone:@""   // 用户的手机号,选其一
 };
 @warning   email和phone只能选其一,两者都填默认优先使用手机号验证用户,如果手机号没有查找到用户,则使用邮箱验证用户
 */
+ (nullable NSURLSessionDataTask *)loginUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取用户信息
 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@""    // 用户唯一标示,可通过创建或登录用户获得,必填
 };
 */
+ (nullable NSURLSessionDataTask *)getUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 更新用户信息

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5Email:@"",       // 邮箱,选填
    KF5Phone:@"",       // 手机号,选填
    KF5Name:@""         // 昵称,选填
 };
 */
+ (nullable NSURLSessionDataTask *)updateUserWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 保存deviceToken

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5DeviceToken:@""  // 用户deviceToken,必填
 };
 */
+ (nullable NSURLSessionDataTask *)saveTokenWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 删除deviceToken
 
 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5DeviceToken:@""  // 用户deviceToken,必填
 };
 */
+ (nullable NSURLSessionDataTask *)deleteTokenWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;


#pragma mark - 文档接口
/**
 获取文档分区列表

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5PerPage:@(),    // 每页的数量,默认30,选填
    KF5Page:@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocCategoriesListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档分类列表
 
 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5CategoryId:@(),  // 分区的id,如果为空,获取所有的分类,选填
    KF5PerPage:@(),     // 每页的数量,默认30,选填
    KF5Page:@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocForumListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档列表

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5ForumId:@(),     // 分类的id,如果为空,获取所有的文档列表,选填
    KF5PerPage:@(),     // 每页的数量,默认30,选填
    KF5Page:@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocPostListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取文档内容

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5PostId:@(),      // 文档的id,必填
 };
 */
+ (nullable NSURLSessionDataTask *)getDocumentWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 搜索文档

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5Query:@"",       // 搜索关键字,必填
    KF5FullSearch:@()   // 是否开启全文搜索,0或1,默认不开启,选填
 };
 */
+ (nullable NSURLSessionDataTask *)searchDocumentWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;

#pragma mark - 工单接口
/**
 获取工单列表

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5PerPage:@(),     // 每页工单的数量,默认30,选填
    KF5Page:@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getTicketListWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取工单内容

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5TicketId:@(),    // 工单的id,必填
    KF5PerPage:@(),     // 每页工单的数量,默认30,选填
    KF5Page:@()         // 当前请求第几页,默认1,选填
 };
 */
+ (nullable NSURLSessionDataTask *)getTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 获取工单详情

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5TicketId:@()     // 工单的id,必填
 };
 */
+ (nullable NSURLSessionDataTask *)getTicketDetailMessageWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 回复工单

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5TicketId:@(),    // 工单的id,必填
    KF5Content:@"",     // 回复内容,必填
    KF5Uploads:@[]      // 附件token数组,选填
 };
 */
+ (nullable NSURLSessionDataTask *)updateTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^) ( NSDictionary *_Nullable result, NSError *_Nullable error))completion;
/**
 工单满意度评价
 
 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",   // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5TicketId:@(),    // 工单的id,必填
    KF5Rating:@(),      // 满意度,必填
    KF5Content:@""      // 满意度评价内容,选填
 };
 */
+ (nullable NSURLSessionDataTask *)ratingTicketWithParams:(nonnull NSDictionary *)params completion:(nullable void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion;
/**
 创建工单

 @param params 参数,如下:
 @{ // 注意:KF5UserToken为静态常量,下同
    KF5UserToken:@"",       // 用户唯一标示,可通过创建或登录用户获得,必填
    KF5Title:@"",           // 工单的标题,必填
    KF5Content:@"",         // 回复内容,必填
    KF5Uploads:@[],         // 附件token数组,选填
    KF5CustomFields:@""     // 自定义字段,如@[@{@"name":@"field_123",@"value":@"手机端"},@{@"name":@"field_321",@"value":@"IOS"}],需要将数组转成JSONString使用,选填
 };
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
