//
//  CPContractDetailVC.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailVC.h"
#import "CPContractDetailCell1.h"
#import "CPContractDetailCell2.h"
#import "CPContractDetailCell3.h"
#import "CPContractDetailCell4.h"
#import "CPContractDetailCell5.h"
#import "CPContractDetailCell6.h"
#import "CPContractDetailCell5CollectionViewFlowLayout.h"

#import "CPCommentContractVC.h"
#import "CPContractMJModel.h"
#import "CPScheduleMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"
#import <WFChatClient/WFCChatClient.h>

#import <UserNotifications/UserNotifications.h>


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000


#else

#endif


@interface CPContractDetailVC ()<CPContractDetailCell5Delegate, CPContractDetailCell6Delegate, CPContractDetailCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *weekArray;
@property (nonatomic, strong) CPContractMJModel *contractModel;
@property (nonatomic) CGFloat cell3CellHeight;
@property (nonatomic) CGFloat cell4CellHeight;
@property (nonatomic) CGFloat cell5CollectionViewHeight;
@property (nonatomic) NSUInteger cell5CollectionViewTotalRow;
@property (nonatomic) NSUInteger tableSections; // 6 sections

@property (nonatomic, strong) NSArray *noticeTitles; // select notice items
@property (nonatomic, strong) NSMutableArray *noticeTag; //
@property (nonatomic, assign) BOOL hasNotice;
@property (nonatomic, assign) NSUInteger selectLimitCount;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;//current selected notice item
@end

@implementation CPContractDetailVC

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
    
    _noticeTag = @[@"-1", @"-1", @"-1", @"-1"].mutableCopy;
    _hasNotice = NO;
    
    self.weekArray = @[
    kLocalizedTableString(@"SundayLong", @"CPLocalizable"),             kLocalizedTableString(@"MondayLong", @"CPLocalizable"), kLocalizedTableString(@"TuesdayLong", @"CPLocalizable"), kLocalizedTableString(@"WednesdayLong", @"CPLocalizable"), kLocalizedTableString(@"ThursdayLong", @"CPLocalizable"),
    kLocalizedTableString(@"FridayLong", @"CPLocalizable"),
    kLocalizedTableString(@"SaturdayLong", @"CPLocalizable")].mutableCopy;


    self.tableSections = 0;
    _cell3CellHeight = 200;
    // default height 145
    _cell5CollectionViewHeight = 145;
    [self generateItems];
    
    [SVProgressHUD show];
    [self requestContractDetail];
    
    // test
//    [self cancelAllNotification];
}

- (void)generateItems
{
    self.noticeTitles = @[kLocalizedTableString(@"The day before", @"CPLocalizable"),
                   kLocalizedTableString(@"The Same day", @"CPLocalizable"),
                   kLocalizedTableString(@"1 hour in advance", @"CPLocalizable"),
                   kLocalizedTableString(@"10 minutes in advance", @"CPLocalizable")];
    

    _cell5CollectionViewTotalRow = 1;
    NSInteger markWidth = 0;
    for (int i = 0; i < self.noticeTitles.count; ++i) {
        
        //当前attributes
        NSString *currentText = self.noticeTitles[i];
        CGFloat currentWidth = [self calculateCellSize:currentText];
        
        NSString *nextText = @"";
        CGFloat nextWidth = 0;
        if (i == self.noticeTitles.count - 1) {
            // do nothing
        }
        else {
            nextText = self.noticeTitles[i+1];
            nextWidth = [self calculateCellSize:nextText];
        }

        //间距
        NSInteger maximumSpacing = kMinimumLineSpacing;

        markWidth += currentWidth + maximumSpacing;
        NSLog(@"currentText:%@", currentText);
        NSLog(@"currentWidth:%f", currentWidth);
        NSLog(@"nextWidth:%f", nextWidth);
        NSLog(@"markWidth:%ld", (long)markWidth);
        NSLog(@"before row:%ld", (long)_cell5CollectionViewTotalRow);
        
        if (markWidth < kSCREENWIDTH - 20) {
            // do nothing
        }
        else if (markWidth >= kSCREENWIDTH - 20) {
            _cell5CollectionViewTotalRow += 1;
            if (nextWidth != 0) {
                markWidth = currentWidth;
            }
        }
        
        NSLog(@"after row:%ld", (long)_cell5CollectionViewTotalRow);
    }
    
    NSLog(@"after total row:%ld", (long)_cell5CollectionViewTotalRow);
}

//计算cell size
- (CGFloat)calculateCellSize:(NSString *)content {
    //获取文字的宽度
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f]};
    CGSize size = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, kItemHeight) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    size.height = kItemHeight;
    size.width = floorf(size.width+20);
    return size.width;
}



#pragma mark - UITableView UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return self.tableSections;
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
        _cell5CollectionViewHeight = _cell5CollectionViewTotalRow*kItemHeight + (_cell5CollectionViewTotalRow - 1)*kMinimumInteritemSpacing + 55;
        NSLog(@"CPContractDetailVC heightForRowAtIndexPath _cell5CollectionViewHeight:%f", _cell5CollectionViewHeight);
        return _cell5CollectionViewHeight;
    }
    else if (indexPath.section == 5) {
        
        return 100;
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
            else {
                ((CPContractDetailCell2*)cell).phoneLbl.text = @"";
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
            else {
                ((CPContractDetailCell2*)cell).phoneLbl.text = @"";
            }
            
            if (_contractModel.cjUserVo.username) {
                ((CPContractDetailCell2*)cell).nameLbl.text = _contractModel.cjUserVo.username;
            }
            else if (_contractModel.cjUserVo.nickname) {
                ((CPContractDetailCell2*)cell).nameLbl.text = _contractModel.cjUserVo.nickname;
            }
            else {
                ((CPContractDetailCell2*)cell).nameLbl.text = @"";
            }
        }
        
        
    }
    else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell3"];
        ((CPContractDetailCell3*)cell).titleLbl.text = kLocalizedTableString(@"Schedule Time", @"CPLocalizable");
        ((CPContractDetailCell3*)cell).fromMarkLbl.text = kLocalizedTableString(@"Start Address", @"CPLocalizable");
        ((CPContractDetailCell3*)cell).toMarkLbl.text = kLocalizedTableString(@"End Address", @"CPLocalizable");
        
        // 合约类型 contractType  0:短期 1:长期
        // 用户类型 userType 0:乘客  1：司机
        if (_contractModel.contractType == 1) {
            ((CPContractDetailCell3*)cell).endDateLbl.text = [NSString stringWithFormat:@"%@ %@", kLocalizedTableString(@"End at", @"CPLocalizable"), _contractModel.endDate];
            
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
            ((CPContractDetailCell3*)cell).contractTypeLbl.text = kLocalizedTableString(@"Longterm Contract", @"CPLocalizable");
        }
        else{
            ((CPContractDetailCell3*)cell).endDateLbl.text = _contractModel.beginTime;
            
            NSDate *date1 = [Utils stringToDate:_contractModel.beginTime withDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *beginTime = [Utils dateToString:date1 withDateFormat:@"MM/dd EEE HH:mm"];
            NSDate *date2 = [Utils stringToDate:_contractModel.endTime withDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *endTime = [Utils dateToString:date2 withDateFormat:@"MM/dd EEE HH:mm"];
            
            NSString *time = [NSString stringWithFormat:@"%@~%@", beginTime, endTime];
            ((CPContractDetailCell3*)cell).timeLbl.text = time;
            ((CPContractDetailCell3*)cell).contractTypeLbl.text = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
        }
        
        if (_contractModel.curUserType == 0) {
            ((CPContractDetailCell3*)cell).driverLbl.text = kLocalizedTableString(@"Impassenger", @"CPLocalizable");
            ((CPContractDetailCell3*)cell).driverIcon.image = [UIImage imageNamed:@"passenger"];
        }
        else if (_contractModel.curUserType == 1) {
            ((CPContractDetailCell3*)cell).driverLbl.text = kLocalizedTableString(@"Imdriver", @"CPLocalizable");
            ((CPContractDetailCell3*)cell).driverIcon.image = [UIImage imageNamed:@"driver"];
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell5"];
        ((CPContractDetailCell5*)cell).titleLbl.text = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
        ((CPContractDetailCell5*)cell).contractModel = self.contractModel;
        if (self.hasNotice) {
            ((CPContractDetailCell5*)cell).selectLimitCount = self.selectLimitCount;
        }
        ((CPContractDetailCell5*)cell).noticeTag = self.noticeTag;
        ((CPContractDetailCell5*)cell).noticeTitleItems = self.noticeTitles;
        ((CPContractDetailCell5*)cell).delegate = self;

    }
    else if (indexPath.section == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPContractDetailCell6"];
        ((CPContractDetailCell6*)cell).delegate = self;
        if (self.contractModel) {
            ((CPContractDetailCell6*)cell).contractModel = self.contractModel;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
}

#pragma mark - set contract notice action
- (void)collectionViewDidSelectItemAtIndex:(NSIndexPath *)indexPath isSelect:(BOOL)select{
    NSLog(@"collectionViewDidSelectItemAtIndex indexPath.row:%ld, isSelect:%d", (long)indexPath.row, select);
    self.selectedIndexPath = indexPath;
    
    if (select) {
        [_noticeTag replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        
    }
    else {
        [_noticeTag replaceObjectAtIndex:indexPath.row withObject:@"-1"];
    }
    
    NSString *noticeTagStr = @"";
    for (int i = 0; i < _noticeTag.count; i++) {
        NSString *type = [_noticeTag objectAtIndex:i];
        if (i == 0) {
            noticeTagStr = type;
        }
        else {
            noticeTagStr = [NSString stringWithFormat:@"%@,%@", noticeTagStr, type];
        }
    }
    
    NSString *selectedTag = [_noticeTag objectAtIndex:indexPath.row];
    NSLog(@"collectionViewDidSelectItemAtIndex _noticeSelectTag:%@, noticeTagStr:%@, selectedTag:%@", _noticeTag, noticeTagStr, selectedTag);
    
    if (self.contractModel.contractType == 0) {
        // set local notice
        [self setupShortTermNotifications:[selectedTag integerValue] indexPath:self.selectedIndexPath];
    }
    else if (self.contractModel.contractType == 1) {
        // set local notice
        [self setupLongTermNotifications:[selectedTag integerValue] indexPath:self.selectedIndexPath];
    }
    
    // save notice tag to server
    [self requestSaveNoticeByNoticeTag:noticeTagStr];
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


#pragma mark - 获取合约详情
- (void)requestContractDetail{
    NSMutableDictionary *param = @{
                                   @"contractId":[NSNumber numberWithUnsignedInteger:self.contractId]
                                   }.mutableCopy;
    
    NSLog(@"self.contractModel.dataid:%lu", (unsigned long)self.contractModel.dataid);
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/contractDetail", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPContractDetailVC requestContractDetail responseObject:%@", responseObject);
        if (responseObject) {
            NSUInteger state = [[responseObject valueForKey:@"code"] integerValue];
            CPContractMJModel *contractMJModel = [CPContractMJModel mj_objectWithKeyValues:[responseObject valueForKey:@"data"]];
            weakSelf.contractModel = contractMJModel;
            
            if (state == 200) {
                //
                CGSize size1 = W_GET_STRINGSIZE(contractMJModel.fromAddressVo.address, kSCREENWIDTH-70, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height1 =  size1.height;
                
                CGSize size2 = W_GET_STRINGSIZE(contractMJModel.toAddressVo.address, kSCREENWIDTH-70, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
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
                
                CGFloat cell3Height = height1 +height2 +height3 +125;
                weakSelf.cell3CellHeight = cell3Height;
                NSLog(@"CPContractDetailVC requestContractDetail height1:%f, height2:%f, height3:%f", height1, height2, height3);
                
                CGSize size4 = W_GET_STRINGSIZE(contractMJModel.remark, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                CGFloat height4 = size4.height;
                weakSelf.cell4CellHeight = height4 + 40;
                
                
                NSArray *noticetagArr = [weakSelf.contractModel.noticeTag componentsSeparatedByString:@","];
                for (int i = 0; i < noticetagArr.count; i++) {
                    
                }

                if (noticetagArr.count > 0) {
                    for (int i = 0; i < noticetagArr.count; i++) {
                        NSInteger type = [[noticetagArr objectAtIndex:i] integerValue];
                        if (type != -1) {
                            weakSelf.selectLimitCount += 1;
                        }
                    }
                    weakSelf.hasNotice = YES;
                    weakSelf.noticeTag = noticetagArr.mutableCopy;
                }

                weakSelf.tableSections = 6;
                [weakSelf.tableView reloadData];
                
            }
            else{
                NSLog(@"CPContractDetailVC requestContractDetail 失败");
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
            }
        }
        else {
            NSLog(@"CPContractDetailVC requestContractDetail 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPContractDetailVC requestContractDetail error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

#pragma mark - set up UIAlertController
- (void)setupAlertViewWithConfirmType:(NSUInteger)type andIndex:(NSUInteger)index{
    NSLog(@"setupAlertViewWithConfirmType index:%lu", (unsigned long)index);
    NSString *message = @"";
    if (type == 1) {
        message = kLocalizedTableString(@"Cancel this contract", @"CPLocalizable");
    }
    else if (type == 2) {
        message = kLocalizedTableString(@"Confirm passenger on car", @"CPLocalizable");
    }
    else if (type == 3) {
        message = kLocalizedTableString(@"Confirm already arrive", @"CPLocalizable");
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
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
        
        if (type == 1) {
            [self requestCancelContractById:index];
        }
        else if (type == 2) {
            [self requestContractOnCar];
        }
        else if (type == 3) {
            [self requestConfirmArrive];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


- (void)requestContractOnCar{
    // 乘车状态 ridingStatus  1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达
    // 合约状态 status 0:新建状态 1:接受合约，未进行 2:合约取消 3:合约结束(完成) 4:合约进行中 5:合约进行中(仅做为长期合约下车)
    NSLog(@"requestContractOnCarById index:%lu", (unsigned long)index);
    
    CPContractMJModel *contractMJModel = self.contractModel;
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/confirmOnCar.json", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:contractMJModel.dataid], @"ridingStatus":[NSNumber numberWithInteger:1]}.mutableCopy success:^(id responseObject) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyInProgressContractVC requestContractOnCarByIndex responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                contractMJModel.ridingStatus = 1;
                contractMJModel.onCarTimestamp = [Utils getCurrentTimestampMillisecond];
                [weakSelf.tableView reloadSection:5 withRowAnimation:UITableViewRowAnimationNone];
                
                
                //发送合约确认上车的消息
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"account:%@, contractModel.cjUserVo.username:%@, contractMJModel.qyUserVo.username:%@", account, contractMJModel.cjUserVo.username, contractMJModel.qyUserVo.username);
                NSString *somebody = @"";
                if ([account isEqualToString:contractMJModel.cjUserVo.username]) {
                    somebody = contractMJModel.qyUserVo.imUserId;
                }
                else {
                    somebody = contractMJModel.cjUserVo.imUserId;
                }
                
                WFCCConversation *conversation = [WFCCConversation conversationWithType:Single_Type target:somebody line:0];
                
                NSLog(@"requestContractOnCarById somebody:%@", somebody);
                WFCCRidingStatusNotificationMessageContent *tipNotificationContent = [[WFCCRidingStatusNotificationMessageContent alloc] init];
                tipNotificationContent.tip = kLocalizedTableString(@"Already On Car", @"CPLocalizable");
                tipNotificationContent.carriageStatus = CarriageStatus_OnCar;
                [weakSelf sendMessageWithConversation:conversation message:tipNotificationContent];
                
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"data"]];
            }
        }
        else {
            NSLog(@"CPMyInProgressContractVC requestContractOnCarByIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyInProgressContractVC  requestContractOnCarByIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



- (void)requestConfirmArrive{
    NSLog(@"requestConfirmArriveById index:%lu", (unsigned long)index);
    CPContractMJModel *contractMJModel = self.contractModel;
    NSLog(@"CPMyInProgressContractVC requestConfirmArriveById contractMJModel.ridingStatus:%ld", (long)contractMJModel.ridingStatus);
    
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/confirmArrive", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:contractMJModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyInProgressContractVC requestConfirmArriveById responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
                NSDictionary *dict = [responseObject valueForKey:@"data"];
                //ridingStatus 乘车状态  1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达
                NSInteger ridingStatus = [[dict valueForKey:@"ridingStatus"] integerValue];
                contractMJModel.ridingStatus = ridingStatus;
                contractMJModel.oneSideHasConfirmArrive = YES;
                [weakSelf.tableView reloadSection:5 withRowAnimation:UITableViewRowAnimationNone];
                
                //
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                //发送合约确认到达的消息
                NSLog(@"account:%@, contractModel.cjUserVo.username:%@, contractMJModel.qyUserVo.username:%@", account, contractMJModel.cjUserVo.username, contractMJModel.qyUserVo.username);
                NSString *somebody = @"";
                if ([account isEqualToString:contractMJModel.cjUserVo.username]) {
                    somebody = contractMJModel.qyUserVo.imUserId;
                }
                else {
                    somebody = contractMJModel.cjUserVo.imUserId;
                }
                
                NSLog(@"requestConfirmArriveById somebody:%@", somebody);
                
                WFCCConversation *conversation = [WFCCConversation conversationWithType:Single_Type target:somebody line:0];
                
                WFCCRidingStatusNotificationMessageContent *tipNotificationContent = [[WFCCRidingStatusNotificationMessageContent alloc] init];
                tipNotificationContent.tip = kLocalizedTableString(@"Other Already Arrive", @"CPLocalizable");
                tipNotificationContent.carriageStatus = CarriageStatus_Arrived;
                [weakSelf sendMessageWithConversation:conversation message:tipNotificationContent];
                
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"data"]];
            }
        }
        else {
            NSLog(@"CPMyInProgressContractVC requestConfirmArriveById 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyInProgressContractVC requestConfirmArriveById error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



// 取消合约
- (void)contractDetailCell6CancelBtnAction{
    [self requestCancelContractById:_contractModel.dataid];
}

- (void)contractDetailCell6OnCarBtnAction{
    NSComparisonResult result = [self compareNowAndBeginDateByModel:self.contractModel];
    if (result == NSOrderedDescending || result == NSOrderedSame) {
        [self requestContractOnCar];
    }
    else {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Your schedule hasn't started", @"CPLocalizable")];
    }
}

#pragma mark - compareNowAndBeginDateByModel
// !!!: compareNowAndBeginDateByModel
- (NSComparisonResult)compareNowAndBeginDateByModel:(CPContractMJModel*)model{
    NSComparisonResult result;
    
    if (model.contractType == 0) {
        NSDate *date = [NSDate date];
        
        NSDate *beginDate = [Utils stringToDate:model.beginTime withDateFormat:@"yyyy-MM-dd HH:mm"];
        
        return result = [date compare:beginDate];
        
        
    }
    else {
        NSComparisonResult result = -3;
        //
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDate *today = [NSDate date];
        NSDateComponents *dateComps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                                   fromDate:today];
        NSInteger todayWeekDay = [dateComps2 weekday];
        
        
        NSArray *weekNumArr = [model.weekNum componentsSeparatedByString:@","];
        for (int i = 0; i < weekNumArr.count; i++) {
            NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
            
            if (todayWeekDay == notifyWeekday) {
                
                NSString *theDayStr = [Utils dateToString:today withDateFormat:@"yyyy-MM-dd"];
                NSDate *theDate = [Utils stringToDate:[NSString stringWithFormat:@"%@ %@", theDayStr, model.beginTime] withDateFormat:@"yyyy-MM-dd HH:mm"];
                
                result = [today compare:theDate];
                
                break;
            }
        }
        
        return result;
    }
}


- (void)contractDetailCell6ArriveBtnAction{
    [self requestConfirmArrive];
}

- (void)requestCancelContractById:(NSUInteger)index{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/cancelContract", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:_contractModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPContractDetailVC requestCancelContractByID responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
                
                // cancel spec notice
                [weakSelf cancelLocalNoticeByModel:weakSelf.contractModel];
                
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CANCELCONTRACT" object:nil];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"data"]];
            }
            
        }
        else {
            NSLog(@"CPContractDetailVC requestCancelContractByID 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPContractDetailVC requestCancelContractByID error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

#pragma mark - send message
- (void)sendMessageWithConversation:(WFCCConversation*)conversation message:(WFCCMessageContent *)content {
    //发送消息时，client会发出"kSendingMessageStatusUpdated“的通知，消息界面收到通知后加入到列表中。
    [[WFCCIMService sharedWFCIMService] send:conversation content:content expireDuration:0 success:^(long long messageUid, long long timestamp) {
        NSLog(@"send message success");
    } error:^(int error_code) {
        NSLog(@"send message fail(%d)", error_code);
    }];
}


- (void)requestSaveNoticeByNoticeTag:(NSString*)noticeTag{
    [SVProgressHUD show];
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/contractWarn", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:self.contractId], @"noticeTag":noticeTag}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPContractDetailVC requestSaveNoticeTime responseObject:%@", responseObject);
        if (responseObject) {
            // cancel notice after network success
#warning cancel notice after network success, not use now, you can use them if u want
//            NSString *selectedTagStr = [weakSelf.noticeTag objectAtIndex:weakSelf.selectedIndexPath.row];
//            NSInteger selectedTag = [selectedTagStr integerValue];
//            if (selectedTag == -1) {
//                NSString *identifier = @"";
//                if (weakSelf.contractModel.contractType == 0) {
//                    // 将提醒类型和合约id作为通知的identifier
//                    identifier = [NSString stringWithFormat:@"%lu-%ld", (unsigned long)weakSelf.contractModel.dataid, (long)weakSelf.selectedIndexPath.row];
//
//                }
//                else if (weakSelf.contractModel.contractType == 1) {
//                    NSArray *weekNumArr = [weakSelf.contractModel.weekNum componentsSeparatedByString:@","];
//                    for (int i = 0; i < weekNumArr.count; i++) {
//                        NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
//
//                        NSInteger theNotifyWeekday = notifyWeekday;
//                        theNotifyWeekday -= 1;
//                        if (theNotifyWeekday == 0) {
//                            theNotifyWeekday = 7;
//                        }
//
//
//                        if (weakSelf.selectedIndexPath.row == 0) {
//                            identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)weakSelf.contractModel.dataid, (long)weakSelf.selectedIndexPath.row, theNotifyWeekday];
//                        }
//                        else if (weakSelf.selectedIndexPath.row == 1) {
//                            identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)weakSelf.contractModel.dataid, (long)weakSelf.selectedIndexPath.row, notifyWeekday];
//                        }
//                        else if (weakSelf.selectedIndexPath.row == 2) {
//                            identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)weakSelf.contractModel.dataid, (long)weakSelf.selectedIndexPath.row, notifyWeekday];
//                        }
//                        else if (weakSelf.selectedIndexPath.row == 3) {
//                            identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)weakSelf.contractModel.dataid, (long)weakSelf.selectedIndexPath.row, notifyWeekday];
//                        }
//                    }
//                }
//
//                [self cancelNotificationWithIdentifier:identifier];
//            }
            
            [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
            
        }
        else {
            NSLog(@"CPContractDetailVC requestSaveNoticeTime 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPContractDetailVC requestSaveNoticeTime error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



#pragma mark - set up notice method
static NSNotificationName const _Nullable kCheckinNotification = @"CheckinNotification";
static NSString *const _Nullable kCheckinNotificationSwitchKey  = @"kCheckinNotificationSwitchKey";

/**  设置通知*/  // -1,未选择， 0前一天，  1当天， 2提前1小时， 3提前10分钟,
- (void)setupLongTermNotifications:(NSInteger)noticeType indexPath:(NSIndexPath*)indexPath{
    // 用户首次使用 默认开启通知（相当于NSUserDefaults）
//    if ([NSUtil getValueForKey:kCheckinNotificationSwitchKey] == nil) {
//        [NSUtil saveValue:@(YES) forKey:kCheckinNotificationSwitchKey];
//    }
    
    // 如果用户关闭通知，直接返回
//    if([[NSUtil getValueForKey:kCheckinNotificationSwitchKey] isEqual: @(NO)]) return;
    
//    // 取消以前的通知
//    [self cancelAllNotification];
    
    NSString *todayStr = [Utils dateToString:[NSDate date] withDateFormat:@"yyyy-MM-dd"];
    NSDate *beginDate = [Utils stringToDate:[NSString stringWithFormat:@"%@ %@", todayStr, self.contractModel.beginTime] withDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                              fromDate:beginDate];
    NSInteger hour = [dateComps hour];
    NSInteger minute = [dateComps minute];
    
    NSDate *today = [NSDate date];
    NSDateComponents *dateComps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                              fromDate:today];
    NSInteger todayWeekDay = [dateComps2 weekday];
    
    NSString *identifier = @"";
    
    NSArray *weekNumArr = [self.contractModel.weekNum componentsSeparatedByString:@","];
    for (int i = 0; i < weekNumArr.count; i++) {
        NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
        if (indexPath.row == 0) {// 提前一天
            if (noticeType == 0) {
                NSInteger theNotifyWeekday = notifyWeekday;
                theNotifyWeekday -= 1;
                
                if (theNotifyWeekday == 0) {
                    theNotifyWeekday = 7;
                }
                //            if(theNotifyWeekday == 7 || theNotifyWeekday == 1) continue;
                
                // 将提醒类型和合约id作为通知的identifier
                identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType, (long)theNotifyWeekday];
                
                if (@available(iOS 10.0, *)) {
                    UNNotificationRequest *request = [self createNotificationRequestWithWeekday:theNotifyWeekday identifier:identifier hour:hour minute:minute noticeType:noticeType contractId:self.contractModel.dataid];
                    // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                }
                else{
                    NSInteger diff = labs(theNotifyWeekday - todayWeekDay);
                    //
                    NSDate *theDate = [today dateByAddingTimeInterval:-diff*60*60*24];
                    UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
                
            }
            else {
                [self cancelNotificationWithIdentifier:identifier];
            }
            
        }
        else if (indexPath.row == 1) {// 当天
            if (noticeType == 1) {
                // 将提醒类型和合约id作为通知的identifier
                identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType, (long)notifyWeekday];
                
                NSInteger theNotifyWeekday = notifyWeekday;
                if (@available(iOS 10.0, *)) {
                    // 当天。默认提前3小时。
                    NSInteger theHour = hour;
                    NSInteger theMinute = minute;
                    
                    if (theHour >= 3) {
                        theHour -= 3;
                    }
                    else{
                        theHour = 24-(3-theHour);
                        theNotifyWeekday -= 1;
                    }
                    
                    UNNotificationRequest *request = [self createNotificationRequestWithWeekday:theNotifyWeekday identifier:identifier hour:theHour minute:theMinute noticeType:noticeType contractId:self.contractModel.dataid];
                    // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                }
                else{
                    NSInteger diff = labs(theNotifyWeekday - todayWeekDay);
                    // 当天。默认提前3小时提醒
                    NSDate *theDate = [today dateByAddingTimeInterval:-diff*60*60*24 - 60*60*3];
                    UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
                
            }
            else {
                [self cancelNotificationWithIdentifier:identifier];
            }
        
        }
        else if (indexPath.row == 2) {// 提前1小时
            if (noticeType == 2) {
                // 将提醒类型和合约id作为通知的identifier
                identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType, (long)notifyWeekday];
                
                NSInteger theNotifyWeekday = notifyWeekday;
                if (@available(iOS 10.0, *)) {
                    NSInteger theHour = hour;
                    NSInteger theMinute = minute;
                    
                    // 提前1小时提醒
                    if (theHour >= 1) {
                        theHour -= 1;
                    }
                    else{
                        theHour = 23;
                        theNotifyWeekday -= 1;
                    }
                    
                    UNNotificationRequest *request = [self createNotificationRequestWithWeekday:theNotifyWeekday identifier:identifier hour:theHour minute:theMinute noticeType:noticeType contractId:self.contractModel.dataid];
                    // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                }
                else{
                    NSInteger diff = labs(theNotifyWeekday - todayWeekDay);
                    // 提前1小时提醒
                    NSDate *theDate = [today dateByAddingTimeInterval:-diff*60*60*24 - 60*60*1];
                    UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
                
            }
            else {
                [self cancelNotificationWithIdentifier:identifier];
            }
            
        }
        else if (indexPath.row == 3) {// 提前10分钟
            if (noticeType == 3) {
                // 将提醒类型和合约id作为通知的identifier
                identifier = [NSString stringWithFormat:@"%lu-%ld-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType, (long)notifyWeekday];
                
                NSInteger theNotifyWeekday = notifyWeekday;
                if (@available(iOS 10.0, *)) {
                    NSInteger theHour = hour;
                    NSInteger theMinute = minute;
                    
                    // 提前10分钟
                    if (theMinute >= 10) {
                        theMinute -= 10;
                    }
                    else {
                        theMinute = 60-(10-theMinute);
                        if (theHour >= 1) {
                            theHour -= 1;
                        }
                        else{
                            theHour = 23;
                            theNotifyWeekday -= 1;
                        }
                    }
                    UNNotificationRequest *request = [self createNotificationRequestWithWeekday:theNotifyWeekday identifier:identifier hour:theHour minute:theMinute noticeType:noticeType contractId:self.contractModel.dataid];
                    // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                }
                else{
                    NSInteger diff = labs(theNotifyWeekday - todayWeekDay);
                    // 提前10分钟提醒
                    NSDate *theDate = [today dateByAddingTimeInterval:-diff*60*60*24 - 60*10];
                    UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
                
            }
            else {
                [self cancelNotificationWithIdentifier:identifier];
            }
        }
    }
}


/**  设置通知*/  // -1未选择，0前一天，1当天，2提前1小时，3提前10分钟
- (void)setupShortTermNotifications:(NSInteger)noticeType indexPath:(NSIndexPath*)indexPath{
    // 用户首次使用 默认开启通知（相当于NSUserDefaults）
    //    if ([NSUtil getValueForKey:kCheckinNotificationSwitchKey] == nil) {
    //        [NSUtil saveValue:@(YES) forKey:kCheckinNotificationSwitchKey];
    //    }

    // 如果用户关闭通知，直接返回
    //    if([[NSUtil getValueForKey:kCheckinNotificationSwitchKey] isEqual: @(NO)]) return;

    //    // 取消以前的通知
    //    [self cancelAllNotification];

    NSDate *beginDate = [Utils stringToDate:self.contractModel.beginTime withDateFormat:@"yyyy-MM-dd HH:mm"];

    NSString *identifier = @"";
    
    if (indexPath.row == 0) {// 提前一天
        if (noticeType == 0) {
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType];
            //
            NSDate *theDate = [beginDate dateByAddingTimeInterval:-60*60*24];
            
            if (@available(iOS 10.0, *)) {
                UNNotificationRequest *request = [self createNotificationRequestWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else{
                
                UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
            
        }
        else {
            [self cancelNotificationWithIdentifier:identifier];
        }
        
    }
    else if (indexPath.row == 1) { // 当天
        if (noticeType == 1) {
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType];
            // 当天。默认提前3小时提醒
            NSDate *theDate = [beginDate dateByAddingTimeInterval:-60*60*3];
            
            if (@available(iOS 10.0, *)) {
                // 当天。默认提前3小时提醒
                UNNotificationRequest *request = [self createNotificationRequestWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else{
                
                UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
            
        }
        else {
            [self cancelNotificationWithIdentifier:identifier];
        }
        
    }
    else if (indexPath.row == 2) { // 提前1小时
        if (noticeType == 2) {
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType];
            // 提前1小时提醒
            NSDate *theDate = [beginDate dateByAddingTimeInterval:-60*60*1];
            if (@available(iOS 10.0, *)) {
                // 提前1小时提醒
                UNNotificationRequest *request = [self createNotificationRequestWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else{
                UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
            
        }
        else {
            [self cancelNotificationWithIdentifier:identifier];
        }
        
    }
    else if (indexPath.row == 3) { // 提前10分钟
        if (noticeType == 3) {
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%ld", (unsigned long)self.contractModel.dataid, (long)noticeType];
            // 提前10分钟提醒
            NSDate *theDate = [beginDate dateByAddingTimeInterval:-60*10];
            if (@available(iOS 10.0, *)) {
                UNNotificationRequest *request = [self createNotificationRequestWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else{
                UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier noticeType:noticeType contractId:self.contractModel.dataid];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
            
        }
        else {
            [self cancelNotificationWithIdentifier:identifier];
        }
    }
}


#pragma mark   -  createLocalNotificationWithDate
#pragma mark - only on iOS 10 or newer
/**  long term   每个星期的星期几提醒*/
- (UNNotificationRequest *)createNotificationRequestWithWeekday:(NSInteger)weekday identifier:(NSString *)identifier hour:(NSInteger)hour minute:(NSInteger)minute noticeType:(NSInteger)noticeType contractId:(NSInteger)contractId{
    NSLog(@"CPContractDetailVC createNotificationRequestWithWeekday identifier:%@", identifier);
    
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.title = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
    if (noticeType == 0) {
        content.body = kLocalizedTableString(@"start in 24 hours", @"CPLocalizable");
    }
    else if (noticeType == 1) {
        content.body = kLocalizedTableString(@"start in 3 hours", @"CPLocalizable");
    }
    else if (noticeType == 2) {
        content.body = kLocalizedTableString(@"start in 1 hours", @"CPLocalizable");
    }
    else if (noticeType == 3) {
        content.body = kLocalizedTableString(@"start in 10 minutes", @"CPLocalizable");
    }
    
    //content.badge = @(++kApplication.applicationIconBadgeNumber); // 不显示角标
    content.userInfo = @{@"kLocalNotificationID":kCheckinNotification, @"identifier":identifier, @"contractId":[NSNumber numberWithInteger:contractId]};
    
    // 2.触发模式 触发时间 每周重复 ()
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.hour = hour;
    dateComponents.minute = minute;
    dateComponents.weekday = weekday;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
    
    // 4.设置UNNotificationRequest
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    return request;
}


/**  short term 提醒*/
- (UNNotificationRequest *)createNotificationRequestWithDate:(NSDate*)date identifier:(NSString *)identifier noticeType:(NSInteger)noticeType contractId:(NSInteger)contractId{
    NSLog(@"CPContractDetailVC createNotificationRequestWithDate identifier:%@", identifier);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                              fromDate:date];
    
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.title = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
    if (noticeType == 0) {
        content.body = kLocalizedTableString(@"start in 24 hours", @"CPLocalizable");
    }
    else if (noticeType == 1) {
        content.body = kLocalizedTableString(@"start in 3 hours", @"CPLocalizable");
    }
    else if (noticeType == 2) {
        content.body = kLocalizedTableString(@"start in 1 hours", @"CPLocalizable");
    }
    else if (noticeType == 3) {
        content.body = kLocalizedTableString(@"start in 10 minutes", @"CPLocalizable");
    }
    
    //content.badge = @(++kApplication.applicationIconBadgeNumber); // 不显示角标
    content.userInfo = @{@"kLocalNotificationID":kCheckinNotification, @"identifier":identifier, @"contractId":[NSNumber numberWithInteger:contractId]};
    
    // 2.触发模式 触发时间
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = dateComps.year;
    dateComponents.month = dateComps.month;
    dateComponents.day = dateComps.day;
    dateComponents.hour = dateComps.hour;
    dateComponents.minute = dateComps.minute;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
    
    // 4.设置UNNotificationRequest
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    return request;
}


#pragma mark - blow iOS 10
/**  设置指定时间通知，每周重复 blow iOS 10 */
- (UILocalNotification *)createLocalNotificationWithDate:(NSDate *)date identifier:(NSString *)identifier noticeType:(NSInteger)noticeType contractId:(NSInteger)contractId{
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // 1.设置触发时间（如果要立即触发，无需设置）
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = date;
    localNotification.repeatInterval = NSCalendarUnitWeekday;
    
    // 2.设置通知标题
    localNotification.alertBody = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
    if (noticeType == 0) {
        localNotification.alertAction = kLocalizedTableString(@"start in 24 hours", @"CPLocalizable");
    }
    else if (noticeType == 1) {
        localNotification.alertAction = kLocalizedTableString(@"start in 3 hours", @"CPLocalizable");
    }
    else if (noticeType == 2) {
        localNotification.alertAction = kLocalizedTableString(@"start in 1 hours", @"CPLocalizable");
    }
    else if (noticeType == 3) {
        localNotification.alertAction = kLocalizedTableString(@"start in 10 minutes", @"CPLocalizable");
    }
    // localNotification.applicationIconBadgeNumber = ++kApplication.applicationIconBadgeNumber;
    
    // 3.设置通知的 传递的userInfo
    localNotification.userInfo = @{@"kLocalNotificationID":kCheckinNotification, @"identifier":identifier, @"contractId":[NSNumber numberWithInteger:contractId]};
    
    return localNotification;
}


#pragma mark - cancel notice
- (void)cancelLocalNoticeByModel:(CPContractMJModel*)model{
    if (model.contractType == 0) {
        NSString *identifier = @"";
        
        // 将提醒类型和合约id作为通知的identifier
        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)model.dataid, 0];
        [self cancelNotificationWithIdentifier:identifier];
        
        
        // 将提醒类型和合约id作为通知的identifier
        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)model.dataid, 1];
        [self cancelNotificationWithIdentifier:identifier];
        
        // 将提醒类型和合约id作为通知的identifier
        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)model.dataid, 2];
        [self cancelNotificationWithIdentifier:identifier];
        
        // 将提醒类型和合约id作为通知的identifier
        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)model.dataid, 3];
        [self cancelNotificationWithIdentifier:identifier];
        
        
    }
    else if (model.contractType == 1) {
        NSString *identifier = @"";
        
        NSArray *weekNumArr = [model.weekNum componentsSeparatedByString:@","];
        for (int i = 0; i < weekNumArr.count; i++) {
            NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
            
            NSInteger theNotifyWeekday = notifyWeekday;
            theNotifyWeekday -= 1;
            if (theNotifyWeekday == 0) {
                theNotifyWeekday = 7;
            }
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 0, theNotifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
            
            
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 1, notifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
            
            
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 2, notifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
            
            
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 3, notifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
        }
    }
}

/**  取消一个特定的通知*/
- (void)cancelNotificationWithIdentifier:(NSString *)identifier{
    NSLog(@"CPContractDetailVC cancelNotificationWithIdentifier identifier:%@", identifier);
    
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
    }
    else{
        
        // 获取当前所有的本地通知
        NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
        if (!notificaitons || notificaitons.count <= 0) { return; }
        for (UILocalNotification *notify in notificaitons) {
            if ([[notify.userInfo objectForKey:@"identifier"] isEqualToString:identifier]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
                break;
            }
        }
    }
}

- (void)cancelAllNotification{
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    }
    else{
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

/**  取消已经推过的通知*/
- (void)removeAllDeliveredNotifications __IOS_AVAILABLE(10.0){
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
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
