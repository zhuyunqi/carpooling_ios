//
//  CPUserRegister2VC.m
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserRegister2VC.h"
#import "VHLNavigation.h"
#import "CPUserRegister1VCCell1.h"
#import "CPUserRegister1VCCell2.h"
#import "SAMKeychain.h"
#import "CPUserReqResultModel.h"
#import "CPUserReqResultSubModel.h"
#import "CPUserInfoModel.h"

#import <WFChatClient/WFCCNetworkService.h>


@interface CPUserRegister2VC ()<CPUserRegister1VCCell1Delegate, CPUserRegister1VCCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *confirmPwd;
@property (nonatomic, strong) NSString *chatId;

@property (nonatomic, strong) NSString *clientId;

@property (nonatomic, strong) NSAttributedString *placeholder1;
@property (nonatomic, strong) NSAttributedString *placeholder2;
@property (nonatomic, strong) NSString *nextString;
@end

@implementation CPUserRegister2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self vhl_setNavBarShadowImageHidden:YES];
    
    if (_handleType == 0) {
        self.title = kLocalizedTableString(@"Register Account", @"CPLocalizable");
        _nextString = kLocalizedTableString(@"Register Login", @"CPLocalizable");
    }
    else if (_handleType == 1) {
        self.title = kLocalizedTableString(@"Reset Password", @"CPLocalizable");
        _nextString = kLocalizedTableString(@"Reset Password", @"CPLocalizable");
    }
    
    NSString *str1 = kLocalizedTableString(@"Number-letter Combination", @"CPLocalizable");
    NSAttributedString *attrString1 = [[NSAttributedString alloc] initWithString:str1 attributes:
                                       @{NSForegroundColorAttributeName:RGBA(204, 204, 204, 1),
                                         NSFontAttributeName:[UIFont systemFontOfSize:15.f]
                                         }];
    _placeholder1 = attrString1;
    
    NSString *str2 = kLocalizedTableString(@"Confirm Password", @"CPLocalizable");
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:str2 attributes:
                                       @{NSForegroundColorAttributeName:RGBA(204, 204, 204, 1),
                                         NSFontAttributeName:[UIFont systemFontOfSize:15.f]
                                         }];
    _placeholder2 = attrString2;
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    UIImageView *backImageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [backImageView setImage:[UIImage imageNamed:@"login_background_image"]];
    self.tableView.backgroundView = backImageView;
    
    self.clientId = [[WFCCNetworkService sharedInstance] getClientId];
    NSLog(@"CPUserRegister2VC viewDidLoad clientId:%@", self.clientId);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //        return 90;
        return 50;
    }
    else if (indexPath.row == 1) {
        return 80;
    }
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 10)];
    //    return view;
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell1"];
        return cell;
    }
    else if (indexPath.row == 1) {
        CPUserRegister1VCCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell2"];
        cell.textTF.attributedPlaceholder = _placeholder1;
        cell.textTF.keyboardType = UIKeyboardTypeASCIICapable;
        cell.textTF.secureTextEntry = YES;
        cell.delegate = self;
        return cell;
    }
    else{
        CPUserRegister1VCCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell3"];
        cell.textTF.attributedPlaceholder = _placeholder2;
        cell.textTF.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        cell.textTF.rightViewMode = UITextFieldViewModeNever;
        cell.textTF.keyboardType = UIKeyboardTypeASCIICapable;
        cell.textTF.secureTextEntry = YES;
        cell.delegate = self;
        [cell.confirmBtn setTitle:_nextString forState:UIControlStateNormal];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        CPActivitysVC *activitysVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivitysVC"];
        //        [self.navigationController pushViewController:activitysVC animated:YES];
    }
}

- (void)userRegister1VCCell1TFText:(NSString *)text{
    _password = text;
    NSLog(@"userRegister1VCCell1TFText text:%@, _password:%@", text, _password);
}

- (void)userRegister1VCCell2TFText:(NSString *)text{
    _confirmPwd = text;
    NSLog(@"userRegister1VCCell2TFText text:%@, _confirmPwd:%@", text, _confirmPwd);
}

- (void)userRegister1VCCell2ConfirmAction{
    [self.view endEditing:YES];
    
    NSString *tips = @"";
    if (!_password) {
        tips = kLocalizedTableString(@"Enter Password", @"CPLocalizable");
    }
    else if (!_confirmPwd) {
        tips = kLocalizedTableString(@"Confirm Password", @"CPLocalizable");
    }
    else if (_password && _confirmPwd) {
        if (_password.length < 8) {
            tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 1", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
        }
        else if (_confirmPwd.length < 8) {
            tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 2", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
        }
        else {
            
            BOOL pwdRegexResult = NO;
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,}$" options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *result1 = [regex firstMatchInString:_password options:0 range:NSMakeRange(0, [_password length])];
            if (result1) {
                NSLog(@"_password true");
                pwdRegexResult = YES;
            }
            else {
                NSLog(@"_password false");
                pwdRegexResult = NO;
            }
            
            BOOL confirmPwdRegexResult = NO;
            NSTextCheckingResult *result2 = [regex firstMatchInString:_confirmPwd options:0 range:NSMakeRange(0, [_confirmPwd length])];
            if (result2) {
                NSLog(@"_confirmPwd true");
                confirmPwdRegexResult = YES;
            }
            else {
                NSLog(@"_confirmPwd false");
                confirmPwdRegexResult = NO;
            }
            
            if (!pwdRegexResult) {                
                tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 1", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
            }
            else if (!confirmPwdRegexResult) {
                tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 2", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
            }
            else if (![_password isEqualToString:_confirmPwd]) {
                tips = kLocalizedTableString(@"Password Error", @"CPLocalizable");
            }
            
        }
        
    }
    
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    
    if (_handleType == 0) {
        if (_isCellPhoneRegister) {
            [self requestPhoneRegister];
        }
        else if (_isEmailRegister) {
            [self requestEmailRegister];
        }
    }
    else if (_handleType == 1) {
        [self requestFogotPassword];
    }
}


- (void)requestPhoneRegister{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
    deviceToken = deviceToken == nil ? @"" : deviceToken;
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/register.json", BaseURL] parameters:@{@"phone":_account, @"password":_confirmPwd, @"clientId":self.clientId, @"deviceToken":deviceToken}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister2VC requestPhoneRegister responseObject:%@", responseObject);
        if (responseObject) {
            CPUserReqResultModel *masterModel = [CPUserReqResultModel mj_objectWithKeyValues:responseObject];
            CPUserReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                [[NSUserDefaults standardUserDefaults] setValue:subModel.token forKey:kUserToken];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:subModel.userId] forKey:kUserID];
                [[NSUserDefaults standardUserDefaults] setValue:weakSelf.account forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:subModel.user.avatar forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:subModel.user.nickname forKey:kUserNickname];
                
                
                NSString *userId = [subModel.imResult valueForKey:@"userId"];
                NSString *userToken = [subModel.imResult valueForKey:@"token"];
                [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
                [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:@"savedToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (![[WFCCNetworkService sharedInstance].userId isEqualToString:userId]) {
                    [[WFCCNetworkService sharedInstance] disconnect:YES];
                    [[WFCCNetworkService sharedInstance] connect:userId token:userToken];
                    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
                    if (nil != deviceToken){
                        [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
                    }
                }
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPUserRegister2VC requestPhoneRegister 失败");
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
            }
        }
        else {
            NSLog(@"CPUserRegister2VC requestPhoneRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister2VC requestPhoneRegister error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



- (void)requestEmailRegister{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
    deviceToken = deviceToken == nil ? @"" : deviceToken;
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/registerByEmail.json", BaseURL] parameters:@{@"email":_account, @"password":_confirmPwd, @"clientId":self.clientId, @"deviceToken":deviceToken}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister2VC requestEmailRegister responseObject:%@", responseObject);
        if (responseObject) {
            CPUserReqResultModel *masterModel = [CPUserReqResultModel mj_objectWithKeyValues:responseObject];
            CPUserReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                [[NSUserDefaults standardUserDefaults] setValue:subModel.token forKey:kUserToken];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:subModel.userId] forKey:kUserID];
                [[NSUserDefaults standardUserDefaults] setValue:weakSelf.account forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:subModel.user.avatar forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:subModel.user.nickname forKey:kUserNickname];
                
                
                NSString *userId = [subModel.imResult valueForKey:@"userId"];
                NSString *userToken = [subModel.imResult valueForKey:@"token"];
                [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
                [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:@"savedToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (![[WFCCNetworkService sharedInstance].userId isEqualToString:userId]) {
                    [[WFCCNetworkService sharedInstance] disconnect:YES];
                    [[WFCCNetworkService sharedInstance] connect:userId token:userToken];
                    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
                    if (nil != deviceToken){
                        [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
                    }
                }
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPUserRegister2VC requestEmailRegister 失败");
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
            }
        }
        else {
            NSLog(@"CPUserRegister2VC requestEmailRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister2VC requestEmailRegister error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



- (void)requestFogotPassword{
    NSLog(@"CPUserRegister2VC requestFogotPassword url:%@, self.account:%@, self.confirmPwd:%@", [NSString stringWithFormat:@"%@/api/register/v1/register.json", BaseURL], self.account, self.confirmPwd);
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/setPassword.json", BaseURL] parameters:@{@"phone":_account, @"password":_confirmPwd}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister2VC requestFogotPassword responseObject:%@", responseObject);
        if (responseObject) {
            CPUserReqResultModel *masterModel = [CPUserReqResultModel mj_objectWithKeyValues:responseObject];
//            CPUserReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPUserRegister2VC requestFogotPassword 失败");
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
            }
        }
        else {
            NSLog(@"CPUserRegister2VC requestFogotPassword 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister2VC requestFogotPassword error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
