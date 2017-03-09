//
//  KFLabel.m
//  Pods
//
//  Created by admin on 16/4/26.
//
//

#import "KFLabel.h"

#import "KFContentLabelHelp.h"
#import "KFHelper.h"
#import "YYText.h"

@interface KFLabel()

@property (nonatomic, weak) NSString *url;

@end

@implementation KFLabel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.urlColor = KF5Helper.KF5OtherURLColor;
        self.ignoreCommonProperties = YES;
        self.displaysAsynchronously = YES;
        __weak typeof(self)weakSelf = self;
        self.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if (range.location >= text.length) return;
            YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
            NSDictionary *info = highlight.userInfo;
            if (info.count == 0) return;
            
            if ([weakSelf.labelDelegate respondsToSelector:@selector(clickLabelWithInfo:)]) {
                [weakSelf.labelDelegate clickLabelWithInfo:info];
            }
        };
    }
    return self;
}


@end
