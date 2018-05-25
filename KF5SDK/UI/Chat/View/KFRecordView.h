//
//  KFRecordView.h
//  KF5ChatSDK
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kKF5DragSideNone = 0,
    kKF5DragSideOut,
    kKF5DragSideIn
}kKF5DragSide;

@interface KFRecordView : UIView
/**
 修改recordInfoLabel的text
 */
@property (nonatomic, assign) kKF5DragSide dragSide;
/**
 应小于1
 */
@property (nonatomic, assign) CGFloat amplitude;
@end
