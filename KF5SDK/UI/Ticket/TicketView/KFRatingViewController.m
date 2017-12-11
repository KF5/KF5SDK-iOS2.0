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
#import "KFUserManager.h"
#import "KFProgressHUD.h"

@interface KFRatingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSInteger ticket_id;

@property (nullable, nonatomic, strong) KFRatingModel *ratingModel;

@property (nullable, nonatomic, weak) UITableView *tableView;
@property (nullable, nonatomic, weak) KFTextView *textView;
@property (nullable, nonatomic, weak) UIButton *submitBtn;

@property (nonatomic,weak) NSLayoutConstraint *tableViewBottomLayout;

@end

@implementation KFRatingViewController

- (instancetype)initWithTicket_id:(NSInteger)ticket_id ratingModel:(KFRatingModel *)ratingModel{
    self = [super init];
    if (self) {
        _ratingModel = ratingModel;
        _ticket_id = ticket_id;
    }
    return self;
}

- (UIView *)headerView{
    // headerView
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    UILabel *label = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5TitleColor];
    label.text = KF5Localized(@"kf5_ratingText");
    [headerView addSubview:label];
    
    [label kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.equalTo(headerView);
        make.left.equalTo(headerView.kf5_safeAreaLayoutGuideLeft).offset(KF5Helper.KF5MiddleSpacing);
        make.right.equalTo(headerView.kf5_safeAreaLayoutGuideRight).offset(-KF5Helper.KF5MiddleSpacing);
        make.bottom.equalTo(headerView);
    }];
    
    return headerView;
}

- (UIView *)footerView{
    // footerView
    
    CGFloat textViewHeight = 200;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, textViewHeight + KF5Helper.KF5MiddleSpacing)];
    
    KFTextView *textView= [[KFTextView alloc] init];
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
    
    [textView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.equalTo(footerView);
        make.left.equalTo(footerView.kf5_safeAreaLayoutGuideLeft).offset(KF5Helper.KF5DefaultSpacing);
        make.right.equalTo(footerView.kf5_safeAreaLayoutGuideRight).offset(-KF5Helper.KF5DefaultSpacing);
        make.height.kf_equal(textViewHeight);
    }];
    
    return footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:KF5Localized(@"kf5_submit") style:UIBarButtonItemStyleDone target:self action:@selector(submitRating)];
    self.navigationItem.rightBarButtonItem.enabled = self.ratingModel.ratingScore != KFTicketRatingScoreNone;
    
    self.title = KF5Localized(@"kf5_rate");
    
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.rowHeight = 44;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = self.footerView;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self.tableView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        self.tableViewBottomLayout = make.bottom.equalTo(self.view).active;
    }];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ratingModel.rateLevelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"KFSatifiedID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger ratingScore = self.ratingModel.rateLevelArray[indexPath.row].integerValue;
    
    cell.accessoryType = self.ratingModel.ratingScore == ratingScore ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = [KFRatingModel stringForRatingScore:ratingScore];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.ratingModel.ratingScore = self.ratingModel.rateLevelArray[indexPath.row].integerValue;
    [tableView reloadData];
    // 选中满意度评分后,即可以提交满意度
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.textView resignFirstResponder];
}

#pragma mark 收到键盘弹出通知后的响应
- (void)keyboardWillShow:(NSNotification *)info {
    NSDictionary *dict = info.userInfo;
    //得到键盘的高度，即输入框需要移动的距离
    self.tableViewBottomLayout.constant = -([dict[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
    
    [UIView animateWithDuration:[dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 animations:^{
        [self.view layoutIfNeeded];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - MAX(self.tableView.tableFooterView.frame.size.height + CGRectGetMaxY(self.navigationController.navigationBar.frame) + KF5Helper.KF5MiddleSpacing, self.tableView.frame.size.height))];
    } completion:nil];
}

#pragma mark 隐藏键盘通知的响应
- (void)keyboardWillHide:(NSNotification *)info {
    NSDictionary *dict = info.userInfo;
    self.tableViewBottomLayout.constant = 0;
    [UIView animateWithDuration:[dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0 options:[dict[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 animations:^{
        [self.view layoutIfNeeded];
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
