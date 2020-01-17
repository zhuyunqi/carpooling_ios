//
//  CPActivityDetailVC.m
//  Carpooling
//
//  Created by bw on 2019/5/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPActivityDetailVC.h"
#import "CPActivityDetailCell1.h"
#import "CPActivityReqResultModel.h"
#import "CPActivityReqResultSubModel.h"
#import "CPActivityMJModel.h"

#import "CPActivityMembersVC.h"


@interface CPActivityDetailVC ()<CPActivityDetailCell1Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, assign) NSInteger canEnroll; // 是否可以报名
@property (nonatomic, assign) BOOL forceEnroll; // 是否强制报名

@property (nonatomic, assign) CGFloat cellHeight;
@end

@implementation CPActivityDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(243, 244, 246, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        
        self.tableView.backgroundColor = dyColor;
        
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(243, 244, 246, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        self.tableView.separatorColor = dyColor2;
        
        UIColor *dyColor3 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        self.view.backgroundColor = dyColor3;
        _bottomView.backgroundColor = dyColor3;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    self.title = kLocalizedTableString(@"Activity Detail", @"CPLocalizable");
    
    if (kBOTTOMSAFEHEIGHT == 0) {
        _bottomConstraint.constant = 0;
    }
    else {
        _bottomConstraint.constant = kBOTTOMSAFEHEIGHT;
    }
    
    _confirmBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _confirmBtn.layer.cornerRadius = _confirmBtn.frame.size.height/2;
    _confirmBtn.layer.masksToBounds = YES;
    [_confirmBtn setTitle:kLocalizedTableString(@"Enroll", @"CPLocalizable") forState:UIControlStateNormal];
    
    self.forceEnroll = 0;
    
    // 已报名则隐藏报名按钮
    if (_activityModel.isEnrollCurUser == 1) {
        _confirmBtn.hidden = YES;
    }
    
    [SVProgressHUD show];
    [self requestActivityDetail];
}

- (void)setActivityModel:(CPActivityMJModel *)activityModel{
    _activityModel = activityModel;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_activityModel) {
        return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kBOTTOMSAFEHEIGHT-60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPActivityDetailCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPActivityDetailCell1"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.activityModel = self.activityModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)activityDetailCell1CheckMember:(id)sender{
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPActivityMembersVC *activityMembersVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivityMembersVC"];
        activityMembersVC.activityId = self.activityModel.dataid;
        [self.navigationController pushViewController:activityMembersVC animated:YES];
    }
    else {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
    }
}

- (IBAction)confirmAction:(id)sender {
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        [self requestIfCanEnroll];
    }
    else {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
    }
}


#pragma mark - requestIfCanEnroll
- (void)requestIfCanEnroll{
    NSMutableDictionary *param = @{
                                   @"activityId":[NSNumber numberWithUnsignedInteger:self.activityModel.dataid]
                                   }.mutableCopy;
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/activity/v1/canEnroll", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPActivityDetailVC requestIfCanEnroll responseObject:%@", responseObject);
        if (responseObject) {
            NSUInteger state = [[responseObject valueForKey:@"code"] integerValue];
            
            if (state == 200) {
                //
                NSDictionary *dict = [responseObject valueForKey:@"data"];
                weakSelf.canEnroll = [[dict valueForKey:@"enrollState"] integerValue];
                
                if (weakSelf.canEnroll == 0) {// can enroll
                    [weakSelf.confirmBtn setTitle:kLocalizedTableString(@"Enroll", @"CPLocalizable") forState:UIControlStateNormal];
                    weakSelf.confirmBtn.hidden = NO;
                    weakSelf.confirmBtn.enabled = YES;
                    weakSelf.confirmBtn.backgroundColor = RGBA(120, 202, 195, 1);
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"you want enrolled", @"CPLocalizable") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [weakSelf requestEnrollActivity];
                        
                    }];
                    
                    [alert addAction:okAction];
                    [alert addAction:cancelAction];
                    
                    [weakSelf.navigationController presentViewController:alert animated:YES completion:nil];
                    
                    
                }
                else if (weakSelf.canEnroll == 1) {// already enroll
                    [weakSelf.confirmBtn setTitle:kLocalizedTableString(@"Already enrolled tip", @"CPLocalizable") forState:UIControlStateNormal];
                    weakSelf.confirmBtn.hidden = NO;
                    weakSelf.confirmBtn.enabled = NO;
                    weakSelf.confirmBtn.backgroundColor = RGBA(220, 220, 220, 1);
                }
                else if (weakSelf.canEnroll == 2) {// enroll conflict
                    //
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:kLocalizedTableString(@"Confirm", @"CPLocalizable") preferredStyle:UIAlertControllerStyleAlert];
                    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor darkGrayColor];
            }
            else {
                return [UIColor colorWithRed:133./256. green:205./256. blue:243./256. alpha:1.0];
            }
        }];
        
        alertController.view.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        alertController.view.tintColor = [UIColor darkGrayColor];
    }
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        weakSelf.forceEnroll = YES;
                        
                        [weakSelf requestEnrollActivity];
                        
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
                    
                    [alertController addAction:okAction];
                    [alertController addAction:cancelAction];
                    
                    [weakSelf presentViewController:alertController animated:YES completion:^{
                        
                    }];
                }
                
                
            }
            else{
                NSLog(@"CPActivityDetailVC requestIfCanEnroll 失败");
            }
        }
        else {
            NSLog(@"CPActivityDetailVC requestIfCanEnroll 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPActivityDetailVC requestActivityDetail error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


#pragma mark - 获取活动详情，获取人员总数和3个报名者的头像
- (void)requestActivityDetail{
    NSMutableDictionary *param = @{
                                   @"activityId":[NSNumber numberWithUnsignedInteger:self.activityModel.dataid]
                                   }.mutableCopy;
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/activity/v1/activityDetail", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPActivityDetailVC requestActivityDetail responseObject:%@", responseObject);
        if (responseObject) {
            NSUInteger state = [[responseObject valueForKey:@"code"] integerValue];
            CPActivityMJModel *activityModel = [CPActivityMJModel mj_objectWithKeyValues:[responseObject valueForKey:@"data"]];
            weakSelf.activityModel = activityModel;
            
            if (state == 200) {
                //
                if (activityModel.isEnrollCurUser) {
                    [weakSelf.confirmBtn setTitle:kLocalizedTableString(@"Already enrolled tip", @"CPLocalizable") forState:UIControlStateNormal];
                    weakSelf.confirmBtn.hidden = NO;
                    weakSelf.confirmBtn.enabled = NO;
                    weakSelf.confirmBtn.backgroundColor = RGBA(220, 220, 220, 1);
                }
                
                [self.tableView reloadData];
            }
            else{
                NSLog(@"CPActivityDetailVC requestActivityDetail 失败");
            }
        }
        else {
            NSLog(@"CPActivityDetailVC requestActivityDetail 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPActivityDetailVC requestActivityDetail error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

#pragma mark - 报名活动
- (void)requestEnrollActivity{
    
    NSMutableDictionary *param = @{
                                   @"activityId":[NSNumber numberWithUnsignedInteger:self.activityModel.dataid],
                                   @"forceEnroll":[NSNumber numberWithBool:self.forceEnroll],
                                   }.mutableCopy;
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/activity/v1/enrollActivity", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPActivityDetailVC requestEnrollActivity responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                CPActivityMJModel *activityModel = [CPActivityMJModel mj_objectWithKeyValues:[responseObject valueForKey:@"data"]];
                activityModel.addressVo = weakSelf.activityModel.addressVo;
                weakSelf.activityModel = activityModel;
                [weakSelf.tableView reloadData];
                
                [weakSelf.confirmBtn setTitle:kLocalizedTableString(@"Already enrolled tip", @"CPLocalizable") forState:UIControlStateNormal];
                weakSelf.confirmBtn.hidden = NO;
                weakSelf.confirmBtn.enabled = NO;
                weakSelf.confirmBtn.backgroundColor = RGBA(220, 220, 220, 1);
                
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EnrollActivitySuccess" object:nil];
            
                
            }
            else{
                if ([[responseObject valueForKey:@"code"] integerValue] == 401) {
                    // 未登录
                    [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
                }
                else if ([[responseObject valueForKey:@"code"] integerValue] == 500) {
                    //
                    NSString *msg = [responseObject valueForKey:@"msg"];
//                    if (msg && [msg containsString:@"您已经报名"]) {
                    if (msg && [msg containsString:@"数据库中已存在该记录"]) {
                        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Already enrolled", @"CPLocalizable")];
                    }
                }
            }
        }
        else {
            NSLog(@"CPActivityDetailVC requestEnrollActivity 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPActivityDetailVC requestEnrollActivity error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
