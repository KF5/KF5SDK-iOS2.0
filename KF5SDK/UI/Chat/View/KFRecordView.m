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
        [self addSubview:amplitudeImageView];
        _amplitudeImageView = amplitudeImageView;
        
        UILabel *recordInfoLabel = [KFHelper labelWithFont:KF5Helper.KF5NameFont textColor:[UIColor whiteColor]];
        recordInfoLabel.text = KF5Localized(@"kf5_slide_to_cancel");
        recordInfoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:recordInfoLabel];
        _recordInfoLabel = recordInfoLabel;
        
        [amplitudeImageView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.top.kf_equalTo(self).kf_offset(KF5Helper.KF5VerticalSpacing);
            make.width.kf_equal(amplitudeImageView.image.size.width);
            make.height.kf_equal(amplitudeImageView.image.size.height);
            make.centerX.kf_equalTo(self.kf5_centerX);
        }];
        [recordInfoLabel kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
            make.bottom.kf_equalTo(self).kf_offset(-KF5Helper.KF5VerticalSpacing);
            make.width.kf_equalTo(self);
            make.centerX.kf_equalTo(self.kf5_centerX);
        }];
        
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
