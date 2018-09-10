//
//  KFCreateTicketViewController.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFBaseViewController.h"

@interface KFCreateTicketViewController : KFBaseViewController
/**
 当视图出现时,是否直接显示键盘,默认为NO
 */
@property (nonatomic, assign) BOOL isShowKeyBoardWhenViewAppear;
/**
 设置工单自定义字段数组

 @param customFields 格式如:@[@{@"name":@"field_123",@"value":@"手机端"},@{@"name":@"field_321",@"value":@"IOS"}]
 @warning 每次提交工单时,都会将自定义字段添加到工单中
 */
+ (void)setCustomFields:(nullable NSArray *)customFields;

@end
