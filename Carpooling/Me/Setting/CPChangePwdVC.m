//
//  CPChangePwdVC.m
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPChangePwdVC.h"
#import "CPChangePwdCell1.h"
#import "CPChangePwdCell2.h"

@interface CPChangePwdVC ()<CPChangePwdCell1Delegate, CPChangePwdCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *oldPwd;
@property (nonatomic, strong) NSString *anewPwd;
@property (nonatomic, strong) NSString *anewConfirmPwd;
@end

@implementation CPChangePwdVC

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
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    self.title = kLocalizedTableString(@"Change Password", @"CPLocalizable");
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 80;
    }
    return CPREGULARCELLHEIGHT;
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
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPChangePwdCell1"];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:kLocalizedTableString(@"Enter Old Password", @"CPLocalizable") attributes:
                                           @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                             NSFontAttributeName:((CPChangePwdCell1*)cell).textField.font
                                             }];
        ((CPChangePwdCell1*)cell).textField.attributedPlaceholder = attrString;
        ((CPChangePwdCell1*)cell).textField.keyboardType = UIKeyboardTypeDefault;
        ((CPChangePwdCell1*)cell).textField.tag = 10000;
        ((CPChangePwdCell1*)cell).delegate = self;
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPChangePwdCell2"];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:kLocalizedTableString(@"Enter New Password", @"CPLocalizable") attributes:
                                          @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                            NSFontAttributeName:((CPChangePwdCell1*)cell).textField.font
                                            }];
        ((CPChangePwdCell1*)cell).textField.attributedPlaceholder = attrString;
        ((CPChangePwdCell1*)cell).textField.keyboardType = UIKeyboardTypeDefault;
        ((CPChangePwdCell1*)cell).textField.tag = 10001;
        ((CPChangePwdCell1*)cell).delegate = self;
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPChangePwdCell3"];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:kLocalizedTableString(@"Confirm New Password", @"CPLocalizable") attributes:
                                          @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                            NSFontAttributeName:((CPChangePwdCell1*)cell).textField.font
                                            }];
        ((CPChangePwdCell1*)cell).textField.attributedPlaceholder = attrString;
        ((CPChangePwdCell1*)cell).textField.keyboardType = UIKeyboardTypeDefault;
        ((CPChangePwdCell1*)cell).textField.tag = 10002;
        ((CPChangePwdCell1*)cell).delegate = self;
    }
    else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPChangePwdCell4"];
        ((CPChangePwdCell2*)cell).delegate = self;
        [((CPChangePwdCell2*)cell).confirmBtn setTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)changePwdCell1TFTextField:(UITextField *)textField{
    if (textField.tag == 10000) {
        _oldPwd = textField.text;
    }
    else if (textField.tag == 10001) {
        _anewPwd = textField.text;
    }
    else if (textField.tag == 10002) {
        _anewConfirmPwd = textField.text;
        
    }
}

- (void)changePwdCell2BtnAction{
    NSString *tips = @"";
    if (!_oldPwd) {
        tips = kLocalizedTableString(@"Enter Old Password", @"CPLocalizable");
    }
    else if (!_anewPwd) {
        tips = kLocalizedTableString(@"Enter New Password", @"CPLocalizable");
    }
    else if (!_anewConfirmPwd) {
        tips = kLocalizedTableString(@"Confirm New Password", @"CPLocalizable");
    }
    else if (_anewPwd && _anewConfirmPwd) {
        if (_anewPwd.length < 8) {
            tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 2", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
        }
        else if (_anewConfirmPwd.length < 8) {
            tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 3", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
        }
        else {
            
            BOOL pwdRegexResult = NO;
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,}$" options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *result1 = [regex firstMatchInString:_anewPwd options:0 range:NSMakeRange(0, [_anewPwd length])];
            if (result1) {
                NSLog(@"_anewPwd true");
                pwdRegexResult = YES;
            }
            else {
                NSLog(@"_anewPwd false");
                pwdRegexResult = NO;
            }
            
            BOOL confirmPwdRegexResult = NO;
            NSTextCheckingResult *result2 = [regex firstMatchInString:_anewConfirmPwd options:0 range:NSMakeRange(0, [_anewConfirmPwd length])];
            if (result2) {
                NSLog(@"_anewConfirmPwd true");
                confirmPwdRegexResult = YES;
            }
            else {
                NSLog(@"_anewConfirmPwd false");
                confirmPwdRegexResult = NO;
            }
            
            if (!pwdRegexResult) {
                tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 2", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
            }
            else if (!confirmPwdRegexResult) {
                tips = [NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"textfield 3", @"CPLocalizable"), kLocalizedTableString(@"Check password", @"CPLocalizable")];
            }
            else if (![_anewPwd isEqualToString:_anewConfirmPwd]) {
                tips = kLocalizedTableString(@"Password Error", @"CPLocalizable");
            }
            
        }
    }
    
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    [self requestChangePassword];
}

- (void)requestChangePassword{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/updatePassword", BaseURL] parameters:@{@"oldPassword":_oldPwd, @"newPassword":_anewConfirmPwd}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPChangeIDVC requestChangeName responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPChangeIDVC requestChangeName 失败");
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
            }
        }
        else {
            NSLog(@"CPChangeIDVC requestChangeName 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPChangeIDVC requestChangeName error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
