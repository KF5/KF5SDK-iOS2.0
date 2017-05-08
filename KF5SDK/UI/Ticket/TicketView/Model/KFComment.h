//
//  KFComment.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import <Foundation/Foundation.h>
#import "KFHelper.h"
#import "KFAttachment.h"

@interface KFComment : NSObject

/**消息发送人的id*/
@property (nonatomic, assign) NSInteger author_id;
/**消息内容*/
@property (nonatomic, copy) NSString *content;
/**创建时间*/
@property (nonatomic, assign) double created;
/**消息id*/
@property (nonatomic, assign) NSInteger comment_id;
/**附件 */
@property (nonatomic, strong) NSArray <KFAttachment *>*attachments;
/**发送人的名称*/
@property (nonatomic, copy) NSString *author_name;
/**消息来自于*/
@property (nonatomic, assign) KFMessageFrom messageFrom;

/**发送状态*/
@property (nonatomic, assign) KFMessageStatus messageStatus;

+ (NSArray *)commentWithDict:(NSDictionary *)dict;

@end
