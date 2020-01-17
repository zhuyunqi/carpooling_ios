//
//  CPCommentContractDetailVC.m
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPCommentContractDetailVC.h"
#import "CPContractDetailCell1.h"
#import "CPContractDetailCell2.h"
#import "CPContractDetailCell3.h"
#import "CPContractDetailCell4.h"
#import "CPCommentContractDetailCell1.h"

#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

@interface CPCommentContractDetailVC ()<CPContractDetailCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *weekArray;
@property (strong, nonatomic) NSArray *items;
@property (nonatomic) CGFloat cell3CellHeight;
@property (nonatomic) CGFloat cell4CellHeight;
@property (nonatomic) NSUInteger cell5CommentCellHeight;
@end

@implementation CPCommentContractDetailVC

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
    
    self.title = kLocalizedTableString(@"Contract Detail", @"CPLocalizable");
    
    _cell3CellHeight = 200;
    // default height 145
    _cell5CommentCellHeight = 180;
    
    self.weekArray = @[
    kLocalizedTableString(@"SundayLong", @"CPLocalizable"),             kLocalizedTableString(@"MondayLong", @"CPLocalizable"), kLocalizedTableString(@"TuesdayLong", @"CPLocalizable"), kLocalizedTableString(@"WednesdayLong", @"CPLocalizable"), kLocalizedTableString(@"ThursdayLong", @"CPLocalizable"),
    kLocalizedTableString(@"FridayLong", @"CPLocalizable"),
    kLocalizedTableString(@"SaturdayLong", @"CPLocalizable")].mutableCopy;
    
    
    [SVProgressHUD show];
    [self requestContractDetail];
}


- (void)setContractModel:(CPContractMJModel *)contractModel{
    _contractModel = contractModel;
}


#pragma mark - UITableView UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CPREGULARCELLHEIGHT;
    }
    else if (indexPath.section == 1) {
        return 80;
    }
    else if (indexPath.section == 2) {
        return _cell3CellHeight;
    }
    else if (indexPath.section == 3) {
        return _cell4CellHeight;
    }
    else if (indexPath.section == 4) {
        
        return _cell5CommentCellHeight;
    }
    
    return CPREGULARCELLHEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return 10;
    }
    
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] init];
    if (section != 0) {
        view.frame = CGRectMake(0, 0, self.view.frame.size.width, 10);
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return SECTIONHEADERVIEWBACKGROUNDCOLOR;
                }
                else {
                    return [UIColor systemBackgroundColor];
                }
            }];
            
            view.backgroundColor = dyColor;
            
        } else {
            // Fallback on earlier versions
            view.backgroundColor = SECTIONHEADERVIEWBACKGROUNDCOLOR;
        }
    }
    return view;
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
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell1"];
        ((CPContractDetailCell1*)cell).titleLbl.text = kLocalizedTableString(@"Theme", @"CPLocalizable");
        ((CPContractDetailCell1*)cell).subtitleLbl.text = _contractModel.subject;
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell2"];
        ((CPContractDetailCell2*)cell).delegate = self;
        NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
        if ([account isEqualToString:_contractModel.cjUserVo.username]) {
            if (_contractModel.qyUserVo.avatar) {
                [((CPContractDetailCell2*)cell).avatar sd_setImageWithURL:[NSURL URLWithString:_contractModel.qyUserVo.avatar]];
            }
            else{
                ((CPContractDetailCell2*)cell).avatar.image = [UIImage imageNamed:@"messege_no_icon"];
            }
            if (_contractModel.qyUserVo.mobile) {
                ((CPContractDetailCell2*)cell).phoneLbl.text = _contractModel.qyUserVo.mobile;
            }
            if (_contractModel.qyUserVo.username) {
                ((CPContractDetailCell2*)cell).nameLbl.text = _contractModel.qyUserVo.username;
            }
            else if (_contractModel.qyUserVo.nickname) {
                ((CPContractDetailCell2*)cell).nameLbl.text = _contractModel.qyUserVo.nickname;
            }
        }
        else {
            if (_contractModel.cjUserVo.avatar) {
                [((CPContractDetailCell2*)cell).avatar sd_setImageWithURL:[NSURL URLWithString:_contractModel.cjUserVo.avatar]];
            }
            else{
                ((CPContractDetailCell2*)cell).avatar.image = [UIImage imageNamed:@"messege_no_icon"];
            }
            if (_contractModel.cjUserVo.mobile) {
                ((CPContractDetailCell2*)cell).phoneLbl.text = _contractModel.cjUserVo.mobile;
            }
            if (_contractModel.cjUserVo.username) {
                ((CPContractDetailCell2*)cell).nameLbl.text = _contractModel.cjUserVo.username;
            }
            else if (_contractModel.cjUserVo.nickname) {
                ((CPContractDetailCell2*)cell).nameLbl.text = _contractModel.cjUserVo.nickname;
            }
        }
        
    }
    else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell3"];
        ((CPContractDetailCell3*)cell).titleLbl.text = kLocalizedTableString(@"Schedule Time", @"CPLocalizable");
        ((CPContractDetailCell3*)cell).fromMarkLbl.text = kLocalizedTableString(@"Start Address", @"CPLocalizable");
        ((CPContractDetailCell3*)cell).toMarkLbl.text = kLocalizedTableString(@"End Address", @"CPLocalizable");
        ((CPContractDetailCell3*)cell).endDateLbl.text = _contractModel.endDate;
        
        // 合约类型 contractType  0:短期 1:长期
        // 用户类型 userType 0:乘客  1：司机
        if (_contractModel.contractType == 1) {
            NSString *time = @"";
            if (_contractModel.weekNum && _contractModel.weekNum.length > 0) {
                NSString *str = @"";
                NSArray *arr2 = [_contractModel.weekNum componentsSeparatedByString:@","];
                for (int j = 0; j < arr2.count; j++) {
                    NSInteger weeknumI = [[arr2 objectAtIndex:j] integerValue];
                    
                    NSString *weekStr = [_weekArray objectAtIndex:weeknumI-1];
                    if (j == 0) {
                        str = weekStr;
                    }
                    else {
                        str = [NSString stringWithFormat:@"%@,%@", str, weekStr];
                    }
                }
                
                NSLog(@"HorzonItemCell setContractModel str:%@", str);
                
                time = [NSString stringWithFormat:@"%@ %@~%@", str, _contractModel.beginTime, _contractModel.endTime];
                
            }
            else {
                time = [NSString stringWithFormat:@"%@~%@", _contractModel.beginTime, _contractModel.endTime];
            }
            ((CPContractDetailCell3*)cell).timeLbl.text = time;
        }
        else{
            NSString *time = [NSString stringWithFormat:@"%@~%@", _contractModel.beginTime, _contractModel.endTime];
            ((CPContractDetailCell3*)cell).timeLbl.text = time;
        }
        
        if (_contractModel.curUserType == 0) {
            ((CPContractDetailCell3*)cell).driverLbl.text = kLocalizedTableString(@"Impassenger", @"CPLocalizable");
            ((CPContractDetailCell3*)cell).driverIcon.image = [UIImage imageNamed:@"passenger"];
        }
        else if (_contractModel.curUserType == 1) {
            ((CPContractDetailCell3*)cell).driverLbl.text = kLocalizedTableString(@"Imdriver", @"CPLocalizable");
            ((CPContractDetailCell3*)cell).driverIcon.image = [UIImage imageNamed:@"driver"];
        }
        
        if (_contractModel.contractType == 0) {
            ((CPContractDetailCell3*)cell).contractTypeLbl.text = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
        }
        else if (_contractModel.contractType == 1) {
            ((CPContractDetailCell3*)cell).contractTypeLbl.text = kLocalizedTableString(@"Longterm Contract", @"CPLocalizable");
        }
        
        ((CPContractDetailCell3*)cell).fromLbl.text = _contractModel.fromAddressVo.address;
        ((CPContractDetailCell3*)cell).toLbl.text = _contractModel.toAddressVo.address;
        
    }
    else if (indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell4"];
        ((CPContractDetailCell4*)cell).titleLbl.text = kLocalizedTableString(@"Remark Info", @"CPLocalizable");
        ((CPContractDetailCell4*)cell).subtitleLbl.text = _contractModel.remark;
        
    }
    else if (indexPath.section == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPCommentContractDetailCell1"];
        
        // 用户类型 userType 0:乘客  1：司机
        if (_contractModel.contractType == 1) {
            ((CPCommentContractDetailCell1*)cell).mineCommentLbl.text = _contractModel.evaluateRemark;
            ((CPCommentContractDetailCell1*)cell).otherCommentLbl.text = _contractModel.qyEvaluateRemark;
        }
        else{
            ((CPCommentContractDetailCell1*)cell).mineCommentLbl.text = _contractModel.qyEvaluateRemark;
            ((CPCommentContractDetailCell1*)cell).otherCommentLbl.text = _contractModel.evaluateRemark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
}


- (void)contractDetailCell2PhoneAction{
    NSString *mobile = @"";
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, contractModel.cjUserVo.username:%@", account, _contractModel.cjUserVo.username);
    if ([account isEqualToString:_contractModel.cjUserVo.username]) {
        mobile = _contractModel.qyUserVo.mobile;
    }
    else {
        mobile = _contractModel.cjUserVo.mobile;
    }
    
    if (mobile) {
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@", mobile];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}


- (void)requestContractDetail{
    NSMutableDictionary *param = @{
                                   @"contractId":[NSNumber numberWithUnsignedInteger:self.contractModel.dataid]
                                   }.mutableCopy;
    
    NSLog(@"self.contractModel.dataid:%lu", (unsigned long)self.contractModel.dataid);
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/contractDetail", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPCommentContractDetailVC requestContractDetail responseObject:%@", responseObject);
        if (responseObject) {
            NSUInteger state = [[responseObject valueForKey:@"code"] integerValue];
            CPContractMJModel *contractMJModel = [CPContractMJModel mj_objectWithKeyValues:[responseObject valueForKey:@"data"]];
            weakSelf.contractModel = contractMJModel;
            
            if (state == 200) {
                //
                CGSize size1 = W_GET_STRINGSIZE(contractMJModel.fromAddressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height1 =  size1.height;
                
                CGSize size2 = W_GET_STRINGSIZE(contractMJModel.toAddressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height2 = size2.height;
                
                
                // 合约类型 contractType  0:短期 1:长期
                NSString *time = @"";
                if (contractMJModel.contractType == 0) {
                    time = [NSString stringWithFormat:@"%@~%@", weakSelf.contractModel.beginTime, weakSelf.contractModel.endTime];
                }
                else{
                    if (weakSelf.contractModel.weekNum && weakSelf.contractModel.weekNum.length > 0) {
                        NSString *str = @"";
                        NSArray *arr2 = [weakSelf.contractModel.weekNum componentsSeparatedByString:@","];
                        for (int j = 0; j < arr2.count; j++) {
                            NSInteger weeknumI = [[arr2 objectAtIndex:j] integerValue];
                            NSString *weekStr = [weakSelf.weekArray objectAtIndex:weeknumI-1];
                            if (j == 0) {
                                str = weekStr;
                            }
                            else {
                                str = [NSString stringWithFormat:@"%@,%@", str, weekStr];
                            }
                        }
                        
                        NSLog(@"HorzonItemCell setContractModel str:%@", str);
                        
                        time = [NSString stringWithFormat:@"%@ %@~%@", str, weakSelf.contractModel.beginTime, weakSelf.contractModel.endTime];
                        
                    }
                    else {
                        time = [NSString stringWithFormat:@"%@~%@", weakSelf.contractModel.beginTime, weakSelf.contractModel.endTime];
                    }
                }
                
                CGSize size3 = CGSizeMake(0, 0);
                CGFloat height3 = 0;
                if (@available(iOS 8.2, *)) {
                    size3 = W_GET_STRINGSIZE(time, kSCREENWIDTH-30, MAXFLOAT, [UIFont systemFontOfSize:20.f weight:UIFontWeightMedium]);
                    height3 = size3.height;
                } else {
                    // Fallback on earlier versions
                    size3 = W_GET_STRINGSIZE(time, kSCREENWIDTH-30, MAXFLOAT, [UIFont boldSystemFontOfSize:20.f]);
                    height3 = size3.height;
                }
                
                CGFloat totalHeight = height1 +height2 +height3 +120;
                weakSelf.cell3CellHeight = totalHeight;
                NSLog(@"CPCommentContractDetailVC requestContractDetail height1:%f, height2:%f, height3:%f", height1, height2, height3);
                
                CGSize size4 = W_GET_STRINGSIZE(contractMJModel.remark, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height4 = size4.height;
                weakSelf.cell4CellHeight = height4 + 40;
                
                
                CGSize size5 = W_GET_STRINGSIZE(contractMJModel.evaluateRemark, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height5 = size5.height;
                CGSize size6 = W_GET_STRINGSIZE(contractMJModel.qyEvaluateRemark, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height6 = size6.height;
                weakSelf.cell5CommentCellHeight = height5 + height6 + 150;
                
                [self.tableView reloadData];
                
            }
            else{
                NSLog(@"CPCommentContractDetailVC requestContractDetail 失败");
            }
        }
        else {
            NSLog(@"CPCommentContractDetailVC requestContractDetail 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPCommentContractDetailVC requestContractDetail error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
