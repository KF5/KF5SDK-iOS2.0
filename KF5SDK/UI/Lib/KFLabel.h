//
//  KFLabel.h
//  Pods
//
//  Created by admin on 16/4/26.
//
//

#import "YYLabel.h"

@protocol KFLabelDelegate <NSObject>
//聊天和工单都使用
- (void)clickLabelWithInfo:(nullable NSDictionary *)info;

@end

@interface KFLabel : YYLabel

@property (nullable, nonatomic, weak) id<KFLabelDelegate> labelDelegate;

@property (nullable, nonatomic, strong) UIColor *urlColor;

@end
