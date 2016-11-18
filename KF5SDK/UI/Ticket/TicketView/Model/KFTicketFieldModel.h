//
//  KFTicketFieldModel.h
//  Pods
//
//  Created by admin on 16/11/10.
//
//

#import <UIKit/UIKit.h>

@interface KFTicketFieldModel : NSObject

@property (nonnull, nonatomic, strong) NSDictionary *ticketFieldDict;

@property (nonnull, nonatomic, copy) NSString *title;
@property (nonnull, nonatomic, copy) NSString *content;

@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) CGRect contentFrame;

@property (nonatomic, assign) CGFloat cellHeight;

- (nonnull instancetype)initWithTicketFieldDict:(nonnull NSDictionary *)ticketFieldDict;

- (void)updateFrame;

@end
