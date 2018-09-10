//
//  KFCreateTicketView.h
//  Pods
//
//  Created by admin on 16/11/3.
//
//

#import <UIKit/UIKit.h>
#import "KFSudokuView.h"
#import "KFTextView.h"

@interface KFCreateTicketView : UIView

/// 输入框
@property (nonatomic, strong) KFTextView *textView;
/// 添加附件按钮
@property (nonatomic, weak) UIButton *attBtn;
/// 图片视图
@property (nonatomic,weak) KFSudokuView *photoImageView;

@property (nonatomic,copy) void(^clickAttBtn)(void);

@end
