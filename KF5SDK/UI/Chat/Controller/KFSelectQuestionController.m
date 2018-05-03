//
//  KFSelectQuestionController.m
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/28.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "KFSelectQuestionController.h"
#import "KFHelper.h"

static NSString *cellID = @"selectQuestionCell";

@implementation KFSelectQuestionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = KF5Localized(@"kf5_select_question");

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 64;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:KF5Localized(@"kf5_cancel") style:UIBarButtonItemStyleDone target:self action:@selector(dismissView)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    headerView.backgroundColor = KF5Helper.KF5BgColor;
    UILabel *label = [KFHelper labelWithFont:KF5Helper.KF5TitleFont textColor:KF5Helper.KF5TitleColor];
    label.text = KF5Localized(@"kf5_select_question_description");
    [headerView addSubview:label];
    [label kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(headerView);
        make.left.kf_equalTo(headerView.kf5_safeAreaLayoutGuideLeft).kf_offset(KF5Helper.KF5MiddleSpacing);
        make.right.kf_equalTo(headerView.kf5_safeAreaLayoutGuideRight);
        make.bottom.kf_equalTo(headerView);
    }];
    self.tableView.tableHeaderView = headerView;
}

+ (void)selectQuestionWithViewController:(UIViewController *)viewController questions:(NSArray<NSDictionary *> *)questions selectBlock:(SelectQuestionBlock)selectBlock{
    dispatch_async(dispatch_get_main_queue(), ^{
        KFSelectQuestionController *selectQuestionController = [[KFSelectQuestionController alloc] init];
        selectQuestionController.questions = questions;
        selectQuestionController.selectBlock = selectBlock;
        [viewController presentViewController:[[UINavigationController alloc]initWithRootViewController:selectQuestionController] animated:YES completion:nil];
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *question = self.questions[indexPath.row];
    cell.textLabel.text = [question kf5_stringForKeyPath:@"title"];
    cell.detailTextLabel.text = [question kf5_stringForKeyPath:@"description"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock) self.selectBlock([self.questions[indexPath.row] kf5_arrayForKeyPath:@"agent_ids"], NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissView{
    if (self.selectBlock) self.selectBlock(nil, YES);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
