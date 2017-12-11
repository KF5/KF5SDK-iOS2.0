//
//  KFFaceBoardView.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/24.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFFaceBoardView : UIInputView

@property (nullable, nonatomic, copy) void (^clickBlock)(NSString * _Nonnull title);
@property (nullable, nonatomic, copy) void (^sendBlock)(void);
@property (nullable, nonatomic, copy) void (^deleteBlock)(void);

@end

@interface KFFacePageControl : UIPageControl
@end
