//
//  KFCommentModel.h
//  Pods
//
//  Created by admin on 16/11/4.
//
//

#import <UIKit/UIKit.h>
#import "KFComment.h"
#import "YYTextLayout.h"

@interface KFCommentModel : NSObject

@property (nonnull, nonatomic, strong) KFComment *comment;

/**内容*/
@property (nullable, nonatomic, strong) YYTextLayout *textLayout;
/**附件数组*/
@property (nullable, nonatomic, strong) NSArray <KFAttachment *>*attachments;
/**时间*/
@property (nullable, nonatomic, copy) NSString *timeText;
/**头像*/
@property (nullable, nonatomic, strong) UIImage *headerImage;
/**昵称*/
@property (nullable, nonatomic, copy) NSString *name;


/**内容的frame*/
@property (nonatomic, assign) CGRect textFrame;
/**附件视图的frame*/
@property (nonatomic, assign) CGRect attViewFrame;
/**时间的frame*/
@property (nonatomic, assign) CGRect timeFrame;
/**头像的frame*/
@property (nonatomic, assign) CGRect headerFrame;
/**昵称的frame*/
@property (nonatomic, assign) CGRect nameFrame;
/**loadView的frame */
@property (nonatomic, assign) CGRect loadViewFrame;

/**cell高度*/
@property (nonatomic, assign) CGFloat cellHeight;

/**
 初始化commentModel
 */
- (nonnull instancetype)initWithComment:(nonnull KFComment *)comment;

/**重置frame*/
- (void)updateFrame;

@end
