//
//  KFTicket.h
//  Pods
//
//  Created by admin on 16/10/18.
//
//

#import <Foundation/Foundation.h>

/**
 工单状态
 */
typedef NS_ENUM(NSInteger,KFTicketStatus) {
    KFTicketStatusNew = 0,      // 尚未受理
    KFTicketStatusOpen,         // 受理中
    KFTicketStatusPending,      // 等待回复
    KFTicketStatusSolved,       // 已解决
    KFTicketStatusClosed        // 已关闭
};

@interface KFTicket : NSObject

///工单的id
@property (nonatomic, assign) NSInteger ticket_id;
///标题
@property (nullable, nonatomic, copy) NSString *title;
///状态
@property (nonatomic, assign) KFTicketStatus status;
///描述
@property (nullable, nonatomic, copy) NSString *ticket_description;
///创建时间
@property (nonatomic, assign) double created_at;
///更新时间
@property (nonatomic, assign) double updated_at;
///关闭时间
@property (nonatomic, assign) double due_date;
///最后一条回复的id
@property (nonatomic, assign) NSInteger lastComment_id;

@property (nullable, nonatomic, copy, readonly) NSString *statusString;

+ (nonnull instancetype)ticketWithDict:(nonnull NSDictionary *)dict;

+ (nonnull NSArray <KFTicket *>*)ticketsWithDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

@end
