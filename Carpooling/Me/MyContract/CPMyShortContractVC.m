//
//  CPMyShortContractVC.m
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyShortContractVC.h"
#import "CPMyInProgressContractCell1.h"
#import "CPContractDetailVC.h"
#import "CPContractReqResultModel.h"
#import "CPContractReqResultSubModel.h"
#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"
#import "CPRealTimeShareLocationVC.h"
#import "CPAddressModel.h"

#import <Realm.h>
#import "CPUserInfoModel.h"
#import "SAMKeychain.h"

#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"
#import <WFChatClient/WFCChatClient.h>

#import <UserNotifications/UserNotifications.h>


@interface CPMyShortContractVC ()<CPMyInProgressContractCell1Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noDataLbl;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSIndexPath *selectIndexPath; // select chat with somebody
@property (nonatomic, assign) BOOL oneSideHasConfirmArrive;
@end

@implementation CPMyShortContractVC

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
    
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    
    // 合约乘车状态发生变化 合约确认上车或确认到达
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefreshArriveState:) name:@"RIDINGSTATUSCHANGEFROMOTHER" object:nil];
    
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kTABBARHEIGHT-40)/2, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    noDataLbl.text = kLocalizedTableString(@"has NO Result", @"CPLocalizable");
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
    [SVProgressHUD show];
    [self requestMyShortContractByCurrentIndex:_currIndex];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RIDINGSTATUSCHANGEFROMOTHER" object:nil];
}


- (void)needRefreshArriveState:(NSNotification*)notification{
    
    NSDictionary *dict = notification.userInfo;
    NSInteger ridingStatus = [[dict valueForKey:@"ridingstatus"] integerValue];
    if (ridingStatus == 1) {
        self.oneSideHasConfirmArrive = NO;
    }
    else {
        self.oneSideHasConfirmArrive = YES;
    }
    _currIndex = 1;
    [self requestMyShortContractByCurrentIndex:_currIndex];
    NSLog(@"CPMyShortContractVC needRefreshArriveState");
}

- (void)footerLoadMore{
    [self requestMyShortContractByCurrentIndex:_currIndex];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    NSLog(@"CPMyShortContractVC _dataSource.count:%lu", (unsigned long)_dataSource.count);
    return _dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPContractMJModel *contractModel = [self.dataSource objectAtIndex:indexPath.section];
    return contractModel.cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 10)];
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(240, 240, 240, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        
        view.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        view.backgroundColor = RGBA(240, 240, 240, 1);
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPMyInProgressContractCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMyInProgressContractCell1"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.contractModel = [self.dataSource objectAtIndex:indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:indexPath.section];
    contractDetailVC.contractId = contractMJModel.dataid;
    [[Utils getSupreViewController:self.view].navigationController pushViewController:contractDetailVC animated:YES];
}


- (void)requestMyShortContractByCurrentIndex:(NSUInteger)index{
    // 合约类型 type  0:短期 1:长期 2:正在进行 3:历史合约
    // 乘车状态 ridingStatus;// 1：上车 2：下车，到达
    // 合约状态 status 0:新建状态 1:接受合约，未进行 2:合约取消 3:合约结束(完成) 4:合约进行中 5:合约进行中(仅做为长期合约下车)
    NSMutableDictionary *param = @{
                                   @"type":@0,
                                   @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                   @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                   }.mutableCopy;
    
    NSLog(@"CPMyShortContractVC requestMyShortContractByCurrentIndex self.currIndex:%lu", self.currIndex);
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/getContractList.json", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyShortContractVC requestMyShortContractByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPContractReqResultModel *masterModel = [CPContractReqResultModel mj_objectWithKeyValues:responseObject];
            CPContractReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                if (weakSelf.currIndex == 1) {
                    if (subModel.data.count == 0) {
                        weakSelf.noDataLbl.hidden = NO;
                    }
                    [weakSelf.dataSource removeAllObjects];
                }
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                
                for (int i = 0; i < subModel.data.count; i++) {
                    CPContractMJModel *model = [subModel.data objectAtIndex:i];
                    
                    CGSize size1 = W_GET_STRINGSIZE(model.fromAddressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height1 =  size1.height;
                    
                    CGSize size2 = W_GET_STRINGSIZE(model.toAddressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height2 = size2.height;
                    
                    NSString *time = [NSString stringWithFormat:@"%@~%@", model.beginTime, model.endTime];
                    CGSize size3 = W_GET_STRINGSIZE(time, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:14.f]);
                    CGFloat height3 = size3.height;
                    
                    CGFloat totalHeight = height1 +height2 +height3 +260;
                    model.cellHeight = totalHeight;
                }
                
                weakSelf.currIndex++;
                if (weakSelf.dataSource.count > 0) {
                    weakSelf.noDataLbl.hidden = YES;
                }
                [weakSelf.tableView reloadData];
            }
            else{
                NSLog(@"CPMyShortContractVC requestMyShortContractByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPMyShortContractVC requestMyShortContractByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyShortContractVC  requestMyShortContractByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


#pragma mark - CPMyInProgressContractCell1Delegate
- (void)contractCell1CancelAction:(NSIndexPath *)indexPath{
    [self setupAlertViewWithConfirmType:1 andIndex:indexPath.section];
}

- (void)contractCell1OnCarAction:(NSIndexPath *)indexPath{
    [self setupAlertViewWithConfirmType:2 andIndex:indexPath.section];
}

- (void)contractCell1ArriveAction:(NSIndexPath *)indexPath{
    [self setupAlertViewWithConfirmType:3 andIndex:indexPath.section];
}

- (void)contractCell1DetailAction:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
    contractDetailVC.passValueblock = ^(BOOL cancel) {
        self.currIndex = 1;
        [self requestMyShortContractByCurrentIndex:self.currIndex];
    };
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:indexPath.section];
    contractDetailVC.contractId = contractMJModel.dataid;
    [[Utils getSupreViewController:self.view].navigationController pushViewController:contractDetailVC animated:YES];
}

- (void)contractCell1ChatAction:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    [self requestIfUserIsLogin];
}

- (void)contractCell1LocationAction:(NSIndexPath *)indexPath{
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:indexPath.section];
    
    //发送查看对方位置的通知消息
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, contractModel.cjUserVo.username:%@, contractMJModel.qyUserVo.username:%@", account, contractMJModel.cjUserVo.username, contractMJModel.qyUserVo.username);
    NSString *somebody = @"";
    if ([account isEqualToString:contractMJModel.cjUserVo.username]) {
        somebody = contractMJModel.qyUserVo.imUserId;
    }
    else {
        somebody = contractMJModel.cjUserVo.imUserId;
    }
    NSLog(@"requestContractOnCarById somebody:%@", somebody);
    
    
    NSString *myselfUserId = @"";
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    if (savedUserId.length > 0) {
        myselfUserId = savedUserId;
    }
    NSLog(@"requestContractOnCarById myselfUserId:%@", myselfUserId);

    WFCCConversation *conversation = [WFCCConversation conversationWithType:Single_Type target:somebody line:0];
    
    
    WFCCRealtimeLocationNotificationMessageContent *realtimeLocationTipContent = [[WFCCRealtimeLocationNotificationMessageContent alloc] init];
    realtimeLocationTipContent.tip = kLocalizedTableString(@"other want check your location tip", @"CPLocalizable");
    
    realtimeLocationTipContent.othersIMUserId = myselfUserId;
    realtimeLocationTipContent.shareLocationStatus = RealtimeLocation_Start;
    [self sendMessageWithConversation:conversation message:realtimeLocationTipContent];
    
    
    CPRealTimeShareLocationVC *realTimeShareLocationVC = [[CPRealTimeShareLocationVC alloc] init];
    realTimeShareLocationVC.contractMJModel = contractMJModel;
    [[Utils getSupreViewController:self.view].navigationController pushViewController:realTimeShareLocationVC animated:YES];
}

- (void)contractCell1PhoneCallAction:(NSIndexPath *)indexPath{
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:indexPath.section];
    NSString *mobile = @"";
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, contractModel.cjUserVo.username:%@", account, contractMJModel.cjUserVo.username);
    if ([account isEqualToString:contractMJModel.cjUserVo.username]) {
        mobile = contractMJModel.qyUserVo.mobile;
    }
    else {
        mobile = contractMJModel.cjUserVo.mobile;
    }
    
    if (mobile) {
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@", mobile];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}


- (void)contractCell1NaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Navi by map", @"CPLocalizable") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Start Navi", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //当前位置
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
        //传入目的地，会显示在苹果自带地图上面目的地一栏
        toLocation.name = destination;
        //导航方式选择walking
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [[Utils getSupreViewController:self.view].navigationController presentViewController:alert animated:YES completion:nil];
}


#pragma mark - set up UIAlertController
- (void)setupAlertViewWithConfirmType:(NSUInteger)type andIndex:(NSUInteger)index{
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
            CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:index];
            NSComparisonResult result = [self compareNowAndBeginDateByModel:contractMJModel];
            if (result == NSOrderedDescending || result == NSOrderedSame) {
                [self requestContractOnCarById:index];
            }
            else {
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Your schedule hasn't started", @"CPLocalizable")];
            }

        }
        else if (type == 3) {
            [self requestConfirmArriveById:index];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


- (void)requestCancelContractById:(NSUInteger)index{
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:index];
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/cancelContract", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:contractMJModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyShortContractVC requestCancelContractByID responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
                
                // cancel spec notice
                [weakSelf cancelLocalNoticeByModel:contractMJModel];
                
                [weakSelf.dataSource removeObjectAtIndex:index];
                [weakSelf.tableView reloadData];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CANCELCONTRACT" object:nil];
                
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"data"]];
            }
            
        }
        else {
            NSLog(@"CPMyShortContractVC requestCancelContractByID 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyShortContractVC requestCancelContractByID error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)requestContractOnCarById:(NSUInteger)index{
    // 乘车状态 ridingStatus  1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达
    // 合约状态 status 0:新建状态 1:接受合约，未进行 2:合约取消 3:合约结束(完成) 4:合约进行中 5:合约进行中(仅做为长期合约下车)
    NSLog(@"requestContractOnCarById index:%lu", (unsigned long)index);
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:index];
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/confirmOnCar.json", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:contractMJModel.dataid], @"ridingStatus":[NSNumber numberWithInteger:1]}.mutableCopy success:^(id responseObject) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyShortContractVC requestContractOnCarByIndex responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
                contractMJModel.ridingStatus = 1;
                contractMJModel.onCarTimestamp = [Utils getCurrentTimestampMillisecond];
                [weakSelf.tableView reloadSection:index withRowAnimation:UITableViewRowAnimationNone];
                
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
                
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ONCARSUCCESS" object:nil];
                
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"data"]];
            }
        }
        else {
            NSLog(@"CPMyShortContractVC requestContractOnCarByIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyShortContractVC  requestContractOnCarByIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



- (void)requestConfirmArriveById:(NSUInteger)index{
    NSLog(@"requestConfirmArriveById index:%lu", (unsigned long)index);
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:index];
    NSLog(@"CPMyShortContractVC requestConfirmArriveById contractMJModel.ridingStatus:%ld", (long)contractMJModel.ridingStatus);
    
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/confirmArrive", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:contractMJModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyShortContractVC requestConfirmArriveById responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
                NSDictionary *dict = [responseObject valueForKey:@"data"];
                
                //乘车状态  1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达
                NSInteger ridingStatus = [[dict valueForKey:@"ridingStatus"] integerValue];
                contractMJModel.ridingStatus = ridingStatus;
                
                contractMJModel.oneSideHasConfirmArrive = weakSelf.oneSideHasConfirmArrive;
                [weakSelf.tableView reloadSection:index withRowAnimation:UITableViewRowAnimationNone];
                
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
                
                NSLog(@"requestContractOnCarById somebody:%@", somebody);
                WFCCRidingStatusNotificationMessageContent *tipNotificationContent = [[WFCCRidingStatusNotificationMessageContent alloc] init];
                tipNotificationContent.tip = kLocalizedTableString(@"Other Already Arrive", @"CPLocalizable");
                tipNotificationContent.carriageStatus = CarriageStatus_Arrived;
                [weakSelf sendMessageWithConversation:conversation message:tipNotificationContent];
                
                
                // if share location, then ending it
                WFCCRealtimeLocationNotificationMessageContent *realtimeLocationTipContent = [[WFCCRealtimeLocationNotificationMessageContent alloc] init];
                realtimeLocationTipContent.tip = kLocalizedTableString(@"receive Realtime Location End tip", @"CPLocalizable");
                
                NSString *myselfUserId = @"";
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                if (savedUserId.length > 0) {
                    myselfUserId = savedUserId;
                }
                realtimeLocationTipContent.othersIMUserId = myselfUserId;
                realtimeLocationTipContent.shareLocationStatus = RealtimeLocation_End;
                [self sendMessageWithConversation:conversation message:realtimeLocationTipContent];
                
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ARRIVESUCCESS" object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ENDINGSHARINGLOCATIONTOOTHERTIP" object:nil];
                
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"data"]];
            }
        }
        else {
            NSLog(@"CPMyShortContractVC requestConfirmArriveById 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyShortContractVC requestConfirmArriveById error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



#pragma mark - 请求用户是否登录
- (void)requestIfUserIsLogin{
    WS(weakSelf)
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/islogin", BaseURL] parameters:nil success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyShortContractVC requestIfUserIsLogin responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"CPMyShortContractVC requestIfUserIsLogin 拼车号:%@ has login ", account);
                
                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                
                NSLog(@"CPMyShortContractVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", savedUserId, [WFCCNetworkService sharedInstance].userId);
                
                if (savedToken.length > 0 && savedUserId.length > 0) {
                    if (![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]) {
                        [[WFCCNetworkService sharedInstance] disconnect:YES];
                        [[WFCCNetworkService sharedInstance] connect:savedUserId token:savedToken];
                        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
                        if (nil != deviceToken){
                            [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
                        }
                        //connect im notification
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMCONNECTEDONOTHERVIEWCONTROLLER" object:nil];
                    }
                    
                    //
                    [weakSelf goChatWithSomebody:weakSelf.selectIndexPath.section];
                }
                
            }
            else{
                // 未登录，用设备id匿名聊天
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserNickname];
                NSLog(@"CPMyShortContractVC requestIfUserIsLogin not login");
                
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
            }
            
        }
        else {
            NSLog(@"CPMyShortContractVC requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyShortContractVC requestIfUserIsLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)goChatWithSomebody:(NSInteger)index{
    CPContractMJModel *contractModel = [self.dataSource objectAtIndex:index];
    NSString *currentUserAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    
    CPUserInfoModel *otherUserRLMModel = [CPUserInfoModel new];
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:contractModel.targetIMUserId]) {
        otherUserRLMModel.imUserId = contractModel.imUserId;
    }
    else if (![[WFCCNetworkService sharedInstance].userId isEqualToString:contractModel.targetIMUserId]) {
        otherUserRLMModel.imUserId = contractModel.targetIMUserId;
    }
    
    // 已登录
    if (currentUserAccount) {
        if (contractModel.isFriend) {
            CPUserInfoModel *model = otherUserRLMModel;
            NSLog(@"CPMatchingScheduleVC matchingScheduleCell1BtnAction friend exist, id:%@", model.imUserId);
            
            WFCUMessageListViewController *vc = [[WFCUMessageListViewController alloc] init];
            
            vc.conversation = [WFCCConversation conversationWithType:Single_Type target:model.imUserId line:0];
            vc.hidesBottomBarWhenPushed = YES;
            [[Utils getSupreViewController:self.view].navigationController pushViewController:vc animated:YES];
            
        }
        else{
            NSLog(@"CPMatchingScheduleVC matchingScheduleCell1BtnAction friend isnot exist, otherUserRLMModel.imUserId:%@", otherUserRLMModel.imUserId);
            
            WFCUStrangerMessageController *vc = [[WFCUStrangerMessageController alloc] init];
            vc.showMatchingTopHeaderView = NO;
            vc.contractMJModel = contractModel;
            
            vc.conversation = [WFCCConversation conversationWithType:Single_Type target:otherUserRLMModel.imUserId line:0];
            vc.hidesBottomBarWhenPushed = YES;
            [[Utils getSupreViewController:self.view].navigationController pushViewController:vc animated:YES];
        }
        
        
    }
    else{
        // 未登录
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
    }
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
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 0, (long)theNotifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
            
            
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 1, (long)notifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
            
            
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 2, (long)notifyWeekday];
            [self cancelNotificationWithIdentifier:identifier];
            
            
            // 将提醒类型和合约id作为通知的identifier
            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)model.dataid, 3, (long)notifyWeekday];
            
            [self cancelNotificationWithIdentifier:identifier];
        }
    }
}

/**  取消一个特定的通知*/
- (void)cancelNotificationWithIdentifier:(NSString *)identifier{
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
@end
