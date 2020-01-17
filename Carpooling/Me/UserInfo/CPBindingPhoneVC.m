//
//  CPBindingPhoneVC.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBindingPhoneVC.h"
#import "CPBindingPhoneCell1.h"
#import "NBPhoneNumberUtil.h"
#import "CPNationCodeVC.h"

@interface CPBindingPhoneVC ()<CPBindingPhoneCell1Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL startCount;
@property (nonatomic, assign) BOOL verifyCodeCorrect;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *verifyCode;
@property (nonatomic, strong) NSDictionary *nationDict;
@end

@implementation CPBindingPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                return RGBA(243, 244, 246, 1);
            }
            else {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                return [UIColor systemBackgroundColor];
            }
        }];
        
        self.tableView.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    self.title = kLocalizedTableString(@"Bind Phone", @"CPLocalizable");
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.nationDict = @{@"country":@"United States", @"code":@"+1", @"domainCode":@"US"};
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 10)];
    //    return view;
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
    CPBindingPhoneCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPBindingPhoneCell1"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    NSAttributedString *attrString1 = [[NSAttributedString alloc] initWithString:kLocalizedTableString(@"Enter Phone", @"CPLocalizable") attributes:
                                      @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                        NSFontAttributeName:cell.phoneTF.font
                                        }];
    cell.phoneTF.attributedPlaceholder = attrString1;
    
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:kLocalizedTableString(@"Enter Verification code", @"CPLocalizable") attributes:
                                      @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                        NSFontAttributeName:cell.veriCodeTF.font
                                        }];
    cell.veriCodeTF.attributedPlaceholder = attrString2;
    
    [cell.confirmBtn setTitle:kLocalizedTableString(@"Bind Phone", @"CPLocalizable") forState:UIControlStateNormal];
    
    cell.subtitleLbl.text = [self.nationDict valueForKey:@"country"];
    cell.codeLbl.text = [self.nationDict valueForKey:@"code"];
    
    
    cell.delegate = self;
    cell.startCount = _startCount;
    if (_phone) {
        cell.phoneTF.text = _phone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)bindingPhoneCell1TFTextField:(UITextField *)textField{
    if (textField.tag == 10000) {
        _phone = textField.text;
    }
    else if (textField.tag == 10001) {
        _verifyCode = textField.text;
    }
    
    NSLog(@"userRegister1VCCell2TFText text:%@, _verifyCode:%@", textField.text, _verifyCode);
}

- (void)bindingPhoneCell1GetVerifyAction{
    NSLog(@"bindingPhoneCell1GetVerifyAction action");
    
    NSString *tips = @"";
    if (!_phone) {
        tips = kLocalizedTableString(@"Enter Account", @"CPLocalizable");
    }
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:_phone
                                 defaultRegion:[self.nationDict valueForKey:@"domainCode"] error:&anError];
    NSLog(@"bindingPhoneCell1GetVerifyAction domainCode:%@", [self.nationDict valueForKey:@"domainCode"]);
    if (anError == nil) {
        NSLog(@"CPUserRegister1VC phone:%@ isValidPhoneNumber ? [%@]", _phone, [phoneUtil isValidNumber:myNumber] ? @"YES":@"NO");
        
        if (![phoneUtil isValidNumber:myNumber]) {
            NSLog(@"NBPhoneNumberUtil Error : %@", [anError localizedDescription]);
            tips = kLocalizedTableString(@"Enter Correct Phone", @"CPLocalizable");
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
        tips = kLocalizedTableString(@"Enter Correct Phone", @"CPLocalizable");
    }
    

    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    
    self.startCount = YES;
    [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    [self requestVerifyCode];

}

- (void)bindingPhoneCell1ConfirmAction{
    [self.view endEditing:YES];
    
//    [self requestCheckingVerifyCodeIsCorrect];
    if (_phone && _verifyCode) {
        [self requestBindingPhone];
    }
}

- (void)bindingPhoneCell1GoNationCodeVCAction{
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPNationCodeVC *nationCodeVC = [storyboard instantiateViewControllerWithIdentifier:@"CPNationCodeVC"];
    nationCodeVC.passValueblock = ^(NSDictionary * _Nonnull dict) {
        self.nationDict = dict;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:nationCodeVC animated:YES];
}


- (void)requestVerifyCode{
    NSLog(@"CPBindingPhoneVC requestVerifyCode url:%@", [NSString stringWithFormat:@"%@/api/user/v1/smscode.json", BaseURL]);
//    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/smscode.json", BaseURL] parameters:@{@"phone":_phone, @"countryCode":[self.nationDict valueForKey:@"code"]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPBindingPhoneVC requestVerifyCode responseObject:%@", responseObject);
        if (responseObject) {
            [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];

        }
        else {
            NSLog(@"CPBindingPhoneVC requestVerifyCode 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPBindingPhoneVC requestVerifyCode error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

//- (void)requestCheckingVerifyCodeIsCorrect{
//    [SVProgressHUD show];
//    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/verification", BaseURL] parameters:@{@"phone":_phone, @"code":_verifyCode}.mutableCopy success:^(id responseObject) {
//        [SVProgressHUD dismiss];
//        NSLog(@"CPBindingPhoneVC requestCheckingVerifyCodeIsCorrect responseObject:%@", responseObject);
//        WS(weakSelf);
//        if (responseObject) {
//            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
//                weakSelf.verifyCodeCorrect = YES;
//            }
//            else{
//                weakSelf.verifyCodeCorrect = NO;
//                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
//                NSLog(@"CPBindingPhoneVC requestCheckingVerifyCodeIsCorrect 失败");
//            }
//
//            if (weakSelf.verifyCodeCorrect) {
//                NSString *tips = @"";
//                if (!weakSelf.phone) {
//                    tips = kLocalizedTableString(@"Enter Nickname", @"CPLocalizable");
//                }
//                else if (!weakSelf.verifyCode) {
//                    tips = kLocalizedTableString(@"Enter Nickname", @"CPLocalizable");
//                }
//
//                if (![tips isEqualToString:@""]) {
//                    [SVProgressHUD showInfoWithStatus:tips];
//                    return;
//                }
//                [weakSelf requestBindingPhone];
//            }
//
//        }
//        else {
//            NSLog(@"CPBindingPhoneVC requestCheckingVerifyCodeIsCorrect 失败");
//        }
//
//
//    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
//        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
//        NSLog(@"CPBindingPhoneVC requestCheckingVerifyCodeIsCorrect error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
//    }];
//}


- (void)requestBindingPhone{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/bingPhone.json", BaseURL] parameters:@{@"phone":_phone, @"code":_verifyCode}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPBindingPhoneVC requestBindingPhone responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(weakSelf.phone);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPBindingPhoneVC requestBindingPhone 失败");
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
            }
        }
        else {
            NSLog(@"CPBindingPhoneVC requestBindingPhone 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPBindingPhoneVC requestBindingPhone error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
