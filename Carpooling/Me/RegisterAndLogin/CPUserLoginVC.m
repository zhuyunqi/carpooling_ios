//
//  CPUserLoginVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserLoginVC.h"
#import "VHLNavigation.h"
#import "CPUserRegister1VCCell1.h"
#import "CPUserRegister1VCCell2.h"
#import "CPUserLoginCell1.h"
#import "CPUserReqResultModel.h"
#import "CPUserReqResultSubModel.h"
#import "CPUserInfoModel.h"
#import "CPUserRegister1VC.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <WFChatClient/WFCCNetworkService.h>




@interface CPUserLoginVC ()<CPUserRegister1VCCell1Delegate, CPUserRegister1VCCell2Delegate, CPUserLoginCell1Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSAttributedString *placeholder1;
@property (nonatomic, strong) NSAttributedString *placeholder2;

@property (nonatomic, strong) NSString *clientId;

@property (nonatomic, copy) NSString *fbUserID;
@property (nonatomic, copy) NSString *fbUserNickname;
@property (nonatomic, copy) NSString *fbUserAvatar;
@property (nonatomic, copy) NSString *fbUserEmail;
@property (nonatomic, strong) FBSDKAccessToken *fbAccess_token;

@property (nonatomic, assign) BOOL isEmail;
@end

@implementation CPUserLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self vhl_setNavBarShadowImageHidden:YES];
    self.title = kLocalizedTableString(@"Login", @"CPLocalizable");
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [backImageView setImage:[UIImage imageNamed:@"login_background_image"]];
    self.tableView.backgroundView = backImageView;
    
    NSString *str1 = kLocalizedTableString(@"Enter Account", @"CPLocalizable");
    NSAttributedString *attrString1 = [[NSAttributedString alloc] initWithString:str1 attributes:
                                       @{NSForegroundColorAttributeName:RGBA(204, 204, 204, 1),
                                         NSFontAttributeName:[UIFont systemFontOfSize:15.f]
                                         }];
    _placeholder1 = attrString1;
    
    NSString *str2 = kLocalizedTableString(@"Enter Password", @"CPLocalizable");
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:str2 attributes:
                                       @{NSForegroundColorAttributeName:RGBA(204, 204, 204, 1),
                                         NSFontAttributeName:[UIFont systemFontOfSize:15.f]
                                         }];
    _placeholder2 = attrString2;
    
    
    self.clientId = [[WFCCNetworkService sharedInstance] getClientId];
    NSLog(@"CPUserLoginVC viewDidLoad clientId:%@", self.clientId);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    else if (indexPath.row == 2) {
        return 150;
    }
    return kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kBOTTOMSAFEHEIGHT-50-80-150;
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
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.row == 2) {
        CPUserRegister1VCCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserRegister1VCCell3"];
        cell.textTF.attributedPlaceholder = _placeholder2;
        cell.textTF.secureTextEntry = YES;
        cell.textTF.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        cell.textTF.rightViewMode = UITextFieldViewModeNever;
        cell.delegate = self;
        [cell.confirmBtn setTitle:kLocalizedTableString(@"Login", @"CPLocalizable") forState:UIControlStateNormal];
        
        return cell;
    }
    else{
        CPUserLoginCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserLoginCell1"];
        cell.delegate = self;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)userRegister1VCCell1TFText:(NSString *)text{
    _account = text;
    NSLog(@"CPUserLoginVC text:%@, _account:%@", text, _account);
}

- (void)userRegister1VCCell2TFText:(NSString *)text{
    _password = text;
    NSLog(@"CPUserLoginVC text:%@, _verifyCode:%@", text, _password);
}

- (void)userRegister1VCCell2ConfirmAction{
    [self.view endEditing:YES];
    
    NSString *tips = [self checkIfParamsCorrect];
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    
    if (self.isEmail) {
        [self requestEmailLogin];
    }
    else {
        [self requestPhoneLogin];
    }
}

- (void)userLoginCell1RegisterBtnAction{
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPUserRegister1VC *userRegister1VC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserRegister1VC"];
    userRegister1VC.handleType = 0;
    [self.navigationController pushViewController:userRegister1VC animated:YES];
}

- (void)userLoginCell1ForgotPwdBtnAction{
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPUserRegister1VC *userRegister1VC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserRegister1VC"];
    userRegister1VC.handleType = 1;
    [self.navigationController pushViewController:userRegister1VC animated:YES];
}



- (void)requestPhoneLogin{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
    deviceToken = deviceToken == nil ? @"" : deviceToken;
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/login.json", BaseURL] parameters:@{@"phone":_account, @"password":_password, @"clientId":self.clientId, @"deviceToken":deviceToken}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister2VC requestPhoneLogin responseObject:%@", responseObject);
        WS(weakSelf);
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
                
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"CPUserRegister2VC requestPhoneLogin 失败");
            }
        }
        else {
            NSLog(@"CPUserRegister2VC requestPhoneLogin 失败");
        }

    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister2VC requestPhoneLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)requestEmailLogin{
    [SVProgressHUD show];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
    deviceToken = deviceToken == nil ? @"" : deviceToken;
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/loginByEmail.json", BaseURL] parameters:@{@"email":_account, @"password":_password, @"clientId":self.clientId, @"deviceToken":deviceToken}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserRegister2VC requestEmailLogin responseObject:%@", responseObject);
        WS(weakSelf);
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
                
                
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"CPUserRegister2VC requestEmailLogin 失败");
            }
        }
        else {
            NSLog(@"CPUserRegister2VC requestEmailLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserRegister2VC requestEmailLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (NSString*)checkIfParamsCorrect{
    NSString *tips = @"";
    if (!_account) {
        tips = kLocalizedTableString(@"Enter Account", @"CPLocalizable");
    }
    
    if (!_password) {
        tips = kLocalizedTableString(@"Enter Password", @"CPLocalizable");
    }
    
    
    if (![Utils isValidateEmail:_account]) {
        self.isEmail = false;
    }
    else {
        self.isEmail = true;
    }
    
    return tips;
}

#pragma mark - facebook login
- (void)userLoginCell1ThirdPartyLoginBtnAction{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
    deviceToken = deviceToken == nil ? @"" : deviceToken;
    if ([FBSDKAccessToken currentAccessToken]) {
        self.fbUserID = [FBSDKAccessToken currentAccessToken].userID;
        // User is logged in, do work such as go to next view controller.
        NSLog(@"userLoginCell1ThirdPartyLoginBtnAction [FBSDKAccessToken currentAccessToken].userID:%@", [FBSDKAccessToken currentAccessToken].userID);
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:[FBSDKAccessToken currentAccessToken].userID
                                      parameters:@{@"fields":@"id, name, email, age_range, first_name, last_name, link, gender, locale, picture, timezone, updated_time, verified"}
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSLog(@"FBSDKGraphRequest result:%@", result);
            if (result) {
                self.fbUserNickname = result[@"name"];
                self.fbUserEmail = result[@"email"];
                self.fbUserAvatar = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", self.fbUserID];
                
                // login with fb
                [self requestFBLogin:@{
                                       @"email":self.fbUserEmail,
                                       @"nickname":self.fbUserNickname,
                                       @"username":self.fbUserID,
                                       @"avatar":self.fbUserAvatar,
                                       @"clientId":self.clientId,
                                       @"deviceToken":deviceToken
                                       }];
            }
        }];
        

    }
    else {
        //登陆按钮管理器用于管理登陆按钮的响应事件和FB传递的数据
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        //    @[@"public_profile",@"email",@"user_friends"]
        [loginManager logInWithPermissions:@[@"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
            NSLog(@"userLoginCell1ThirdPartyLoginBtnAction error:%@", error);
            if(result){
                //登陆成功
                if ([FBSDKAccessToken currentAccessToken].userID) {
                    self.fbAccess_token = [FBSDKAccessToken currentAccessToken];
                    self.fbUserID = [FBSDKAccessToken currentAccessToken].userID;
                    NSLog(@"userLoginCell1ThirdPartyLoginBtnAction result:%@ self.fbAccess_token:%@, self.fbUserID:%@", result, self.fbAccess_token, self.fbUserID);
                    self.fbUserAvatar = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", self.fbUserID];
                    
                    NSLog(@"Logged in");
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                                  initWithGraphPath:result.token.userID
                                                  parameters:@{@"fields":@"id, name, email, age_range, first_name, last_name, link, gender, locale, picture, timezone, updated_time, verified"}
                                                  HTTPMethod:@"GET"];
                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        NSLog(@"FBSDKGraphRequest result:%@", result);
                        if (result) {
                            self.fbUserNickname = result[@"name"];
                            self.fbUserEmail = result[@"email"];
                            
                            // login with fb
                            [self requestFBLogin:@{
                                                   @"email":self.fbUserEmail,
                                                   @"nickname":self.fbUserNickname,
                                                   @"username":self.fbUserID,
                                                   @"avatar":self.fbUserAvatar,
                                                   @"clientId":self.clientId,
                                                   @"deviceToken":deviceToken
                                                   }];
                        }
                    }];
                }
            }
        }];
    }
}

#pragma mark - fb
- (void)requestFBLogin:(NSDictionary*)dict{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/loginByFb", BaseURL] parameters:dict.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPUserLoginVC requestFBLogin responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            CPUserReqResultModel *masterModel = [CPUserReqResultModel mj_objectWithKeyValues:responseObject];
            CPUserReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                [[NSUserDefaults standardUserDefaults] setValue:subModel.token forKey:kUserToken];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:subModel.userId] forKey:kUserID];
                [[NSUserDefaults standardUserDefaults] setValue:weakSelf.fbUserID forKey:kUserLoginAccount];
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
                
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"CPUserRegister2VC requestPhoneLogin 失败");
            }
        }
        else {
            NSLog(@"CPUserLoginVC requestFBLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPUserLoginVC requestFBLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
