//
//  KFCreateTicketViewController.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import "KFBaseViewController.h"
#import "KFCreateTicketView.h"

@interface KFCreateTicketViewController : KFBaseViewController

///提交工单时添加的自定义工单字段数组
@property (nullable, nonatomic, strong) NSArray *custom_fields;
///创建工单视图
@property (nullable, nonatomic, weak) KFCreateTicketView *createView;
///当视图出现时,是否直接显示键盘,默认为NO
@property (nonatomic, assign) BOOL isShowKeyBoardWhenViewAppear;

@end
