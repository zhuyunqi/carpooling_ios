//
//  CPActivityMembersVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/3.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPActivityMembersVC.h"
#import "CPActivityMembersCell.h"
#import "CPUserInfoModel.h"
#import "CPActivityMemberReqResultModel.h"
#import "CPActivityMemberReqResultSubModel.h"
#import "SAMKeychain.h"
#import "CPActivityMemberModel.h"
#import "CPUserInfoModel.h"

#import <Realm.h>

#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"


@interface CPActivityMembersVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSIndexPath *selectIndexPath; // select chat with somebody
@end

@implementation CPActivityMembersVC

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
    
    self.title = kLocalizedTableString(@"Members List", @"CPLocalizable");
    [self.tableView registerNib:[UINib nibWithNibName:@"CPMyFriendCell1" bundle:nil] forCellReuseIdentifier:@"CPMyFriendCell1"];
    
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
    [self requestActivityMembersByActivityId:self.activityId andCurrentIndex:_currIndex];
}

- (void)footerLoadMore{
    [self requestActivityMembersByActivityId:self.activityId andCurrentIndex:_currIndex];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
    CPActivityMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPActivityMembersCell"];
    CPActivityMemberModel *activityMemberModel = [self.dataSource objectAtIndex:indexPath.row];
    cell.enrollMember = activityMemberModel.userVo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectIndexPath = indexPath;
    [self requestIfUserIsLogin];
}

- (void)requestActivityMembersByActivityId:(NSUInteger)activityId andCurrentIndex:(NSUInteger)index{
    NSMutableDictionary *param = @{
                                   @"activityId":[NSNumber numberWithUnsignedInteger:activityId],
                                   @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                   @"page":[NSNumber numberWithUnsignedInteger:index],
                                   }.mutableCopy;
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/activity/v1/activityUser", BaseURL] parameters:param success:^(id responseObject) {
        
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyActivityVC requestMyActivityByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPActivityMemberReqResultModel *masterModel = [CPActivityMemberReqResultModel mj_objectWithKeyValues:responseObject];
            CPActivityMemberReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                if (weakSelf.currIndex == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                
                weakSelf.currIndex++;
                [weakSelf.tableView reloadData];
                
            }
            else{
                NSLog(@"CPMyActivityVC requestMyActivityByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPMyActivityVC requestMyActivityByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyActivityVC  requestMyActivityByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


#pragma mark - 请求用户是否登录
- (void)requestIfUserIsLogin{
    WS(weakSelf)
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/islogin", BaseURL] parameters:nil success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyActivityVC requestIfUserIsLogin responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"CPMyActivityVC requestIfUserIsLogin 拼车号:%@ has login ", account);
                
                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                
                NSLog(@"CPMyActivityVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", savedUserId, [WFCCNetworkService sharedInstance].userId);
                
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
                    [weakSelf goChatWithSomebody:weakSelf.selectIndexPath.row];
                }
                
            }
            else{
                // 未登录，用设备id匿名聊天
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserNickname];
                NSLog(@"CPMyActivityVC requestIfUserIsLogin not login");
                
                // im 登录
                NSString *anonymousChatAccount = [SAMKeychain passwordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
                
                [weakSelf anonymousUserGetIMTokenAndUserId:anonymousChatAccount];
            }
            
        }
        else {
            NSLog(@"CPMyActivityVC requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyActivityVC requestIfUserIsLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)anonymousUserGetIMTokenAndUserId:(NSString*)anonymousAccount{
    [SVProgressHUD show];
    NSString *clientId = [[WFCCNetworkService sharedInstance] getClientId];
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/anonymousimlogin", BaseURL] parameters:@{@"phone":anonymousAccount, @"clientId":clientId}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyActivityVC anonymousUserGetIMTokenAndUserId responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSDictionary *dict = [[responseObject valueForKey:@"data"] valueForKey:@"imResult"];
                
                if (nil != dict) {
                    // 匿名im 登录
                    NSString *anonymousUserId = [dict valueForKey:@"userId"];
                    NSString *anonymousToken = [dict valueForKey:@"token"];
                    NSLog(@"CPMyActivityVC anonymousUserGetIMTokenAndUserId anonymousUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", anonymousUserId, [WFCCNetworkService sharedInstance].userId);
                    
                    [[NSUserDefaults standardUserDefaults] setObject:anonymousUserId forKey:kAnonymousUserId];
                    [[NSUserDefaults standardUserDefaults] setObject:anonymousToken forKey:kAnonymousUserToken];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if (![[WFCCNetworkService sharedInstance].userId isEqualToString: anonymousUserId]) {
                        [[WFCCNetworkService sharedInstance] disconnect:YES];
                        [[WFCCNetworkService sharedInstance] connect:anonymousUserId token:anonymousToken];
                        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
                        if (nil != deviceToken){
                            [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
                        }
                        //connect im notification
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMCONNECTEDONOTHERVIEWCONTROLLER" object:nil];
                    }
                    
                    [weakSelf goChatWithSomebody:weakSelf.selectIndexPath.row];
                }
            }
            
        }
        else {
            NSLog(@"CPMyActivityVC anonymousUserGetIMTokenAndUserId 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyActivityVC anonymousUserGetIMTokenAndUserId error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)goChatWithSomebody:(NSInteger)index{
    CPActivityMemberModel *activityMemberModel = [self.dataSource objectAtIndex:index];
    NSString *currentUserAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    // 已登录
    if (currentUserAccount) {
        if (activityMemberModel.isFriend) {
            CPUserInfoModel *model = activityMemberModel.userVo;
            NSLog(@"CPMatchingScheduleVC matchingScheduleCell1BtnAction friend exist, id:%@", model.imUserId);
            
            WFCUMessageListViewController *vc = [[WFCUMessageListViewController alloc] init];
            
            vc.conversation = [WFCCConversation conversationWithType:Single_Type target:model.imUserId line:0];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            NSLog(@"CPMatchingScheduleVC matchingScheduleCell1BtnAction friend isnot exist");
            
            WFCUMessageListViewController *vc = [[WFCUMessageListViewController alloc] init];
            
            vc.conversation = [WFCCConversation conversationWithType:Single_Type target:activityMemberModel.userVo.imUserId line:0];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }
    else{
        // 未登录
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
    }
}

//#pragma mark - 不同的用户, 使用不同的数据库
//- (void)setDefaultRealmForUser:(NSString *)currentUserAccount {
//    //先获取默认配置
//    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
//    
//    //设置只读数据库
//    //config.readOnly = YES;
//    
//    // 使用默认的目录，但是使用用户名来替换默认的文件名
//    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
//                       URLByAppendingPathComponent:currentUserAccount]
//                      URLByAppendingPathExtension:@"realm"];
//    // 将这个配置应用到默认的 Realm 数据库当中
//    [RLMRealmConfiguration setDefaultConfiguration:config];
//}
//
//- (RLMResults*)findIfLocalFriendExistByAccount:(NSString*)account{
//    
//    NSString *currentUserAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
//    // 不同的用户, 使用不同的数据库
//    [self setDefaultRealmForUser:currentUserAccount];
//    
//    NSString *queryStr = [NSString stringWithFormat:@"chatId = '%@'", account];
//    RLMResults *result = [CPUserInfoModel objectsWhere:queryStr];
//    
//    return result;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
