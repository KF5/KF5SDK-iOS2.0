//
//  KFRecordView.m
//  KF5ChatSDK
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 kf5. All rights reserved.
//

#import "KFRecordView.h"
#import "KFHelper.h"

@interface KFRecordView()

@property (nonatomic, weak) UIImageView *amplitudeImageView;
@property (nonatomic, weak) UILabel *recordInfoLabel;

@end

@implementation KFRecordView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 10;

        UIImageView *amplitudeImageView = [[UIImageView alloc]initWithImage:KF5Helper.chat_records.firstObject];
        amplitudeImageView.frame = CGRectMake(0, KF5Helper.KF5VerticalSpacing, amplitudeImageView.image.size.width, amplitudeImageView.image.size.height);
        amplitudeImageView.kf5_centerX = self.kf5_centerX;
        [self addSubview:amplitudeImageView];
        self.amplitudeImageView = amplitudeImageView;
        
        UILabel *recordInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, KF5Helper.KF5NameFont.lineHeight)];
        recordInfoLabel.kf5_centerX = self.kf5_centerX;
        recordInfoLabel.kf5_bottom = self.kf5_bottom - KF5Helper.KF5VerticalSpacing;
        recordInfoLabel.text = KF5Localized(@"kf5_slide_to_cancel");
        recordInfoLabel.textAlignment = NSTextAlignmentCenter;
        recordInfoLabel.textColor = [UIColor whiteColor];
        recordInfoLabel.font = KF5Helper.KF5NameFont;
        [self addSubview:recordInfoLabel];
        self.recordInfoLabel = recordInfoLabel;
    }
    return self;
}

/**
 *   改变recordInfoLabel的text
 */
- (void)setDragSide:(kKF5DragSide)dragSide{
    _dragSide = dragSide;
    
    _recordInfoLabel.text = _dragSide == kKF5DragSideIn ? KF5Localized(@"kf5_slide_to_cancel") : KF5Localized(@"kf5_leave_to_cancel");
}

- (void)setAmplitude:(CGFloat)amplitude{
    _amplitude = amplitude * 10 > 1 ? 1 : amplitude * 10;
    
    NSInteger recordIndex =  (NSInteger)((_amplitude * 14) + 1) ;
    recordIndex = recordIndex > 14 ? 14 :recordIndex;
    
    if (recordIndex < KF5Helper.chat_records.count)
        _amplitudeImageView.image = KF5Helper.chat_records[recordIndex];
    
    [self setNeedsDisplay];
}

@end
