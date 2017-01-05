//
//  KFRatingViewController.m
//  Pods
//
//  Created by admin on 16/12/30.
//
//

#import "KFRatingViewController.h"
#import "KFHelper.h"
#import "KFTextView.h"
#import <KF5SDK/KFHttpTool.h>
#import "KFUserManager.h"
#import "KFProgressHUD.h"

@interface KFRatingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSInteger ticket_id;

@property (nullable, nonatomic, strong) KFRatingModel *ratingModel;

@property (nullable, nonatomic, weak) UITableView *tableView;
@property (nullable, nonatomic, weak) KFTextView *textView;
@property (nullable, nonatomic, weak) UIButton *submitBtn;

@end

@implementation KFRatingViewController

- (instancetype)initWithTicket_id:(NSInteger)ticket_id ratingModel:(KFRatingModel *)ratingModel
{
    self = [super init];
    if (self) {
        _ratingModel = ratingModel;
        _ticket_id = ticket_id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:KF5Localized(@"kf5_submit") style:UIBarButtonItemStyleDone target:self action:@selector(submitRating)];
    self.navigationItem.rightBarButtonItem.enabled = self.ratingModel.ratingScore != KFRatingScoreNone;
    
    self.title = KF5Localized(@"kf5_rate");
    
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    tableView.rowHeight = 44;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // headerView
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(KF5Helper.KF5MiddleSpacing, 0, headerView.frame.size.width - KF5Helper.KF5MiddleSpacing, 44)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = KF5Helper.KF5TitleFont;
    label.textColor = KF5Helper.KF5TitleColor;
    label.text = KF5Localized(@"kf5_ratingText");
    [headerView addSubview:label];
    tableView.tableHeaderView = headerView;
    
    // footerView
    
    CGFloat textViewHeight = 200;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, textViewHeight + KF5Helper.KF5MiddleSpacing)];
    
    KFTextView *textView= [[KFTextView alloc] initWithFrame:CGRectMake(KF5Helper.KF5DefaultSpacing, 0, footerView.frame.size.width - KF5Helper.KF5DefaultSpacing * 2, textViewHeight)];
    textView.text = _ratingModel.ratingContent;
    textView.textColor = KF5Helper.KF5TitleColor;
    textView.font = KF5Helper.KF5TitleFont;
    textView.placeholderText = KF5Localized(@"kf5_rating_placeholderText");
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.layer.borderWidth = 1;
    textView.layer.cornerRadius = 3;
    textView.layer.borderColor = KF5Helper.KF5BgColor.CGColor;
    [footerView addSubview:textView];
    self.textView = textView;
    
    tableView.tableFooterView = footerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)submitRating{
    
    self.ratingModel.ratingContent = self.textView.text;
    
    NSDictionary *params = @{
                             KF5UserToken:[KFUserManager shareUserManager].user.userToken,
                             KF5TicketId:@(self.ticket_id),
                             KF5Rating:@(self.ratingModel.ratingScore),
                             KF5Content:self.ratingModel.ratingContent?:@""
                           };
    
    [KFProgressHUD showDefaultLoadingTo:self.view];
    __weak typeof(self)weakSelf = self;
    [KFHttpTool ratingTicketWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [KFProgressHUD showErrorTitleToView:weakSelf.view title:error.domain hideAfter:0.7f];
            }else{
                [KFProgressHUD hideHUDForView:weakSelf.view];
                if (weakSelf.completionBlock) weakSelf.completionBlock(weakSelf.ratingModel);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}

- (void)updateFrame{
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"KFSatifiedID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger ratingScore = indexPath.row + 1;
    
    cell.accessoryType = self.ratingModel.ratingScore == ratingScore ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = [KFRatingModel stringForRatingScore:ratingScore];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.ratingModel.ratingScore = indexPath.row + 1;
    [tableView reloadData];
    // 选中满意度评分后,即可以提交满意度
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.textView resignFirstResponder];
}

#pragma mark 收到键盘弹出通知后的响应
- (void)keyboardWillShow:(NSNotification *)info {
    //保存info
    NSDictionary *dict = info.userInfo;
    //得到键盘的显示完成后的frame
    CGRect keyboardBounds = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //得到键盘弹出动画的时间
    CGFloat duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //坐标系转换
    CGRect keyboardBoundsRect = [self.view convertRect:keyboardBounds toView:nil];
    
    UIViewAnimationOptions options = [dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    //添加动画
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardBoundsRect.size.height);
        CGFloat offsetY = self.tableView.contentSize.height - MAX(self.tableView.tableFooterView.frame.size.height + CGRectGetMaxY(self.navigationController.navigationBar.frame) + KF5Helper.KF5MiddleSpacing, self.tableView.frame.size.height);
        [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        
    } completion:nil];
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
    //输入框回去的时候就不需要高度了，直接取动画时间和曲线还原回去
    NSDictionary *dict = info.userInfo;
    double duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self updateFrame];
    } completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
