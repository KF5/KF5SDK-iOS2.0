//
//  KFFaceBoardView.h
//  Pods
//
//  Created by admin on 16/10/21.
//
//

#import <UIKit/UIKit.h>

@interface KFFaceBoardView : UIView

@property (nullable, nonatomic, copy) void (^clickBlock)(NSString * _Nonnull text);
@property (nullable, nonatomic, copy) void (^sendBlock)();
@property (nullable, nonatomic, copy) void (^deleteBlock)();

@end
