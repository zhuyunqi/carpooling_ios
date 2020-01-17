//
//  CPUserRegister1VC.m
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserRegister1VC.h"
#import "VHLNavigation.h"
#import "CPUserRegister1VCCell1.h"
#import "CPUserRegister1VCCell2.h"
#import "CPUserRegister1VCCell3.h"
#import "CPUserRegister1VCCell4.h"
#import "CPUserRegister2VC.h"
#import "CPNationCodeVC.h"

#import "NBPhoneNumberUtil.h"

@interface CPUserRegister1VC ()<CPUserRegister1VCCell1Delegate, CPUserRegister1VCCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL startCount;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *verifyCode;
@property (nonatomic, strong) NSAttributedString *placeholder1;
@property (nonatomic, strong) NSAttributedString *placeholder2;
@property (nonatomic, strong) NSDictionary *nationDict;
@property (nonatomic, strong) NSString *nextString;

@property (nonatomic, assign) BOOL isCellPhone;
@property (nonatomic, assign) BOOL isEmail;
@end


@implementation CPUserRegister1VC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self vhl_setNavBarShadowImageHidden:YES];
    
    NSString *str1 = @"";
    if (_handleType == 0) { // 注册
        self.title = kLocalizedTableString(@"Register Account", @"CPLocalizable");
        str1 = kLocalizedTableString(@"Enter Phone or Email", @"CPLocalizable");
    }
    else if (_handleType == 1) { // 忘记密码
        self.title = kLocalizedTableString(@"Forgot Password", @"CPLocalizable");
//        str1 = kLocalizedTableString(@"Enter Account", @"CPLocalizable");
        str1 = kLocalizedTableString(@"Enter Phone or Email", @"CPLocalizable");
    }
    NSAttributedString *attrString1 = [[NSAttributedString alloc] initWithString:str1 attributes:
                                       @{NSForegroundColorAttributeName:RGBA(204, 204, 204, 1),
                                         NSFontAttributeName:[UIFont systemFontOfSize:15.f]
                                         }];
    _placeholder1 = attrString1;
    
    
    NSString *str2 = kLocalizedTableString(@"Enter Verification code", @"CPLocalizable");
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:str2 attributes:
                                       @{NSForegroundColorAttributeName:RGBA(204, 204, 204, 1),
                                         NSFontAttributeName:[UIFont systemFontOfSize:15.f]
                                         }];
    _placeholder2 = attrString2;
    _nextString = kLocalizedTableString(@"Next", @"CPLocalizable");
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    UIImageView *backImageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [backImageView setImage:[UIImage imageNamed:@"login_background_image"]];
    self.tableView.backgroundView = backImageView;
    
    self.isCellPhone = false;
    self.isEmail = false;
    self.nationDict = @{@"country":@"United States", @"code":@"+1", @"domainCode":@"US"};
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 70;
    }
    if (indexPath.row == 1) {
        return CPREGULARCELLHEIGHT-20;
    }
    else if (indexPath.row == 2) {
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
        CPUserRegister1VCCell4 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell1"];
        
        return cell;
    }
    else if (indexPath.row == 1) {
        CPUserRegister1VCCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell4"];
        cell.subTitleLbl.text = [self.nationDict valueForKey:@"country"];
//        cell.textTF.attributedPlaceholder = _placeholder1;
//        cell.delegate = self;
        return cell;
    }
    else if (indexPath.row == 2) {
        CPUserRegister1VCCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell2"];
        cell.nationCodeLbl.text = [self.nationDict valueForKey:@"code"];
        cell.textTF.attributedPlaceholder = _placeholder1;
        cell.delegate = self;
        return cell;
    }
    else{
        CPUserRegister1VCCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell3"];
        cell.textTF.attributedPlaceholder = _placeholder2;
        cell.delegate = self;
        cell.startCount = self.startCount;
        [cell.confirmBtn setTitle:_nextString forState:UIControlStateNormal];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        [self.view endEditing:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPNationCodeVC *nationCodeVC = [storyboard instantiateViewControllerWithIdentifier:@"CPNationCodeVC"];
        nationCodeVC.passValueblock = ^(NSDictionary * _Nonnull dict) {
            self.nationDict = dict;
            [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRow:2 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:nationCodeVC animated:YES];
    }
}


- (void)userRegister1VCCell1TFText:(NSString *)text{
    _account = text;
    NSLog(@"userRegister1VCCell1TFText text:%@, _account:%@", text, _account);
}

- (void)userRegister1VCCell2TFText:(NSString *)text{
    _verifyCode = text;
    NSLog(@"userRegister1VCCell2TFText text:%@, _verifyCode:%@", text, _verifyCode);
}

- (void)userRegister1VCCell2GetVerifyAction{
    NSLog(@"userRegister1VCCell2GetVerifyAction action");
    
    NSString *tips = [self checkIfParamsCorrect];
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }

    
    self.startCount = YES;
    [self.tableView reloadRow:3 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    
    
    if (self.isCellPhone) {
        [self requestPhoneVerifyCode];
    }
    else if (self.isEmail) {
        [self requestEmailVerifyCode];
    }
}

- (void)userRegister1VCCell2ConfirmAction{
    [self.view endEditing:YES];

    NSString *tips = [self checkIfParamsCorrect];
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    
    if (self.isCellPhone) {
        [self requestCheckPhoneVerifyCodeIsCorrect];
    }
    else if (self.isEmail) {
        [self requestCheckEmailVerifyCodeIsCorrect];
    }
}


- (void)requestPhoneVerifyCode{
    NSLog(@"CPUserRegister1VC requestPhoneVerifyCode url:%@", [NSString stringWithFormat:@"%@/api/register/v1/getCode.json", BaseURL]);
//    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/getCode.json", BaseURL] parameters:@{@"phone":_account, @"countryCode":[self.nationDict valueForKey:@"code"]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister1VC requestPhoneVerifyCode responseObject:%@", responseObject);
        if (responseObject) {
            [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
            }
            else{
                NSLog(@"CPUserRegister1VC requestPhoneVerifyCode 失败");
            }
        }
        else {
            NSLog(@"CPUserRegister1VC requestPhoneVerifyCode 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister1VC requestPhoneVerifyCode error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)requestCheckPhoneVerifyCodeIsCorrect{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/verification", BaseURL] parameters:@{@"phone":_account, @"code":_verifyCode}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPSettingVC requestCheckPhoneVerifyCodeIsCorrect responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPUserRegister2VC *userRegister2VC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserRegister2VC"];
                userRegister2VC.handleType = weakSelf.handleType;
                userRegister2VC.account = weakSelf.account;
                userRegister2VC.isCellPhoneRegister = weakSelf.isCellPhone;
                userRegister2VC.isEmailRegister = weakSelf.isEmail;
                [weakSelf.navigationController pushViewController:userRegister2VC animated:YES];

            }
            else{
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"CPSettingVC requestCheckPhoneVerifyCodeIsCorrect 失败");
            }
        }
        else {
            NSLog(@"CPSettingVC requestCheckPhoneVerifyCodeIsCorrect 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPSettingVC requestCheckPhoneVerifyCodeIsCorrect error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (NSString*)checkIfParamsCorrect{
    NSString *tips = @"";
    if (!_account) {
        tips = kLocalizedTableString(@"Enter Account", @"CPLocalizable");
    }
    
    
    if (![Utils isValidateEmail:_account]) {
        self.isEmail = false;
    }
    else {
        self.isEmail = true;
    }
    
    
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:_account
                                 defaultRegion:[self.nationDict valueForKey:@"domainCode"] error:&anError];
    NSLog(@"checkIfParamsCorrect domainCode:%@", [self.nationDict valueForKey:@"domainCode"]);
    if (anError == nil) {
        NSLog(@"CPUserRegister1VC phone:%@ isValidPhoneNumber ? [%@]", _account, [phoneUtil isValidNumber:myNumber] ? @"YES":@"NO");
        
        if (![phoneUtil isValidNumber:myNumber]) {
            self.isCellPhone = false;
            NSLog(@"NBPhoneNumberUtil Error : %@", [anError localizedDescription]);
        }
        else{
            self.isCellPhone = YES;
        }
        
        //        // E164          : +436766077303
        //        NSLog(@"E164          : %@", [phoneUtil format:myNumber
        //                                          numberFormat:NBEPhoneNumberFormatE164
        //                                                 error:&anError]);
        //        // INTERNATIONAL : +43 676 6077303
        //        NSLog(@"INTERNATIONAL : %@", [phoneUtil format:myNumber
        //                                          numberFormat:NBEPhoneNumberFormatINTERNATIONAL
        //                                                 error:&anError]);
        //        // NATIONAL      : 0676 6077303
        //        NSLog(@"NATIONAL      : %@", [phoneUtil format:myNumber
        //                                          numberFormat:NBEPhoneNumberFormatNATIONAL
        //                                                 error:&anError]);
        //        // RFC3966       : tel:+43-676-6077303
        //        NSLog(@"RFC3966       : %@", [phoneUtil format:myNumber
        //                                          numberFormat:NBEPhoneNumberFormatRFC3966
        //                                                 error:&anError]);
    } else {
        NSLog(@"NBPhoneNumberUtil Error : %@", [anError localizedDescription]);
        self.isCellPhone = false;
    }
    
        
    if (self.isCellPhone || self.isEmail) {
        
    }
    else{
        if (!self.isCellPhone) {
            tips = kLocalizedTableString(@"Enter Correct Phone", @"CPLocalizable");
        }
        else if (!self.isEmail) {
            tips = kLocalizedTableString(@"Enter Correct Email", @"CPLocalizable");
        }
    }
    
    return tips;
}

- (void)requestEmailVerifyCode{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/getCodeByEmail", BaseURL] parameters:@{@"email":_account}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister1VC requestEmailVerifyCode responseObject:%@", responseObject);
        if (responseObject) {
            [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
            }
            else{
                NSLog(@"CPUserRegister1VC requestEmailVerifyCode 失败");
            }
        }
        else {
            NSLog(@"CPUserRegister1VC requestEmailVerifyCode 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister1VC requestEmailVerifyCode error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)requestCheckEmailVerifyCodeIsCorrect{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/verificationByEmail", BaseURL] parameters:@{@"email":_account, @"code":_verifyCode}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPSettingVC requestCheckEmailVerifyCodeIsCorrect responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPUserRegister2VC *userRegister2VC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserRegister2VC"];
                userRegister2VC.handleType = weakSelf.handleType;
                userRegister2VC.account = weakSelf.account;
                userRegister2VC.isCellPhoneRegister = weakSelf.isCellPhone;
                userRegister2VC.isEmailRegister = weakSelf.isEmail;
                [weakSelf.navigationController pushViewController:userRegister2VC animated:YES];
                
            }
            else{
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"CPSettingVC requestCheckEmailVerifyCodeIsCorrect 失败");
            }
        }
        else {
            NSLog(@"CPSettingVC requestCheckEmailVerifyCodeIsCorrect 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPSettingVC requestCheckEmailVerifyCodeIsCorrect error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}
@end
