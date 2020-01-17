//
//  CPSettingVC.m
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSettingVC.h"
#import "CPSettingCell1.h"
#import "CPSettingCell2.h"
#import "CPUserInfoCell2.h"
#import "CPChangeLanguageVC.h"
#import "CPChangePwdVC.h"

#import <WFChatClient/WFCCNetworkService.h>


@interface CPSettingVC ()<CPSettingCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *currentLanguage;
@property (nonatomic, copy) NSString *systemLanguage;
@end

@implementation CPSettingVC

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
    
    self.title = kLocalizedTableString(@"Setting", @"CPLocalizable");
    
    NSArray *languages = [NSLocale preferredLanguages];
    self.systemLanguage = @"";
    if (languages.count>0) {
        self.systemLanguage = languages.firstObject;
    }
    _currentLanguage = [[BWLocalizableHelper shareInstance] currentLanguage];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kBOTTOMSAFEHEIGHT-2*CPREGULARCELLHEIGHT;
    }
    else {
        return CPREGULARCELLHEIGHT;
    }
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSettingCell1"];
        ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Change Password", @"CPLocalizable");
        
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSettingCell2"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ((CPSettingCell1*)cell).titleLbl.text = kLocalizedTableString(@"System Language", @"CPLocalizable");
        if ([_currentLanguage isEqualToString:self.systemLanguage]) {
            ((CPSettingCell1*)cell).subTitleLbl.text = kLocalizedTableString(@"Follow system language", @"CPLocalizable");
        }
        else if ([_currentLanguage isEqualToString:@"zh-Hans-CN"]) {
            ((CPSettingCell1*)cell).subTitleLbl.text = kLocalizedTableString(@"Follow Chinese", @"CPLocalizable");
        }
        else if ([_currentLanguage isEqualToString:@"en-CN"]) {
            ((CPSettingCell1*)cell).subTitleLbl.text = kLocalizedTableString(@"Follow English", @"CPLocalizable");
        }

    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSettingCell3"];
        ((CPSettingCell2*)cell).delegate = self;
        [((CPSettingCell2*)cell).confirmBtn setTitle:kLocalizedTableString(@"Logout", @"CPLocalizable") forState:UIControlStateNormal];
        
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPChangePwdVC *changePwdVC = [storyboard instantiateViewControllerWithIdentifier:@"CPChangePwdVC"];
        [self.navigationController pushViewController:changePwdVC animated:YES];
        
    }
    else if (indexPath.row == 1) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPChangeLanguageVC *changeLanguageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPChangeLanguageVC"];
        [self.navigationController pushViewController:changeLanguageVC animated:YES];
    }
}

- (void)settingCell2ConfirmAction{
    [self requestLogout];
}

- (void)requestLogout{
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        [SVProgressHUD show];
        [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/logout", BaseURL] parameters:@{}.mutableCopy success:^(id responseObject) {
            [SVProgressHUD dismiss];
            NSLog(@"CPSettingVC requestLogout responseObject:%@", responseObject);
            WS(weakSelf);
            if (responseObject) {
                if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                    
                    [[WFCCNetworkService sharedInstance] disconnect:YES];
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedName"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedToken"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedUserId"];
                    
                    
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserToken];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserLoginAccount];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserAvatar];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserNickname];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserID];
                    if (weakSelf.passValueblock) {
                        weakSelf.passValueblock(YES);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"USERLOGOUTSUCCESS" object:nil];
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }
                else{
                    NSLog(@"CPSettingVC requestLogout 失败");
                }
            }
            else {
                NSLog(@"CPSettingVC requestLogout 失败");
            }
            
            
        } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            NSLog(@"CPSettingVC requestLogout error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
        }];
    }
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
