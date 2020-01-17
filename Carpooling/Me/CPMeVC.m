//
//  CPMeVC.m
//  Carpooling
//
//  Created by bw on 2019/5/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMeVC.h"
#import "CPMeHeaderCell.h"
#import "CPMeCell1.h"
#import "CPUserInfoVC.h"
#import "CPSettingVC.h"
#import "CPMyContractPageVC.h"
#import "CPMyFriendVC.h"
#import "CPMyScheduleVC.h"
#import "CPMyActivityVC.h"
#import "CPMyAddressPageVC.h"
#import "CPUserRegister1VC.h"
#import "CPUserLoginVC.h"
#import "CPNoticeMessagePageVC.h"
#import "SAMKeychain.h"
#import "CPUserInfoModel.h"
#import "CPChangeIDVC.h"
#import "CPCustomActivity.h"
#import "VHLNavigation.h"

// test
#import "TestMapkitResultVC.h"

@interface CPMeVC ()<CPMeHeaderCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) CPUserInfoModel *user;
@end


@implementation CPMeVC

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
            
            UIColor *dyColor3 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor whiteColor];
                }
                else {
                    return [UIColor secondarySystemBackgroundColor];
                }
            }];
            self.view.backgroundColor = dyColor3;
            
        } else {
            // Fallback on earlier versions
            self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
        }
    
    
    
    [self vhl_setNavBarShadowImageHidden:YES];
    
    self.title = kLocalizedTableString(@"Me", @"CPLocalizable");
    [self initRightBarItem];
    [self initLeftBarItem];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -2000, kSCREENWIDTH, 2000)];
    bgView.backgroundColor = RGBA(120, 202, 195, 1);
    [self.tableView addSubview:bgView];
    
    
    _icons = @[@"me_contract", @"me_schedule", @"me_friend", @"me_address", @"me_activity", @"me_share", @"me_Test",];
    _titles = @[kLocalizedTableString(@"My Contract", @"CPLocalizable"),
                kLocalizedTableString(@"My Schedule", @"CPLocalizable"),
                kLocalizedTableString(@"My Friend", @"CPLocalizable"),
                kLocalizedTableString(@"My Address", @"CPLocalizable"),
                kLocalizedTableString(@"My Activity", @"CPLocalizable"),
                kLocalizedTableString(@"My Share", @"CPLocalizable"),
                @"me_Test Mapkit"
                ];
    
    
    //注册并登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupAndLoginSuccess:) name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
}

- (void)userSignupAndLoginSuccess:(NSNotification*)notification{
    [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self requestUserInfo];
}


- (void)initLeftBarItem{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"set"] style:UIBarButtonItemStyleDone target:self action:@selector(leftItemClick:)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)leftItemClick:(id)sender{
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPSettingVC *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSettingVC"];
        settingVC.passValueblock = ^(BOOL logout) {
            if (logout) {
                [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        [self.navigationController pushViewController:settingVC animated:YES];
        
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
        userLoginVC.passValueblock = ^(BOOL login) {
            if (login) {
                [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        [self.navigationController pushViewController:userLoginVC animated:YES];
    }
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"news"] style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)rightItemClick:(id)sender{
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPNoticeMessagePageVC *noticeMessagePageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPNoticeMessagePageVC"];
        [self.navigationController pushViewController:noticeMessagePageVC animated:YES];
        
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
        userLoginVC.passValueblock = ^(BOOL login) {
            if (login) {
                [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        [self.navigationController pushViewController:userLoginVC animated:YES];
    }
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 200;
    }
    return 50;
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeHeaderCell"];
        cell.separatorInset = UIEdgeInsetsMake(0, kSCREENWIDTH, 0, 0);
        ((CPMeHeaderCell*)cell).delegate = self;
        if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
            [((CPMeHeaderCell*)cell).avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
            if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserNickname]) {
                ((CPMeHeaderCell*)cell).nameLbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:kUserNickname];
            }
            else {
                ((CPMeHeaderCell*)cell).nameLbl.text = @"";
            }
            
            if (_user.creditScore >= 0) {
                ((CPMeHeaderCell*)cell).scoreLbl.hidden = NO;
                ((CPMeHeaderCell*)cell).scoreLbl.text = [NSString stringWithFormat:@"%@ %ld", kLocalizedTableString(@"Score", @"CPLocalizable"), (long)_user.creditScore];
            }
            
            ((CPMeHeaderCell*)cell).accountLbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
            ((CPMeHeaderCell*)cell).accountLbl.hidden = NO;
            ((CPMeHeaderCell*)cell).editBtn.hidden = NO;
            ((CPMeHeaderCell*)cell).editIcon.hidden = NO;
            ((CPMeHeaderCell*)cell).signInBtn.hidden = YES;
            
        }
        else{
            ((CPMeHeaderCell*)cell).avatar.image  = [UIImage imageNamed:@"messege_no_icon"];
            NSString *anonymousChatAccount = [SAMKeychain passwordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
            if (nil != anonymousChatAccount) {
                ((CPMeHeaderCell*)cell).nameLbl.text = [NSString stringWithFormat:@"stranger%@", [anonymousChatAccount substringToIndex:6]];
            }
            
            ((CPMeHeaderCell*)cell).scoreLbl.hidden = YES;
            ((CPMeHeaderCell*)cell).accountLbl.text = @"";
            ((CPMeHeaderCell*)cell).accountLbl.hidden = YES;
            ((CPMeHeaderCell*)cell).editBtn.hidden = YES;
            ((CPMeHeaderCell*)cell).editIcon.hidden = YES;
            ((CPMeHeaderCell*)cell).signInBtn.hidden = NO;
        }
        
    }
    else{
        if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell1"];
        }
        else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell2"];
        }
        else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell3"];
        }
        else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell4"];
        }
        else if (indexPath.row == 5) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell5"];
        }
        else if (indexPath.row == 6) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell6"];
        }
        else if (indexPath.row == 7) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPMeCell7"];
        }
        
        ((CPMeCell1*)cell).icon.image = [UIImage imageNamed:[_icons objectAtIndex:indexPath.row-1]];
        ((CPMeCell1*)cell).titleLbl.text = [_titles objectAtIndex:indexPath.row-1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self checkIfUserLogin]) {
        if (indexPath.row == 0) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPUserInfoVC *userInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserInfoVC"];
            userInfoVC.user = self.user;
            [self.navigationController pushViewController:userInfoVC animated:YES];

        }
        else if (indexPath.row == 1) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyContractPageVC *myContractPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyContractPageVC"];
            [self.navigationController pushViewController:myContractPageVC animated:YES];
        }
        else if (indexPath.row == 2) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyScheduleVC *myScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyScheduleVC"];
            [self.navigationController pushViewController:myScheduleVC animated:YES];
        }
        else if (indexPath.row == 3) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyFriendVC *myFriendVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyFriendVC"];
            [self.navigationController pushViewController:myFriendVC animated:YES];
        }
        else if (indexPath.row == 4) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyAddressPageVC *myAddressPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyAddressPageVC"];
            myAddressPageVC.fromMeVC = YES;
            [self.navigationController pushViewController:myAddressPageVC animated:YES];
        }
        else if (indexPath.row == 5) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyActivityVC *myActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyActivityVC"];
            myActivityVC.showType = MyActivityShowTypeMe;
            [self.navigationController pushViewController:myActivityVC animated:YES];
            
        }
        else if (indexPath.row == 6) {
            
            [self activityShareAction];
            
        }
        else if (indexPath.row == 7) {
            TestMapkitResultVC *vc = [TestMapkitResultVC new];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
}

- (void)meHeaderCellSignInAction{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
    userLoginVC.passValueblock = ^(BOOL login) {
        if (login) {
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    [self.navigationController pushViewController:userLoginVC animated:YES];
}

- (void)meHeaderCellEditAction{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPChangeIDVC *changeIDVC = [storyboard instantiateViewControllerWithIdentifier:@"CPChangeIDVC"];
    changeIDVC.passValueblock = ^(NSString * _Nonnull nickname) {
//        self.user.nickname = nickname;
        [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:changeIDVC animated:YES];
}


- (BOOL)checkIfUserLogin{
    if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
        userLoginVC.passValueblock = ^(BOOL login) {
            if (login) {
                [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        [self.navigationController pushViewController:userLoginVC animated:YES];
        
        return NO;
    }
    
    return YES;
}


- (void)requestUserInfo{
    NSLog(@"CPMeVC requestUserInfo url:%@", [NSString stringWithFormat:@"%@/api/user/v1/userInfo", BaseURL]);
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/userInfo", BaseURL] parameters:@{}.mutableCopy success:^(id responseObject) {
        NSLog(@"CPMeVC requestUserInfo responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSLog(@"CPMeVC requestIfUserIsLogin has login");
                NSDictionary *dict = [responseObject valueForKey:@"data"];
                weakSelf.user = [CPUserInfoModel mj_objectWithKeyValues:dict];
                [weakSelf.tableView reloadData];
                
            }
            else{
                // 未登录，刷新tableview
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserNickname];
                [weakSelf.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                NSLog(@"CPMeVC requestIfUserIsLogin not login");
            }
            
        }
        else {
            NSLog(@"CPMeVC requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMeVC requestUserInfo error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



#pragma mark - iOS 原生分享
- (void)activityShareAction{
    // 1、设置分享的内容，并将内容添加到数组中
    NSString *shareText = @"Share title";
    NSURL *shareUrl = [NSURL URLWithString:@"https://www.discovery.com"];
    NSArray *activityItemsArray = @[shareText, shareUrl];
    
    // 自定义的CPCustomActivity，继承自UIActivity
//    CPCustomActivity *customActivity = [[CPCustomActivity alloc]initWithTitle:shareText URL:shareUrl ActivityType:@"Custom"];
//    NSArray *activityArray = @[customActivity];
    NSArray *activityArray = @[];
    
    // 2、初始化控制器，添加分享内容至控制器
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItemsArray applicationActivities:activityArray];
    activityVC.modalInPopover = YES;
    
    // 3、设置回调
    if (@available(iOS 8.0, *)){
        // ios8.0 之后用此方法回调
        UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
            NSLog(@"CPMeVC activityShareAction activityType == %@",activityType);
            if (completed == YES) {
                NSLog(@"CPMeVC activityShareAction completed");
            }else{
                NSLog(@"CPMeVC activityShareAction cancel");
            }
        };
        activityVC.completionWithItemsHandler = itemsBlock;
    }
    
    // 4、调用控制器
    [self.tabBarController presentViewController:activityVC animated:YES completion:nil];
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
