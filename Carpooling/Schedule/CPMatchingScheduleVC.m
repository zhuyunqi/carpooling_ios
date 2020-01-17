//
//  CPMatchingScheduleVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMatchingScheduleVC.h"
#import "CPMatchingScheduleCell1.h"
#import "VHLNavigation.h"
#import "CPMatchingScheduleReqResultModel.h"
#import "CPMatchingScheduleReqResultSubModel.h"
#import "CPScheduleMJModel.h"
//#import "CPStrangerChatVC.h"
//#import "SSChatController.h"
#import "CPUserInfoModel.h"
#import "CPMatchingScheduleModel.h"
#import "CPAddressModel.h"

#import <Realm.h>

#import "CPMyFriendVC.h"
#import "CPUserLoginVC.h"
#import "SAMKeychain.h"

#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"

#import "UILabel+YBAttributeTextTapAction.h"

#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>


@interface CPMatchingScheduleVC ()<CPMatchingScheduleCell1Delegate, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *fromMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *fromLbl;
@property (weak, nonatomic) IBOutlet UILabel *toMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *toLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (nonatomic, strong) NSIndexPath *selectIndexPath; // select chat with somebody

@property (nonatomic, assign) CGFloat fromAddrHeight;
@property (nonatomic, assign) CGFloat toAddrHeight;
@property (nonatomic, assign) CGFloat timeHeight;

@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UILabel *noDataLbl;

@property (nonatomic, strong) MFMessageComposeViewController *picker;

@property (nonatomic, assign) BOOL talkNow;
@end

@implementation CPMatchingScheduleVC

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
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.title = kLocalizedTableString(@"Schedule Matching", @"CPLocalizable");
    [self vhl_setNavBarShadowImageHidden:YES];
    
    [self configureHeaderView];
    
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-self.headerView.frame.size.height)/2-40, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = RGBA(150, 150, 150, 1);
    
    NSString *text = kLocalizedTableString(@"Invite Friends", @"CPLocalizable");
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", kLocalizedTableString(@"Matching no result", @"CPLocalizable"), text] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.f],
                                                                                                                                                                                                                   NSForegroundColorAttributeName : RGBA(150, 150, 150, 1)}];
    [attrText setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.f],
                              NSForegroundColorAttributeName : RGBA(120, 202, 195, 1)} range:NSMakeRange(attrText.length-text.length, text.length)];
    noDataLbl.attributedText = attrText;
    
    WS(weakSelf)
    [noDataLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(attrText.length-text.length, text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Friends", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyFriendVC *myFriendVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyFriendVC"];
            myFriendVC.fromMatchikngScheduleMJModel = self.scheduleMJModel;
            [weakSelf.navigationController pushViewController:myFriendVC animated:YES];
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Contacts", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 9.0, *)) {
                CNContactPickerViewController *contactVc = [CNContactPickerViewController new];
                contactVc.delegate = self;
                [self presentViewController:contactVc animated:YES completion:nil];
            } else {
                // Fallback on earlier versions
            }
            
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:action1];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"CPMatchingScheduleVC noDataLbl");
    }];
    
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    
    
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingBlock:^{
        [self requestMatchingScheduleByCurrentIndex:self.currIndex];
    }];
    
    self.talkNow = NO;
    //
    [SVProgressHUD show];
    [self requestIfUserIsLogin];
    
    [self requestMatchingScheduleByCurrentIndex:_currIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    CGRect rect = self.tableView.frame;
//    rect.origin.y = kNAVIBARANDSTATUSBARHEIGHT+self.headerHeight;
//    rect.size.height -= kNAVIBARANDSTATUSBARHEIGHT+self.headerHeight;
//    self.tableView.frame = rect;
}

- (void)configureHeaderView{
    _fromLbl.text = [[_requestParams valueForKey:@"fromAddressVo"] valueForKey:@"address"];
    [_fromLbl sizeToFit];
    _fromAddrHeight = _fromLbl.size.height;
    
    _toLbl.text = [[_requestParams valueForKey:@"toAddressVo"] valueForKey:@"address"];
    [_toLbl sizeToFit];
    _toAddrHeight = _toLbl.size.height;
    
    NSDate *date = [Utils getDateWithTimestamp:[[_requestParams valueForKey:@"arriveTime"] integerValue]];
    NSString *dateStr = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
    NSString *str = dateStr;
    NSString *schedulingCycle = [_requestParams valueForKey:@"schedulingCycle"];
    if (schedulingCycle && schedulingCycle.length > 0) {
        str = [NSString stringWithFormat:@"%@ %@(%@)", dateStr, kLocalizedTableString(@"repeat", @"CPLocalizable"), [_requestParams valueForKey:@"schedulingCycle"]];
    }
    
    CGSize size3 = W_GET_STRINGSIZE(str, kSCREENWIDTH-86, MAXFLOAT, [UIFont systemFontOfSize:14.f]);
    _timeLbl.text = str;
    
    
    [_timeLbl sizeToFit];
    _timeHeight = _timeLbl.size.height;
    
    
//    _headerHeightConstraint.constant = self.headerHeight;
    _headerHeightConstraint.constant = _fromAddrHeight + _toAddrHeight + _timeHeight + size3.height + 50;
    _headerView.backgroundColor = RGBA(120, 202, 195, 1);
    
    _titleLbl.textColor = [UIColor whiteColor];
    _fromLbl.textColor = [UIColor whiteColor];
    _toLbl.textColor = [UIColor whiteColor];
    _timeLbl.textColor = [UIColor whiteColor];
    _fromMarkLbl.textColor = [UIColor whiteColor];
    _toMarkLbl.textColor = [UIColor whiteColor];
    _timeMarkLbl.textColor = [UIColor whiteColor];
    
    _fromMarkLbl.text = kLocalizedTableString(@"From", @"CPLocalizable");
    _toMarkLbl.text = kLocalizedTableString(@"To", @"CPLocalizable");
    _timeMarkLbl.text = kLocalizedTableString(@"Schedule Endtime", @"CPLocalizable");
    _titleLbl.text = [_requestParams valueForKey:@"subject"];
}

- (void)setRequestParams:(NSMutableDictionary *)requestParams{
    _requestParams = requestParams;
}

- (void)setScheduleMJModel:(CPScheduleMJModel *)scheduleMJModel{
    _scheduleMJModel = scheduleMJModel;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPMatchingScheduleModel *model = [self.dataSource objectAtIndex:indexPath.row];
    return model.cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
    CPMatchingScheduleCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMatchingScheduleCell1"];
    cell.delegate = self;
    cell.matchingScheduleModel = [self.dataSource objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        CPActivitysVC *activitysVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivitysVC"];
        //        [self.navigationController pushViewController:activitysVC animated:YES];
    }
}


- (void)requestMatchingScheduleByCurrentIndex:(NSUInteger)index{
    WS(weakSelf);
    [self.requestParams setValue:[NSNumber numberWithUnsignedInteger:_currIndex] forKey:@"page"];
    [self.requestParams setValue:[NSNumber numberWithUnsignedInteger:_pageSize] forKey:@"pageSize"];
    NSLog(@"CPMatchingScheduleVC requestMatchingScheduleByCurrentIndex _currIndex:%lu", (unsigned long)_currIndex);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/scheduling/v1/scheduling.json", BaseURL] parameters:self.requestParams success:^(id responseObject) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [SVProgressHUD dismiss];
        NSLog(@"CPMatchingScheduleVC requestMatchingScheduleByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPMatchingScheduleReqResultModel *masterModel = [CPMatchingScheduleReqResultModel mj_objectWithKeyValues:responseObject];
            CPMatchingScheduleReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
                if (weakSelf.currIndex == 1) {
                    if (subModel.data.count == 0) {
                        weakSelf.noDataLbl.hidden = NO;
                    }
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                
                for (int i = 0; i < subModel.data.count; i++) {
                    CPMatchingScheduleModel *model = [subModel.data objectAtIndex:i];
                    
                    CGSize size1 = W_GET_STRINGSIZE(model.schedulingCarpoolVo.fromAddressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height1 =  size1.height;
                    
                    CGSize size2 = W_GET_STRINGSIZE(model.schedulingCarpoolVo.toAddressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height2 = size2.height;
                    
                    NSDate *date = [Utils getDateWithTimestamp:model.schedulingCarpoolVo.arriveTime];
                    NSString *time = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];

                    CGSize size3 = W_GET_STRINGSIZE(time, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:14.f]);
                    CGFloat height3 = size3.height;
                    
                    CGFloat totalHeight = height1 +height2 +height3 +100;
                    model.cellHeight = totalHeight;
                }
                
                weakSelf.currIndex++;
                if (weakSelf.dataSource.count > 0) {
                    weakSelf.noDataLbl.hidden = YES;
                }
                [weakSelf.tableView reloadData];
                
            }
            else{
                NSLog(@"requestMatchingSchedule requestMatchingScheduleByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPMatchingScheduleVC requestMatchingScheduleByCurrentIndex 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMatchingScheduleVC requestMatchingScheduleByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}



#pragma mark - 与陌生人打招呼
- (void)matchingScheduleCell1BtnAction:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    self.talkNow = YES;
    [self requestIfUserIsLogin];
}


#pragma mark - 请求用户是否登录
- (void)requestIfUserIsLogin{
    WS(weakSelf)
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/islogin", BaseURL] parameters:nil success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMatchingScheduleVC requestIfUserIsLogin responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"CPMatchingScheduleVC requestIfUserIsLogin 拼车号:%@ has login ", account);
                
                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                
                NSLog(@"CPMatchingScheduleVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", savedUserId, [WFCCNetworkService sharedInstance].userId);
                
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
                    
                    if (weakSelf.talkNow) {
                        //
                        [weakSelf goChatWithSomebody:weakSelf.selectIndexPath.row];
                    }
                }
                
            }
            else{
                // 未登录，用设备id匿名聊天
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserNickname];
                NSLog(@"CPMatchingScheduleVC requestIfUserIsLogin not login");
                
                // im 登录
                NSString *anonymousChatAccount = [SAMKeychain passwordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
                
                [weakSelf anonymousUserGetIMTokenAndUserId:anonymousChatAccount];
            }
            
        }
        else {
            NSLog(@"CPMatchingScheduleVC requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMatchingScheduleVC requestIfUserIsLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)anonymousUserGetIMTokenAndUserId:(NSString*)anonymousAccount{
    [SVProgressHUD show];
    NSString *clientId = [[WFCCNetworkService sharedInstance] getClientId];
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/anonymousimlogin", BaseURL] parameters:@{@"phone":anonymousAccount, @"clientId":clientId}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMatchingScheduleVC anonymousUserGetIMTokenAndUserId responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSDictionary *dict = [[responseObject valueForKey:@"data"] valueForKey:@"imResult"];
                
                if (nil != dict) {
                    // 匿名im 登录
                    NSString *anonymousUserId = [dict valueForKey:@"userId"];
                    NSString *anonymousToken = [dict valueForKey:@"token"];
                    NSLog(@"CPMatchingScheduleVC anonymousUserGetIMTokenAndUserId anonymousUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", anonymousUserId, [WFCCNetworkService sharedInstance].userId);
                    
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
                    
                    if (weakSelf.talkNow) {
                        //
                        [weakSelf goChatWithSomebody:weakSelf.selectIndexPath.row];
                    }
                }
            }
            
        }
        else {
            NSLog(@"CPMatchingScheduleVC anonymousUserGetIMTokenAndUserId 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMatchingScheduleVC anonymousUserGetIMTokenAndUserId error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)goChatWithSomebody:(NSInteger)index{
    CPMatchingScheduleModel *matchingScheduleModel = [self.dataSource objectAtIndex:index];
    NSString *currentUserAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    // 已登录
    if (currentUserAccount) {
        if (matchingScheduleModel.isFriend) {
            CPUserInfoModel *model = matchingScheduleModel.userVo;
            NSLog(@"CPMatchingScheduleVC matchingScheduleCell1BtnAction friend exist, id:%@", model.imUserId);
            
            WFCUMessageListViewController *vc = [[WFCUMessageListViewController alloc] init];
            
            if (_scheduleMJModel) {
                vc.scheduleMJModel = matchingScheduleModel.schedulingCarpoolVo;
            }
            else if (_requestParams) {
                vc.scheduleMJModel = [CPScheduleMJModel mj_objectWithKeyValues:_requestParams];
            }
            
            vc.conversation = [WFCCConversation conversationWithType:Single_Type target:model.imUserId line:0];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else{
            NSLog(@"CPMatchingScheduleVC matchingScheduleCell1BtnAction friend isnot exist, matchingScheduleModel.userVo.imUserId:%@", matchingScheduleModel.userVo.imUserId);
            
            WFCUStrangerMessageController *vc = [[WFCUStrangerMessageController alloc] init];
            vc.showMatchingTopHeaderView = YES;
            
            if (_scheduleMJModel) {
                vc.scheduleMJModel = matchingScheduleModel.schedulingCarpoolVo;
            }
            else if (_requestParams) {
                vc.scheduleMJModel = [CPScheduleMJModel mj_objectWithKeyValues:_requestParams];
            }
            
            vc.conversation = [WFCCConversation conversationWithType:Single_Type target:matchingScheduleModel.userVo.imUserId line:0];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }
    else{
        // 未登录
        
        WFCUStrangerMessageController *vc = [[WFCUStrangerMessageController alloc] init];
        vc.showMatchingTopHeaderView = YES;
        
        if (_scheduleMJModel) {
            vc.scheduleMJModel = matchingScheduleModel.schedulingCarpoolVo;
        }
        else if (_requestParams) {
            vc.scheduleMJModel = [CPScheduleMJModel mj_objectWithKeyValues:_requestParams];
        }
        
        vc.conversation = [WFCCConversation conversationWithType:Single_Type target:matchingScheduleModel.userVo.imUserId line:0];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - CNContactPickerDelegate-
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact  API_AVAILABLE(ios(9.0)){
    //    NSLog(@"选中某一个联系人时调用---------------------------------");
    
    //    [self printContactInfo:contact];
    NSMutableArray *phoneNumbers = [NSMutableArray array];
    for (CNLabeledValue *labeledValue in contact.phoneNumbers){
        CNPhoneNumber *phoneValue = labeledValue.value;
        NSString * phoneNumber = phoneValue.stringValue;
        NSLog(@"number: %@",phoneNumber);
        NSString *phoneNum = [self phoneNumberFormat:phoneNumber];
        [phoneNumbers addObject:phoneNum];
    }
    //
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass) {
        if ([MFMessageComposeViewController canSendText]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self displaySMSComposerSheetWithPhoneString:phoneNumbers];
            });
            
        }else{
        }
    }
}


- (void)displaySMSComposerSheetWithPhoneString:(NSArray *)phoneNumbers{
    
    self.picker = [[MFMessageComposeViewController alloc] init];
    
    if ([MFMessageComposeViewController canSendText]) {
        _picker.messageComposeDelegate = self;
        _picker.recipients = phoneNumbers;
        _picker.body = @"http://mgsfc.172u.win:888/h5-project/index.html";
        //下面的代码为发消息界面添加一个取消按钮 不然会返回不回来
        UINavigationItem *navigationItem = [[[_picker viewControllers]lastObject]navigationItem];
        [navigationItem setTitle:kLocalizedTableString(@"New Message", @"CPLocalizable")];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(0, 0, 40, 20)];
        //取消按
        [button setTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [button addTarget:self action:@selector(msgBackFun) forControlEvents:UIControlEventTouchUpInside];
        navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

//通讯录手机号转换纯数字
- (NSString *)phoneNumberFormat:(NSString *)phoneNum{
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[^\\d]" options:0 error:NULL];
    phoneNum = [regular stringByReplacingMatchesInString:phoneNum options:0 range:NSMakeRange(0, [phoneNum length]) withTemplate:@""];
    return phoneNum;
}

//短信界面返回
- (void)msgBackFun {
    
    [self.picker dismissViewControllerAnimated:YES completion:nil];
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
