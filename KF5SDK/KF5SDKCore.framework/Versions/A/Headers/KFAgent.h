//
//  KFAgent.h
//  Pods
//
//  Created by admin on 16/10/19.
//
//

#import <Foundation/Foundation.h>
#import "KFDispatcher.h"

@interface KFAgent : NSObject
/**
 客服的id
 */
@property (nonatomic, assign) NSInteger Id;
/**
 客服的昵称
 */
@property (nullable, nonatomic, copy) NSString *displayName;
/**
 客服的头像
 */
@property (nullable, nonatomic, copy) NSString *photoUrl;
/**
 客服角色(人工客服/机器人客服)
 */
@property (nonatomic, assign) KFAgentRole agentRole;

@end
