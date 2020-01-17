//
//  ConversationTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationTableViewController.h"
#import "WFCUConversationTableViewCell.h"
#import "WFCUContactListViewController.h"
#import "WFCUCreateGroupViewController.h"
#import "WFCUFriendRequestViewController.h"
#import "WFCUAddFriendViewController.h"
#import "WFCUSearchGroupTableViewCell.h"
#import "WFCUConversationSearchResultController.h"
#import "WFCUConversationSearchTableViewController.h"
#import "WFCUSearchChannelViewController.h"
#import "WFCUCreateChannelViewController.h"

#import "WFCUMessageListViewController.h"
#import <WFChatClient/WFCChatClient.h>

#import "WFCUUtilities.h"
#import "UITabBar+badge.h"
#import "KxMenu.h"
#import "UIImage+ERCategory.h"
#import "MBProgressHUD.h"

#import "WFCUContactTableViewCell.h"
#import "QrCodeHelper.h"

#import "VHLNavigation.h"
#import "SAMKeychain.h"
#import "WFCConfig.h"

#import <UserNotifications/UserNotifications.h>


@interface WFCUConversationTableViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray<WFCCConversationInfo *> *conversations;

@property (nonatomic, strong) WFCUConversationSearchResultController *resultsTableController;
@property (nonatomic, strong)  UISearchController       *searchController;

@property (nonatomic, strong) NSArray<WFCCConversationSearchInfo *>  *searchConversationList;
@property (nonatomic, strong) NSArray<WFCCUserInfo *>  *searchFriendList;
@property (nonatomic, strong) NSArray<WFCCGroupSearchInfo *>  *searchGroupList;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *searchViewContainer;

//@property (nonatomic, assign) BOOL firstAppear;
@property (nonatomic, assign) BOOL refreshConversations;
@property (nonatomic, assign) BOOL needActive;// UISearchController needActive

@property (nonatomic, strong) UIView *pcSessionView;
@property (nonatomic, strong) UIView *titleViewCntr;
@property (nonatomic, strong) UILabel *naviLbl;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation WFCUConversationTableViewController
- (void)initSearchUIAndTableView {
    _searchConversationList = [NSMutableArray array];

    _resultsTableController = [[WFCUConversationSearchResultController alloc] init];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor blackColor];
            }
            else {
                return [UIColor placeholderTextColor];
            }
        }];
        self.searchController.searchBar.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        [self.searchController.searchBar setValue:kLocalizedTableString(@"Cancel", @"CPLocalizable") forKey:@"_cancelButtonText"];
        
        self.searchController.searchBar.tintColor = [UIColor blackColor];
    }
    
    
    self.searchController.searchBar.placeholder = kLocalizedTableString(@"Search", @"CPLocalizable");
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.definesPresentationContext = YES;
    
//    [self updatePcSession];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    WFCCUserInfo *userInfo = notification.userInfo[@"userInfo"];
    NSArray *dataSource = self.conversations;
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.conversation.type == Single_Type && [conv.conversation.target isEqualToString:userInfo.userId]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
    WFCCGroupInfo *groupInfo = notification.userInfo[@"groupInfo"];
    NSArray *dataSource = self.conversations;
    
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.conversation.type == Group_Type && [conv.conversation.target isEqualToString:groupInfo.target]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)onChannelInfoUpdated:(NSNotification *)notification {
    WFCCChannelInfo *channelInfo = notification.userInfo[@"groupInfo"];
    NSArray *dataSource = self.conversations;
    
    for (int i = 0; i < dataSource.count; i++) {
        WFCCConversationInfo *conv = dataSource[i];
        if (conv.conversation.type == Channel_Type && [conv.conversation.target isEqualToString:channelInfo.channelId]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

//
- (void)onSendingMessageStatusUpdated:(NSNotification *)notification {
//        long messageId = [notification.object longValue];
//        self.conversations = [[[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0), @(1)]] mutableCopy];
//        [self updateBadgeNumber];
//        [self.tableView reloadData];
        
        
        long messageId = [notification.object longValue];
        NSArray *dataSource = self.conversations;

        if (messageId == 0) {
            return;
        }

        for (int i = 0; i < dataSource.count; i++) {
            WFCCConversationInfo *conv = dataSource[i];
            if (conv.lastMessage && conv.lastMessage.direction == MessageDirection_Send && conv.lastMessage.messageId == messageId) {
                conv.lastMessage = [[WFCCIMService sharedWFCIMService] getMessage:messageId];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
//            else if (conv.lastMessage && conv.lastMessage.direction == MessageDirection_Send && conv.lastMessage.messageId != messageId) {
//                conv.lastMessage = [[WFCCIMService sharedWFCIMService] getMessage:messageId];
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//            }
        }
}

- (void)onRightBarBtn:(UIBarButtonItem *)sender {
    CGFloat searchExtra = 0;
    CGFloat offsetY = 5;
    if (@available(iOS 11.0, *)) {
        
    }
    else if (@available(iOS 8.0, *)) {
        offsetY = kNAVIBARANDSTATUSBARHEIGHT;
    }
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(self.view.bounds.size.width - 56, 0 + searchExtra, 48, offsetY)
                 menuItems:@[
//                             [KxMenuItem menuItem:@"创建聊天"
//                                            image:[UIImage imageNamed:@"menu_start_chat"]
//                                           target:self
//                                           action:@selector(startChatAction:)],
                             [KxMenuItem menuItem:kLocalizedTableString(@"Add Friend title", @"CPLocalizable")
                                            image:[UIImage imageNamed:@"menu_add_friends"]
                                           target:self
                                           action:@selector(addFriendsAction:)],
//                             [KxMenuItem menuItem:@"收听频道"
//                                            image:[UIImage imageNamed:@"menu_listen_channel"]
//                                           target:self
//                                           action:@selector(listenChannelAction:)],
//                             [KxMenuItem menuItem:@"扫二维码"
//                                            image:[UIImage imageNamed:@"menu_scan_qr"]
//                                           target:self
//                                           action:@selector(scanQrCodeAction:)]


                             ]];
}

- (void)startChatAction:(id)sender {
    WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
    pvc.selectContact = YES;
    pvc.multiSelect = YES;
    pvc.showCreateChannel = YES;
  __weak typeof(self)ws = self;
    pvc.createChannel = ^(void) {
        WFCUCreateChannelViewController *vc = [[WFCUCreateChannelViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };

    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
      if (contacts.count == 1) {
        WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
        mvc.conversation = [WFCCConversation conversationWithType:Single_Type target:contacts[0] line:0];
        mvc.hidesBottomBarWhenPushed = YES;
        [ws.navigationController pushViewController:mvc animated:YES];
      } else {
        WFCUCreateGroupViewController *vc = [[WFCUCreateGroupViewController alloc] init];
        vc.memberIds = [contacts mutableCopy];
        if (![vc.memberIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
          [vc.memberIds insertObject:[WFCCNetworkService sharedInstance].userId atIndex:0];
        }
        vc.hidesBottomBarWhenPushed = YES;
        [ws.navigationController pushViewController:vc animated:YES];
      }
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
    [self.navigationController presentViewController:navi animated:YES completion:nil];

}

- (void)addFriendsAction:(id)sender {
//    UIViewController *addFriendVC = [[WFCUFriendRequestViewController alloc] init];
//    addFriendVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:addFriendVC animated:YES];
    
    UIViewController *addFriendVC = [[WFCUAddFriendViewController alloc] init];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

- (void)listenChannelAction:(id)sender {
    UIViewController *searchChannelVC = [[WFCUSearchChannelViewController alloc] init];
    searchChannelVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchChannelVC animated:YES];
}

- (void)scanQrCodeAction:(id)sender {
    if (gQrCodeDelegate) {
        [gQrCodeDelegate scanQrCode:self.navigationController];
    }
}

#pragma mark - awakeFromNib
-(void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"WFCUConversationTableViewController awakeFromNib");
    
    self.conversations = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearAllUnread:) name:@"kTabBarClearBadgeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelInfoUpdated:) name:kChannelInfoUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendingMessageStatusUpdated:) name:kSendingMessageStatusUpdated object:nil];
    
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusChanged:) name:kConnectionStatusChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecallMessages:) name:kRecallMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingUpdated:) name:kSettingUpdated object:nil];
    
    
    //注册并登录成功的通知 register or login success
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupAndLoginSuccess:) name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
    
    // ChangeLanguage
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLanguageChangedNotification:) name:ChangeLanguageNotificationName object:nil];
    
    //connect im on other viewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imConnectedOnOtherViewController:) name:@"IMCONNECTEDONOTHERVIEWCONTROLLER" object:nil];
    
    //receive message from remote notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestIfUserIsLogin) name:@"RECEIVEREMOTENOTIFICATIONWHENAPPACTIVE" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        self.view.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    
    if (@available(iOS 11.0, *)) {
        // fix bug iOS 11 click cancel causes searchbar flutters
        self.edgesForExtendedLayout = UIRectEdgeNone;
    } else {
        // Fallback on earlier versions
    }
    
    [self vhl_setNavBarBackgroundColor:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]];
    [self vhl_setNavBarTintColor:[UIColor whiteColor]];
    [self vhl_setNavBarTitleColor:[UIColor whiteColor]];
    
    
    [self initSearchUIAndTableView];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_plus"] style:UIBarButtonItemStyleDone target:self action:@selector(onRightBarBtn:)];
    
    
    UIView *continer = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 60, 0, 150, 44)];
//    continer.backgroundColor = [UIColor orangeColor];
    self.titleViewCntr = continer;
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 110, 44)];
//    navLabel.backgroundColor = [UIColor greenColor];
    [navLabel setTextColor:[UIColor whiteColor]];
    navLabel.font = [UIFont systemFontOfSize:18];
    navLabel.textAlignment = NSTextAlignmentCenter;
    self.naviLbl = navLabel;
    [self.titleViewCntr addSubview:navLabel];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.center = CGPointMake(20, 21);
    [indicatorView startAnimating];
    [continer addSubview:indicatorView];
    self.indicatorView = indicatorView;
    [self.titleViewCntr addSubview:self.indicatorView];
    self.navigationItem.titleView = self.titleViewCntr;
    
//    self.firstAppear = YES;
    
    if (!self.conversations) {
        self.conversations = [[NSMutableArray alloc] init];
    }
}



- (void)userSignupAndLoginSuccess:(NSNotification*)notification{
    self.refreshConversations = YES;
}

- (void)didLanguageChangedNotification:(NSNotification*)notification{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasChangeLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)imConnectedOnOtherViewController:(NSNotification*)notification{
    self.refreshConversations = YES;
}


- (void)updateConnectionStatus:(ConnectionStatus)status {
  if (status != kConnectionStatusConnecting && status != kConnectionStatusReceiving) {
      [self.indicatorView stopAnimating];
      self.naviLbl.frame = CGRectMake(0, 0, 150, 44);
    switch (status) {
      case kConnectionStatusLogout:
        self.naviLbl.text = kLocalizedTableString(@"Unlogin", @"CPLocalizable");
        break;
      case kConnectionStatusUnconnected:
        self.naviLbl.text = kLocalizedTableString(@"Disconnect", @"CPLocalizable");
        break;
      case kConnectionStatusConnected:
        self.naviLbl.text = kLocalizedTableString(@"Message", @"CPLocalizable");
        break;
        
      default:
        break;
    }
      
  } else {
      [self.indicatorView startAnimating];
      self.naviLbl.frame = CGRectMake(40, 0, 110, 44);
      if (status == kConnectionStatusConnecting) {
        self.naviLbl.text = kLocalizedTableString(@"Connecting", @"CPLocalizable");
      } else {
        self.naviLbl.text = kLocalizedTableString(@"Receiving", @"CPLocalizable");
      }
  }
}

- (void)onConnectionStatusChanged:(NSNotification *)notification {
  ConnectionStatus status = [notification.object intValue];
  [self updateConnectionStatus:status];
}

- (void)onReceiveMessages:(NSNotification *)notification {
    NSArray<WFCCMessage *> *messages = notification.object;
    for (int i = 0; i < messages.count; i++) {
        WFCCMessage *message = [messages objectAtIndex:i];
        //
        if ([message.content isKindOfClass:[WFCCRidingStatusNotificationMessageContent class]] && message.direction == MessageDirection_Receive) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RIDINGSTATUSCHANGEFROMOTHER" object:nil];
            
        }
        else if ([message.content isKindOfClass:[WFCCContractAttitudeTipPushNotificationMessageContent class]] && message.direction == MessageDirection_Receive) {
            
            WFCCContractAttitudeTipPushNotificationMessageContent *contractAttitudeContent = (WFCCContractAttitudeTipPushNotificationMessageContent *)message.content;
            if (contractAttitudeContent.contractAttitude == ContractAttitude_Agree) {
                if (contractAttitudeContent.contractType == 0) {
                    if (contractAttitudeContent.beginTime) {
                        [self setupShortTermNotificationByDataid:contractAttitudeContent.contractId contractType:contractAttitudeContent.contractType beginTime:contractAttitudeContent.beginTime];
                    }
                    
                }
                else {
                    if (contractAttitudeContent.endTime) {
                        [self setupLongTermNotificationsByDataid:contractAttitudeContent.contractId contractType:contractAttitudeContent.contractType beginTime:contractAttitudeContent.beginTime endTime:contractAttitudeContent.endTime endDate:contractAttitudeContent.endDate weekNum:contractAttitudeContent.weekNum];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OTHERUSERACCEPTCONTRACT" object:nil];
            }
        }
        else if ([message.content isKindOfClass:[WFCCRealtimeLocationNotificationMessageContent class]] && message.direction == MessageDirection_Receive) {
            
            WFCCRealtimeLocationNotificationMessageContent *realtimeLocationTipContent = (WFCCRealtimeLocationNotificationMessageContent *)message.content;
            if (realtimeLocationTipContent.shareLocationStatus == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARINGLOCATIONTOOTHERTIP" object:nil userInfo:@{@"othersIMUserId":realtimeLocationTipContent.othersIMUserId}];
            }
            else if (realtimeLocationTipContent.shareLocationStatus == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ENDINGSHARINGLOCATIONTOOTHERTIP" object:nil userInfo:@{@"othersIMUserId":realtimeLocationTipContent.othersIMUserId}];
            }
        }
    }
    
  if ([messages count]) {
    [self refreshList];
    [self refreshLeftButton];
  }
}

- (void)onSettingUpdated:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshList];
        [self refreshLeftButton];
//        [self updatePcSession];
    });
}

- (void)onRecallMessages:(NSNotification *)notification {
    [self refreshList];
    [self refreshLeftButton];
}

- (void)onClearAllUnread:(NSNotification *)notification {
    if ([notification.object intValue] == 0) {
        [[WFCCIMService sharedWFCIMService] clearAllUnreadStatus];
        [self refreshList];
        [self refreshLeftButton];
    }
}

- (void)refreshList {
    self.conversations = [[[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0), @(1)]] mutableCopy];
    [self updateBadgeNumber];
    [self.tableView reloadData];
}

- (void)updateBadgeNumber {
    int count = 0;
    for (WFCCConversationInfo *info in self.conversations) {
        if (!info.isSilent) {
            count += info.unreadCount.unread;
        }
    }
    [self.tabBarController.tabBar showBadgeOnItemIndex:1 badgeValue:count];
}

- (void)updatePcSession {
    NSString *pcOnline = [[WFCCIMService sharedWFCIMService] getUserSetting:UserSettingScope_PC_Online key:@""];
    
    if (@available(iOS 11.0, *)) {
        if ([pcOnline isEqualToString:@"1"]) {
            self.tableView.tableHeaderView = self.pcSessionView;
        } else {
            self.tableView.tableHeaderView = nil;
        }
    } else {
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.needActive = NO;
    NSArray *viewControllers = self.navigationController.viewControllers;
    for (UIViewController *vc in viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"WFCUConversationSearchTableViewController")]) {
            self.needActive = YES;
            break;
        }
    }
    
    if (self.needActive) {
        
    }
    else {
        self.searchController.active = NO;
    }
    
    [self refreshLeftButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    if (self.firstAppear) {
//        self.firstAppear = NO;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusChanged:) name:kConnectionStatusChanged object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecallMessages:) name:kRecallMessages object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingUpdated:) name:kSettingUpdated object:nil];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self requestIfUserIsLogin];
}


- (void)refreshLeftButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0), @(1)]];
        NSUInteger count = unreadCount.unread;

        NSString *title = nil;
        if (count > 0 && count < 1000) {
            title = [NSString stringWithFormat:@"%@(%ld)", kLocalizedTableString(@"back", @"CPLocalizable"), count];
        } else if (count >= 1000) {
            title = [NSString stringWithFormat:@"%@(...)", kLocalizedTableString(@"back", @"CPLocalizable")];
        } else {
            title = kLocalizedTableString(@"back", @"CPLocalizable");
        }

        UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
        item.title = title;

        self.navigationItem.backBarButtonItem = item;
    });
}

- (UIView *)pcSessionView {
    if (!_pcSessionView) {
        _pcSessionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        [_pcSessionView setBackgroundColor:[UIColor grayColor]];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 4, 32, 32)];
        iv.image = [UIImage imageNamed:@"pc_session"];
        [_pcSessionView addSubview:iv];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(68, 10, 100, 20)];
        label.text = @"PC已登录";
        [_pcSessionView addSubview:label];
    }
    return _pcSessionView;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCUConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationCell"];
    if (cell == nil) {
        cell = [[WFCUConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationCell"];
    }
    cell.info = self.conversations[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 72;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 76, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 76, 0, 0)];
    }
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) ws = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:kLocalizedTableString(@"Delete", @"CPLocalizable") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:ws.conversations[indexPath.row].conversation];
        [[WFCCIMService sharedWFCIMService] removeConversation:ws.conversations[indexPath.row].conversation clearMessage:YES];
        [ws.conversations removeObjectAtIndex:indexPath.row];
        [ws updateBadgeNumber];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UITableViewRowAction *setTop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:kLocalizedTableString(@"Sticky", @"CPLocalizable") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] setConversation:ws.conversations[indexPath.row].conversation top:YES success:^{
            [ws refreshList];
        } error:^(int error_code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:NO];
          
            hud.label.text = kLocalizedTableString(@"Setup failed", @"CPLocalizable");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
    }];
    
    UITableViewRowAction *setUntop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:kLocalizedTableString(@"Cancel Sticky", @"CPLocalizable") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[WFCCIMService sharedWFCIMService] setConversation:ws.conversations[indexPath.row].conversation top:NO success:^{
            [ws refreshList];
        } error:^(int error_code) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:NO];
            hud.label.text = kLocalizedTableString(@"Setup failed", @"CPLocalizable");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
        
        [self refreshList];
    }];
    
   
    delete.backgroundColor = RGBA(235, 78, 61, 1);
    setTop.backgroundColor = [UIColor purpleColor];
    setUntop.backgroundColor = [UIColor orangeColor];
    
    if (self.conversations[indexPath.row].isTop) {
        return @[delete, setUntop ];
    } else {
        return @[delete, setTop];
    }
};


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    WFCCConversationInfo *info = self.conversations[indexPath.row];
    mvc.conversation = info.conversation;
    mvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
    _searchController = nil;
    _searchConversationList       = nil;
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    if (searchString.length) {
        self.searchConversationList = [[WFCCIMService sharedWFCIMService] searchConversation:searchString inConversation:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0), @(1)]];
        self.searchFriendList = [[WFCCIMService sharedWFCIMService] searchFriends:searchString];
        self.searchGroupList = [[WFCCIMService sharedWFCIMService] searchGroups:searchString];
    } else {
        self.searchConversationList = nil;
        self.searchFriendList = nil;
        self.searchGroupList = nil;
    }
    
    
    // hand over the filtered results to our search results table
    WFCUConversationSearchResultController *conversationSearchResultController = (WFCUConversationSearchResultController *)self.searchController.searchResultsController;
    conversationSearchResultController.searchConversationList = self.searchConversationList;
    conversationSearchResultController.searchFriendList = self.searchFriendList;
    conversationSearchResultController.searchGroupList = self.searchGroupList;
    [conversationSearchResultController.tableView reloadData];
}


#pragma mark - 请求用户是否登录
- (void)requestIfUserIsLogin{
    [self.indicatorView startAnimating];
    self.naviLbl.frame = CGRectMake(40, 0, 110, 44);
    self.naviLbl.text = kLocalizedTableString(@"Connecting", @"CPLocalizable");
    
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/islogin", BaseURL] parameters:nil success:^(id responseObject) {
        NSLog(@"WFCUConversationTableViewController requestIfUserIsLogin responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"WFCUConversationTableViewController requestIfUserIsLogin 拼车号:%@ has login ", account);
                
                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                
                NSLog(@"WFCUConversationTableViewController savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@, [WFCCNetworkService sharedInstance].currentConnectionStatus:%ld", savedUserId, [WFCCNetworkService sharedInstance].userId, (long)[WFCCNetworkService sharedInstance].currentConnectionStatus);
                
                if (savedToken.length > 0 && savedUserId.length > 0) {
                    if (![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]) {
                        
                        NSLog(@"![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]");
                        [[WFCCNetworkService sharedInstance] disconnect:YES];
                        [[WFCCNetworkService sharedInstance] connect:savedUserId token:savedToken];
                        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
                        if (nil != deviceToken){
                            [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
                        }
                        
                    }
                    else if ([[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]) {
                        // change account
                        if(weakSelf.refreshConversations){
                            weakSelf.refreshConversations = false;
                            
                        }
                        else { // change language
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasChangeLanguage]) {
                                
                                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHasChangeLanguage];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        }
                    }
                    
                    [weakSelf updateConnectionStatus:[WFCCNetworkService sharedInstance].currentConnectionStatus];
                    [weakSelf refreshList];
                    [weakSelf refreshLeftButton];
                }
                
            }
            else{
                // 未登录，用设备id匿名聊天
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserLoginAccount];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserAvatar];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserNickname];
                NSLog(@"WFCUConversationTableViewController requestIfUserIsLogin not login");
                
                // im 登录
                NSString *anonymousChatAccount = [SAMKeychain passwordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
                
                [weakSelf anonymousUserGetIMTokenAndUserId:anonymousChatAccount];
            }
            
        }
        else {
            NSLog(@"WFCUConversationTableViewController requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        self.naviLbl.frame = CGRectMake(0, 0, 150, 44);
        self.naviLbl.text = kLocalizedTableString(@"Disconnect", @"CPLocalizable");
        [self.indicatorView stopAnimating];
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"WFCUConversationTableViewController requestIfUserIsLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)anonymousUserGetIMTokenAndUserId:(NSString*)anonymousAccount{
    WS(weakSelf)
//    [SVProgressHUD show];
    NSString *clientId = [[WFCCNetworkService sharedInstance] getClientId];
    
    NSLog(@"WFCUConversationTableViewController anonymousUserGetIMTokenAndUserId clientId:%@", clientId);
    
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/anonymousimlogin", BaseURL] parameters:@{@"phone":anonymousAccount, @"clientId":clientId}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"WFCUConversationTableViewController anonymousUserGetIMTokenAndUserId responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSDictionary *dict = [[responseObject valueForKey:@"data"] valueForKey:@"imResult"];
                
                if (nil != dict) {
                    // 匿名im 登录
                    NSString *anonymousUserId = [dict valueForKey:@"userId"];
                    NSString *anonymousToken = [dict valueForKey:@"token"];
                    NSLog(@"WFCUConversationTableViewController anonymousUserGetIMTokenAndUserId anonymousUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", anonymousUserId, [WFCCNetworkService sharedInstance].userId);
                    
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
                    }
                    
                    [weakSelf updateConnectionStatus:[WFCCNetworkService sharedInstance].currentConnectionStatus];
                    [weakSelf refreshList];
                    [weakSelf refreshLeftButton];
                }
            }
            
        }
        else {
            NSLog(@"WFCUConversationTableViewController anonymousUserGetIMTokenAndUserId 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"WFCUConversationTableViewController anonymousUserGetIMTokenAndUserId error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


#pragma mark - set up notice method
static NSNotificationName const _Nullable kCheckinNotification = @"contractAgreeNotification";
static NSString *const _Nullable kCheckinNotificationSwitchKey  = @"kCheckinNotificationSwitchKey";

/**  设置通知*/  // -1未选择，0前一天，1当天，2提前1小时，3提前10分钟
- (void)setupLongTermNotificationsByDataid:(NSUInteger)dataid
                              contractType:(NSUInteger)contractType
                                 beginTime:(NSString*)beginTime
                                   endTime:(NSString*)endTime
                                   endDate:(NSString*)endDate
                                   weekNum:(NSString*)weekNum {
    // 用户首次使用 默认开启通知（相当于NSUserDefaults）
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kCheckinNotificationSwitchKey] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kCheckinNotificationSwitchKey];
    }
    
    // 如果用户关闭通知，直接返回
    if([[[NSUserDefaults standardUserDefaults] valueForKey:kCheckinNotificationSwitchKey] isEqual: @(NO)]) return;
    
    
    NSString *todayStr = [Utils dateToString:[NSDate date] withDateFormat:@"yyyy-MM-dd"];
    NSDate *beginDate = [Utils stringToDate:[NSString stringWithFormat:@"%@ %@", todayStr, beginTime] withDateFormat:@"yyyy-MM-dd HH:mm"];
    
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
    
    NSArray *weekNumArr = [weekNum componentsSeparatedByString:@","];
    for (int i = 0; i < weekNumArr.count; i++) {
        NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
        
        // 将提醒类型和合约id作为通知的identifier
        identifier = [NSString stringWithFormat:@"%@-%lu-%ld", kCheckinNotification, (unsigned long)dataid, notifyWeekday];
        
        NSInteger theNotifyWeekday = notifyWeekday;
        
        if (@available(iOS 10.0, *)) {
            
            UNNotificationRequest *request = [self createNotificationRequestWithWeekday:theNotifyWeekday identifier:identifier hour:hour minute:minute contractId:dataid contractType:contractType beginTime:beginTime endTime:endTime endDate:endDate weekNum:weekNum];
            // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
        }
        else{
            NSInteger diff = labs(theNotifyWeekday - todayWeekDay);
            // 提前0小时提醒，当前
            NSDate *theDate = [today dateByAddingTimeInterval:-diff*60*60*24 - 60*60*0];
            UILocalNotification *notification = [self createLocalNotificationWithDate:theDate identifier:identifier contractId:dataid contractType:contractType beginTime:beginTime weekNum:weekNum];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}


/**  设置通知*/  // -1未选择，0前一天，1当天，2提前1小时，3提前10分钟
- (void)setupShortTermNotificationByDataid:(NSUInteger)dataid
                              contractType:(NSUInteger)contractType
                                 beginTime:(NSString*)beginTime {
    // 用户首次使用 默认开启通知（相当于NSUserDefaults）
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kCheckinNotificationSwitchKey] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kCheckinNotificationSwitchKey];
    }
    
    // 如果用户关闭通知，直接返回
    if([[[NSUserDefaults standardUserDefaults] valueForKey:kCheckinNotificationSwitchKey] isEqual: @(NO)]) return;
    
    
    NSDate *beginDate = [Utils stringToDate:beginTime withDateFormat:@"yyyy-MM-dd HH:mm"];
    
    // 将提醒类型和合约id作为通知的identifier
    NSString *identifier = [NSString stringWithFormat:@"%@%ld", kCheckinNotification, (unsigned long)dataid];
    
    if (@available(iOS 10.0, *)) {
        UNNotificationRequest *request = [self createNotificationRequestWithDate:beginDate identifier:identifier contractId:dataid contractType:contractType beginTime:beginTime weekNum:@""];
        // 把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else{
        
        UILocalNotification *notification = [self createLocalNotificationWithDate:beginDate identifier:identifier contractId:dataid contractType:contractType beginTime:beginTime weekNum:@""];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


#pragma mark   -  createLocalNotificationWithDate
#pragma mark - only on iOS 10 or newer
/**  long term   每个星期的星期几提醒*/
- (UNNotificationRequest *)createNotificationRequestWithWeekday:(NSInteger)weekday
                                                     identifier:(NSString *)identifier
                                                           hour:(NSInteger)hour
                                                         minute:(NSInteger)minute
                                                     contractId:(NSInteger)contractId contractType:(NSUInteger)contractType
                                                      beginTime:(NSString*)beginTime
                                                        endTime:(NSString*)endTime
                                                      endDate:(NSString*)endDate
                                                        weekNum:(NSString*)weekNum {
    NSLog(@"WFCUMessageListViewController createNotificationRequestWithWeekday identifier:%@", identifier);
    
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.title = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
    content.body = kLocalizedTableString(@"contract start now", @"CPLocalizable");
    
    //content.badge = @(++kApplication.applicationIconBadgeNumber); // 不显示角标
    content.userInfo = @{@"kLocalNotificationID":kCheckinNotification, @"identifier":identifier, @"contractId":[NSNumber numberWithInteger:contractId], @"contractType":[NSNumber numberWithInteger:contractType], @"beginTime":beginTime, @"endTime":endTime, @"weekNum":weekNum, @"endDate":endDate};
    
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
- (UNNotificationRequest *)createNotificationRequestWithDate:(NSDate*)date
                                                  identifier:(NSString *)identifier
                                                  contractId:(NSInteger)contractId
                                                contractType:(NSUInteger)contractType
                                                   beginTime:(NSString*)beginTime
                                                     weekNum:(NSString*)weekNum {
    NSLog(@"WFCUMessageListViewController createNotificationRequestWithDate identifier:%@", identifier);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                              fromDate:date];
    
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.title = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
    content.body = kLocalizedTableString(@"contract start now", @"CPLocalizable");
    
    //content.badge = @(++kApplication.applicationIconBadgeNumber); // 不显示角标
    content.userInfo = @{@"kLocalNotificationID":kCheckinNotification, @"identifier":identifier, @"contractId":[NSNumber numberWithInteger:contractId], @"contractType":[NSNumber numberWithInteger:contractType], @"beginTime":beginTime, @"weekNum":weekNum};
    
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
- (UILocalNotification *)createLocalNotificationWithDate:(NSDate *)date
                                              identifier:(NSString *)identifier
                                              contractId:(NSInteger)contractId contractType:(NSUInteger)contractType
                                               beginTime:(NSString*)beginTime
                                                 weekNum:(NSString*)weekNum {
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // 1.设置触发时间（如果要立即触发，无需设置）
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = date;
    localNotification.repeatInterval = NSCalendarUnitWeekday;
    
    // 2.设置通知标题
    localNotification.alertBody = kLocalizedTableString(@"Contract Remind", @"CPLocalizable");
    localNotification.alertAction = kLocalizedTableString(@"contract start now", @"CPLocalizable");
    // localNotification.applicationIconBadgeNumber = ++kApplication.applicationIconBadgeNumber;
    
    // 3.设置通知的 传递的userInfo
    localNotification.userInfo = @{@"kLocalNotificationID":kCheckinNotification, @"identifier":identifier, @"contractId":[NSNumber numberWithInteger:contractId], @"contractType":[NSNumber numberWithInteger:contractType], @"beginTime":beginTime, @"weekNum":weekNum};
    
    return localNotification;
}



@end
