//
//  KFComment.m
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFComment.h"
#import "KFHelper.h"
#import "KFUserManager.h"

@implementation KFComment

+ (NSArray *)commentWithDict:(NSDictionary *)dict{
    
    NSArray *commentsList = [dict kf5_arrayForKeyPath:@"data.comments"];
    NSMutableArray *comments = [NSMutableArray arrayWithCapacity:commentsList.count];
    for (NSDictionary *comDict in commentsList) {
        KFComment *comment = [[KFComment alloc]init];
        comment.comment_id = [comDict kf5_numberForKeyPath:@"id"].integerValue;
        comment.created = [comDict kf5_numberForKeyPath:@"created_at"].doubleValue;
        comment.author_name = [comDict kf5_stringForKeyPath:@"author_name"];
        comment.author_id = [comDict kf5_numberForKeyPath:@"author_id"].integerValue;
        comment.messageFrom = comment.author_id == [KFUserManager shareUserManager].user.user_id ? KFMessageFromMe : KFMessageFromOther;
        comment.content = [[comDict kf5_stringForKeyPath:@"content"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        comment.attachments = [KFAttachment attachmentsWithDict:[comDict kf5_arrayForKeyPath:@"attachments"]];
        comment.messageStatus = KFMessageStatusSuccess;
        [comments addObject:comment];
    }
    return comments;
}

@end
