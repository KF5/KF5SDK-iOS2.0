//
//  KFSelectQuestionController.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/28.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "KFBaseViewController.h"
typedef void ((^SelectQuestionBlock)(NSArray<NSNumber *> * _Nullable agentIds, BOOL cancel));

@interface KFSelectQuestionController : KFBaseTableViewController

@property (nonatomic,strong, nullable) NSArray <NSDictionary *>* questions;

@property (nonatomic,copy, nullable) SelectQuestionBlock selectBlock;

+ (void)selectQuestionWithViewController:(UIViewController *_Nonnull)viewController questions:(nullable NSArray <NSDictionary *>*)questions selectBlock:(nullable SelectQuestionBlock)selectBlock;

@end
