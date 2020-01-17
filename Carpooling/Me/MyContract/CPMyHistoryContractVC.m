//
//  CPMyHistoryContractVC.m
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyHistoryContractVC.h"
#import "CPMyHistoryContractCell.h"
#import "CPCommentContractDetailVC.h"
#import "CPContractReqResultModel.h"
#import "CPContractReqResultSubModel.h"
#import "CPContractDetailVC.h"
#import "CPCommentContractVC.h"
#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

#import <Realm.h>
#import "CPUserInfoModel.h"
#import "SAMKeychain.h"

#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"

@interface CPMyHistoryContractVC ()<CPMyHistoryContractCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noDataLbl;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSIndexPath *selectIndexPath; // select chat with somebody
@end

@implementation CPMyHistoryContractVC


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

    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kTABBARHEIGHT-40)/2, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    noDataLbl.text = kLocalizedTableString(@"has NO Result", @"CPLocalizable");
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    
    
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
    [SVProgressHUD show];
    [self requestMyHistoryContractByCurrentIndex:_currIndex];
}

- (void)footerLoadMore{
    [self requestMyHistoryContractByCurrentIndex:_currIndex];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    NSLog(@"CPMyHistoryContractVC _dataSource.count:%lu", (unsigned long)_dataSource.count);
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPMyHistoryContractCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMyHistoryContractCell"];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.contractModel = [self.dataSource objectAtIndex:indexPath.section];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPCommentContractDetailVC *commentContractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPCommentContractDetailVC"];
    commentContractDetailVC.contractModel = [self.dataSource objectAtIndex:indexPath.section];
    [[Utils getSupreViewController:self.view].navigationController pushViewController:commentContractDetailVC animated:YES];
}


- (void)requestMyHistoryContractByCurrentIndex:(NSUInteger)index{
    // 合约类型 type  0:短期 1:长期 2:正在进行 3:历史合约
    // 合约状态 status 0:新建状态 1:接受合约，未进行 2:合约取消 3:合约结束(完成) 4:合约进行中 5:合约进行中(仅做为长期合约下车)
    NSMutableDictionary *param = @{
                                   @"type":@3,
                                   @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                   @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                   }.mutableCopy;
    
    NSLog(@"CPMyHistoryContractVC requestMyHistoryContractByCurrentIndex self.currIndex:%lu", self.currIndex);
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/getContractList.json", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyHistoryContractVC requestMyHistoryContractByCurrentIndex responseObject:%@", responseObject);
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
                    
                    CGFloat totalHeight = height1 +height2 +height3 +220;
                    model.cellHeight = totalHeight;
                }
                
                weakSelf.currIndex++;
                if (weakSelf.dataSource.count > 0) {
                    weakSelf.noDataLbl.hidden = YES;
                }
                [weakSelf.tableView reloadData];
            }
            else{
                NSLog(@"CPMyHistoryContractVC requestMyHistoryContractByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPMyHistoryContractVC requestMyHistoryContractByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyHistoryContractVC  requestMyHistoryContractByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)historyContractCellDetailAction:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:indexPath.section];
    contractDetailVC.contractId = contractMJModel.dataid;
    [[Utils getSupreViewController:self.view].navigationController pushViewController:contractDetailVC animated:YES];
}

- (void)historyContractCellChatAction:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    [self requestIfUserIsLogin];
}

- (void)historyContractCellPhoneCallAction:(NSIndexPath *)indexPath{
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

- (void)historyContractCellCommentAction:(NSIndexPath *)indexPath{
    CPContractMJModel *contractMJModel = [self.dataSource objectAtIndex:indexPath.section];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPCommentContractVC *commentContractVC = [storyboard instantiateViewControllerWithIdentifier:@"CPCommentContractVC"];
    commentContractVC.contractId = contractMJModel.dataid;
    commentContractVC.passValueblock = ^(BOOL success) {
        self.currIndex = 1;
        [self requestMyHistoryContractByCurrentIndex:self.currIndex];
    };
    [[Utils getSupreViewController:self.view].navigationController pushViewController:commentContractVC animated:YES];
}


- (void)historyContractCellNaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
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


#pragma mark - 请求用户是否登录
- (void)requestIfUserIsLogin{
    WS(weakSelf)
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/islogin", BaseURL] parameters:nil success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyHistoryContractVC requestIfUserIsLogin responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"CPMyHistoryContractVC requestIfUserIsLogin 拼车号:%@ has login ", account);
                
                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                
                NSLog(@"CPMyHistoryContractVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", savedUserId, [WFCCNetworkService sharedInstance].userId);
                
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
            NSLog(@"CPMyHistoryContractVC requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyHistoryContractVC requestIfUserIsLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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



@end
