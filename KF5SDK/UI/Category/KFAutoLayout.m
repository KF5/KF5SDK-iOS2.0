//
//  KFAutoLayout.m
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/16.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "KFAutoLayout.h"
#import <objc/runtime.h>

@implementation KFViewAttribute

- (id)initWithItem:(id)item layoutAttribute:(NSLayoutAttribute)layoutAttribute{
    self = [super init];
    if (!self) return nil;
    
    _item = item;
    _layoutAttribute = layoutAttribute;
    
    return self;
}

@end

@interface KFAutoLayoutMaker()

@property (nullable, nonatomic,weak) id firstItem;
@property (nonatomic, assign) NSLayoutAttribute firstAttribute;
@property (nullable, nonatomic,weak) id secondItem;
@property (nonatomic, assign) NSLayoutAttribute secondAttribute;
@property (nonatomic, assign) NSLayoutRelation relation;
@property (nonatomic, assign) CGFloat multiplierValue;
@property (nonatomic, assign) CGFloat constant;
@property (nonatomic, assign) UILayoutPriority priorityValue;

@property (nonatomic,strong) NSLayoutConstraint *layoutConstraint;


@end

@implementation KFAutoLayoutMaker

- (instancetype)initWithFirstItem:(id)firstItem firstAttribute:(NSLayoutAttribute)firstAttribute{
    self = [super init];
    if (!self) return nil;
    
    _firstItem = firstItem;
    _firstAttribute = firstAttribute;
    _secondItem = nil;
    _secondAttribute = NSLayoutAttributeNotAnAttribute;
    _multiplierValue = 1.0;
    _constant = 0;
    _priorityValue = UILayoutPriorityRequired;
    
    return self;
}

- (KFAutoLayoutMaker *(^)(CGFloat))offset{
    return ^id(CGFloat offset){
        self.constant = offset;
        return self;
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(id _Nonnull))equalTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}
- (KFAutoLayoutMaker * _Nonnull (^)(id _Nonnull))greaterThanOrEqualTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(id _Nonnull))lessThanOrEqualTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(CGFloat))kf_equal{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationEqual);
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(CGFloat))kf_greaterThanOrEqual{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationGreaterThanOrEqual);
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(CGFloat))kf_lessThanOrEqual{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationLessThanOrEqual);
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(UILayoutPriority))priority{
    return ^(UILayoutPriority priority) {
        self.priorityValue = priority;
        return self;
    };
}

- (KFAutoLayoutMaker * _Nonnull (^)(CGFloat))multiplier{
    return ^(CGFloat multiplier) {
        self.multiplierValue = multiplier;
        return self;
    };
}

- (BOOL)isActive{
    return self.layoutConstraint != nil;
}

- (NSLayoutConstraint *)active{
    if (self.layoutConstraint) self.layoutConstraint.active = NO;
    if (self.firstItem) {
        self.layoutConstraint = [NSLayoutConstraint constraintWithItem:self.firstItem attribute:self.firstAttribute relatedBy:self.relation toItem:self.secondItem attribute:self.secondAttribute multiplier:self.multiplierValue constant:self.constant];
        self.layoutConstraint.priority = self.priorityValue;
        self.layoutConstraint.active = YES;
    }
    return self.layoutConstraint;
}

- (void)deactivate{
    [self.layoutConstraint setActive:NO];
    self.layoutConstraint = nil;
}

#pragma mark private
- (KFAutoLayoutMaker * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attribute, NSLayoutRelation relation) {
        self.relation = relation;
        if ([attribute isKindOfClass:[UIView class]]) {
            self.secondItem = attribute;
            self.secondAttribute = self.firstAttribute;
        }else if ([attribute isKindOfClass:[KFViewAttribute class]]){
            self.secondItem = ((KFViewAttribute *)attribute).item;
            self.secondAttribute = ((KFViewAttribute *)attribute).layoutAttribute;
        }else if ([attribute isKindOfClass:[NSNumber class]]){
            self.secondItem = nil;
            self.secondAttribute = NSLayoutAttributeNotAnAttribute;
            self.constant = ((NSNumber *)attribute).floatValue;
        }else{
            NSAssert(attribute, @"格式不正确,必须是UIView或KFAutoLayoutMaker或NSNumber");
        }
        self.relation = relation;
        return self;
    };
}

@end

@interface KFAutoLayout()

@property (nonatomic,strong) NSMutableArray<KFAutoLayoutMaker *> *constraints;
@property (nonatomic,weak) id view;

@end

@implementation KFAutoLayout

- (id)initWithView:(UIView *)view{
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    self.constraints = [NSMutableArray array];
    return self;
}

#pragma mark - standard Attributes
- (KFAutoLayoutMaker *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (KFAutoLayoutMaker *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (KFAutoLayoutMaker *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (KFAutoLayoutMaker *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (KFAutoLayoutMaker *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (KFAutoLayoutMaker *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (KFAutoLayoutMaker *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (KFAutoLayoutMaker *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (KFAutoLayoutMaker *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (KFAutoLayoutMaker *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (KFAutoLayoutMaker *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (KFAutoLayoutMaker *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    KFAutoLayoutMaker *maker = [[KFAutoLayoutMaker alloc] initWithFirstItem:self.view firstAttribute:layoutAttribute];
    [self.constraints addObject:maker];
    return maker;
}

- (void)active{
    for (KFAutoLayoutMaker *maker in self.constraints) {
        if (!maker.isActive) {
            [maker active];
        }
    }
}

- (void)deactivate{
    [self.constraints makeObjectsPerformSelector:@selector(deactivate)];
    [self.constraints removeAllObjects];
}

@end



@implementation UIView (KF5AutoLayout)

static char kInstalledKF5AutoLayoutKey;

- (KFAutoLayout *)kf5_layout {
    KFAutoLayout *autolayout = objc_getAssociatedObject(self, &kInstalledKF5AutoLayoutKey);
    if (!autolayout) {
        autolayout = [[KFAutoLayout alloc] initWithView:self];
        objc_setAssociatedObject(self, &kInstalledKF5AutoLayoutKey, autolayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return autolayout;
}

- (void)kf5_makeConstraints:(void (^)(KFAutoLayout *))make{
    make(self.kf5_layout);
    [self.kf5_layout active];
}

- (void)kf5_remakeConstraints:(void (^)(KFAutoLayout * _Nonnull))make{
    [self.kf5_layout deactivate];
    [self kf5_makeConstraints:make];
}

- (KFViewAttribute *)kf5_left{
    return [self viewAttribute:NSLayoutAttributeLeft];
}

- (KFViewAttribute *)kf5_top{
    return [self viewAttribute:NSLayoutAttributeTop];
}

- (KFViewAttribute *)kf5_right{
    return [self viewAttribute:NSLayoutAttributeRight];
}

- (KFViewAttribute *)kf5_bottom{
    return [self viewAttribute:NSLayoutAttributeBottom];
}

- (KFViewAttribute *)kf5_leading{
    return [self viewAttribute:NSLayoutAttributeLeading];
}

- (KFViewAttribute *)kf5_trailing{
    return [self viewAttribute:NSLayoutAttributeTrailing];
}

- (KFViewAttribute *)kf5_width{
    return [self viewAttribute:NSLayoutAttributeWidth];
}

- (KFViewAttribute *)kf5_height{
    return [self viewAttribute:NSLayoutAttributeHeight];
}

- (KFViewAttribute *)kf5_centerX{
    return [self viewAttribute:NSLayoutAttributeCenterX];
}

- (KFViewAttribute *)kf5_centerY{
    return [self viewAttribute:NSLayoutAttributeCenterY];
}

- (KFViewAttribute *)kf5_baseline{
    return [self viewAttribute:NSLayoutAttributeBaseline];
}

#pragma mark - iOS11 safeArea
- (KFViewAttribute *)kf5_safeAreaLayoutGuideTop{
    return [self safeAreaViewAttribute:NSLayoutAttributeTop];
}

- (KFViewAttribute *)kf5_safeAreaLayoutGuideBottom{
    return [self safeAreaViewAttribute:NSLayoutAttributeBottom];
}

- (KFViewAttribute *)kf5_safeAreaLayoutGuideLeft{
    return [self safeAreaViewAttribute:NSLayoutAttributeLeft];
}

- (KFViewAttribute *)kf5_safeAreaLayoutGuideRight{
    return [self safeAreaViewAttribute:NSLayoutAttributeRight];
}

- (UIEdgeInsets)kf5_safeAreaInsets{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }
#endif
    return safeInsets;
}

#pragma mark - private
- (KFViewAttribute *)viewAttribute:(NSLayoutAttribute)layoutAttribute {
    return [[KFViewAttribute alloc] initWithItem:self layoutAttribute:layoutAttribute];
}

- (KFViewAttribute *)safeAreaViewAttribute:(NSLayoutAttribute)layoutAttribute {
    id item = self;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        item = self.safeAreaLayoutGuide;
    }
#endif
    return [[KFViewAttribute alloc] initWithItem:item layoutAttribute:layoutAttribute];
}

@end

@implementation UIViewController (KF5AutoLayout)

- (KFViewAttribute *)kf5_topLayoutGuide{
    return [self kf5_topLayoutGuideBottom];
}

- (KFViewAttribute *)kf5_bottomLayoutGuide{
    return [self kf5_bottomLayoutGuideTop];
}

- (KFViewAttribute *)kf5_topLayoutGuideTop{
    return [[KFViewAttribute alloc] initWithItem:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}

- (KFViewAttribute *)kf5_topLayoutGuideBottom{
    return [[KFViewAttribute alloc] initWithItem:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (KFViewAttribute *)kf5_bottomLayoutGuideTop{
    return [[KFViewAttribute alloc] initWithItem:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}

- (KFViewAttribute *)kf5_bottomLayoutGuideBottom{
    return [[KFViewAttribute alloc] initWithItem:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (KFViewAttribute *)kf5_safeAreaTopLayoutGuide{
    id item = self.topLayoutGuide;
    NSLayoutAttribute attribute = NSLayoutAttributeBottom;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        item = self.view.safeAreaLayoutGuide;
        attribute = NSLayoutAttributeTop;
    }
#endif
    return [[KFViewAttribute alloc] initWithItem:item layoutAttribute:attribute];
}

- (KFViewAttribute *)kf5_safeAreaBottomLayoutGuide{
    id item = self.bottomLayoutGuide;
    NSLayoutAttribute attribute = NSLayoutAttributeTop;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        item = self.view.safeAreaLayoutGuide;
        attribute = NSLayoutAttributeBottom;
    }
#endif
    return [[KFViewAttribute alloc] initWithItem:item layoutAttribute:attribute];
}

@end
