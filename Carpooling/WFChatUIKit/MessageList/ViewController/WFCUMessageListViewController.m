//
//  MessageListViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/31.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUMessageListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WFCUImagePreviewViewController.h"
#import "WFCUVoiceRecordView.h"

#import "WFCUImageCell.h"
#import "WFCUTextCell.h"
#import "WFCUVoiceCell.h"
#import "WFCULocationCell.h"
#import "WFCUFileCell.h"
#import "WFCUInformationCell.h"
#import "WFCUCallSummaryCell.h"
#import "WFCUStickerCell.h"
#import "WFCUVideoCell.h"
#import "WFCUAddFriendCell.h"
#import "WFCUContractMessageCell.h"
#import "WFCUBrowserViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUProfileTableViewController.h"

#import "WFCUChatInputBar.h"



#import "WFCUConversationSettingViewController.h"
#import "SDPhotoBrowser.h"
#import "WFCULocationViewController.h"
#import "WFCULocationPoint.h"
#import "WFCUVideoViewController.h"

#import "WFCUContactListViewController.h"
#import "WFCUBrowserViewController.h"

#import "MBProgressHUD.h"
#import "WFCUMediaMessageDownloader.h"

#import "VideoPlayerSampleViewController.h"
#import "VideoPlayerKit.h"

#import "WFCUForwardViewController.h"

#import <WFChatClient/WFCChatClient.h>
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif

#import "VHLNavigation.h"

#import "CPInitShortTermContractVC.h"
#import "CPInitLongTermContractVC.h"
#import "SSChatLocationController.h"
#import "SSChatMapController.h"

#import "SAMKeychain.h"
#import "CPUserLoginVC.h"

#import <UserNotifications/UserNotifications.h>


@interface WFCUMessageListViewController () <UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UINavigationControllerDelegate, WFCUMessageCellDelegate, AVAudioPlayerDelegate, WFCUChatInputBarDelegate, SDPhotoBrowserDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong)NSMutableArray<WFCUMessageModel *> *modelList;
@property (nonatomic, strong)NSMutableDictionary<NSNumber *, Class> *cellContentDict;

@property(nonatomic) AVAudioPlayer *player;
@property(nonatomic) NSTimer *playTimer;

@property(nonatomic, assign)long playingMessageId;
@property(nonatomic, assign)BOOL loadingMore;
@property(nonatomic, assign)BOOL hasMoreOld;
  
@property(nonatomic, strong)WFCCUserInfo *targetUser;
@property(nonatomic, strong)WFCCGroupInfo *targetGroup;
@property(nonatomic, strong)WFCCChannelInfo *targetChannel;
@property(nonatomic, strong)WFCCChatroomInfo *targetChatroom;

@property(nonatomic, strong)WFCUChatInputBar *chatInputBar;
@property(nonatomic, strong)VideoPlayerKit *videoPlayerViewController;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic)NSArray<WFCCMessage *> *imageMsgs;

@property (strong, nonatomic)NSString *orignalDraft;

@property (nonatomic, strong)id<UIGestureRecognizerDelegate> scrollBackDelegate;

@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, assign)BOOL showAlias;

@property (nonatomic, strong)WFCUMessageCellBase *cell4Menu;
@property (nonatomic, assign)BOOL firstAppear;

@property (nonatomic, assign)BOOL hasNewMessage;
@property (nonatomic, assign)BOOL loadingNew;

@property (nonatomic, strong)UICollectionReusableView *headerView;
@property (nonatomic, strong)UICollectionReusableView *footerView;
@property (nonatomic, strong)UIActivityIndicatorView *headerActivityView;
@property (nonatomic, strong)UIActivityIndicatorView *footerActivityView;

@property (nonatomic, strong)NSTimer *showTypingTimer;

// alertview select contract 选择合约
@property(nonatomic, strong) UIView *viewOnAlertView;
@property(nonatomic, assign) NSInteger selectedContractType;
@property(nonatomic, strong) NSDictionary *contractDict;
@end

@implementation WFCUMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self vhl_setNavBarBackgroundColor:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]];
    [self vhl_setNavBarTintColor:[UIColor whiteColor]];
    [self vhl_setNavBarTitleColor:[UIColor whiteColor]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Initiation Contract", @"CPLocalizable") style:UIBarButtonItemStyleDone target:self action:@selector(didSelectContract)];
    

    self.cellContentDict = [[NSMutableDictionary alloc] init];

    [self initializedSubViews];
    self.firstAppear = YES;
    self.hasMoreOld = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onResetKeyboard:)];
    [self.collectionView addGestureRecognizer:tap];
    
    [self reloadMessageList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecallMessages:) name:kRecallMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendingMessage:) name:kSendingMessageStatusUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageListChanged:) name:kMessageListChanged object:self.conversation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    
  if(self.conversation.type == Single_Type) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:self.conversation.target];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_chat_single"] style:UIBarButtonItemStyleDone target:self action:@selector(onRightBarBtn:)];
    
  } else if(self.conversation.type == Group_Type) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:self.conversation.target];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_chat_group"] style:UIBarButtonItemStyleDone target:self action:@selector(onRightBarBtn:)];
  } else if(self.conversation.type == Channel_Type) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelInfoUpdated:) name:kChannelInfoUpdated object:self.conversation.target];
      
//      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_chat_channel"] style:UIBarButtonItemStyleDone target:self action:@selector(onRightBarBtn:)];
  }
    
    self.chatInputBar = [[WFCUChatInputBar alloc] initWithParentView:self.backgroundView conversation:self.conversation delegate:self];
    
    self.orignalDraft = [[WFCCIMService sharedWFCIMService] getConversationInfo:self.conversation].draft;
    
    if (self.conversation.type == Chatroom_Type) {
        __weak typeof(self) ws = self;
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
        hud.label.text = @"进入聊天室。。。";
        [hud showAnimated:YES];
        
        [[WFCCIMService sharedWFCIMService] joinChatroom:ws.conversation.target success:^{
            NSLog(@"join chatroom successs");
            [ws sendChatroomWelcomeMessage];
            [hud hideAnimated:YES];
            [ws loadMoreMessage:YES];
        } error:^(int error_code) {
            NSLog(@"join chatroom error");
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"进入聊天室失败";
//            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            hud.completionBlock = ^{
                [ws.navigationController popViewControllerAnimated:YES];
            };
        }];
    }
    
    WFCCConversationInfo *info = [[WFCCIMService sharedWFCIMService] getConversationInfo:self.conversation];
    self.chatInputBar.draft = info.draft;
    
    
    // is friend ismyfriend
    
    NSLog(@"WFCUMessageListViewController viewDidLoad self.conversation.target:%@", self.conversation.target);
    if (![[WFCCIMService sharedWFCIMService] isMyFriend:self.conversation.target]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Add Friend", @"CPLocalizable") style:UIBarButtonItemStyleDone target:self action:@selector(addFriendAction:)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 添加好友, 把添加好友和发起合约当成发送一条文本消息。
#pragma mark - 发送添加好友消息
- (void)addFriendAction:(id)sender{
    if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        [self.view endEditing:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
        [self.navigationController pushViewController:userLoginVC animated:YES];
        
        return;
    }
    
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    
    if (savedUserId.length > 0) {
        [[WFCCIMService sharedWFCIMService] sendFriendRequest:self.conversation.target reason:@"" success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"好友请求成功");
                WFCCAddFriendMessageContent *content = [WFCCAddFriendMessageContent contentWith:@"" desc:kLocalizedTableString(@"Other Request Add Friend", @"CPLocalizable") status:0 summary:kLocalizedTableString(@"MessageTypeAddFriend", @"CPLocalizable")];
                [self sendMessage:content];
                
            });
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"好友请求失败 error_code:%d", error_code);
                if (error_code == 16) {
                    [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Add Friend error 16", @"CPLocalizable")];
                }
            });
        }];
    }
}

- (void)setLoadingMore:(BOOL)loadingMore {
    _loadingMore = loadingMore;
    if (_loadingMore) {
        [self.headerActivityView startAnimating];
    } else {
        [self.headerActivityView stopAnimating];
    }
}

- (UIActivityIndicatorView *)headerActivityView {
    if (!_headerActivityView) {
        _headerActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _headerActivityView;
}

- (UIActivityIndicatorView *)footerActivityView {
    if (!_footerActivityView) {
        _footerActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _footerActivityView;
}

- (void)setLoadingNew:(BOOL)loadingNew {
    _loadingNew = loadingNew;
    if (loadingNew) {
        [self.footerActivityView startAnimating];
    } else {
        [self.footerActivityView stopAnimating];
    }
}

- (void)setHasNewMessage:(BOOL)hasNewMessage {
    _hasNewMessage = hasNewMessage;
    UICollectionViewFlowLayout *_customFlowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    if (hasNewMessage) {
        _customFlowLayout.footerReferenceSize = CGSizeMake(320.0f, 20.0f);
    } else {
        _customFlowLayout.footerReferenceSize = CGSizeZero;
    }
}

- (void)loadMoreMessage:(BOOL)isHistory {
    __weak typeof(self) weakSelf = self;
    if (isHistory) {
        if (self.loadingMore) {
            return;
        }
        self.loadingMore = YES;
        long lastIndex = 0;
        long long lastUid = 0;
        if (weakSelf.modelList.count) {
            lastIndex = [weakSelf.modelList firstObject].message.messageId;
            lastUid = [weakSelf.modelList firstObject].message.messageUid;
        }
        
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            NSArray *messageList = [[WFCCIMService sharedWFCIMService] getMessages:weakSelf.conversation contentTypes:nil from:lastIndex count:10 withUser:self.privateChatUser];
            if (!messageList.count) {
                [[WFCCIMService sharedWFCIMService] getRemoteMessages:weakSelf.conversation before:lastUid count:10 success:^(NSArray<WFCCMessage *> *messages) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!messages.count) {
                            weakSelf.hasMoreOld = NO;
                        } else {
                            [weakSelf appendMessages:messages newMessage:NO highlightId:0];
                        }
                        weakSelf.loadingMore = NO;
                    });
                } error:^(int error_code) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.hasMoreOld = NO;
                        weakSelf.loadingMore = NO;
                    });
                }];
            } else {
                [NSThread sleepForTimeInterval:0.5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf appendMessages:messageList newMessage:NO highlightId:0];
                    weakSelf.loadingMore = NO;
                });
            }
        });
        
        
    } else {
            if (weakSelf.loadingNew || !weakSelf.hasNewMessage) {
                return;
            }
            weakSelf.loadingNew = YES;
        
            long lastIndex = 0;
            if (self.modelList.count) {
                lastIndex = [self.modelList lastObject].message.messageId;
            }
        
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            NSArray *messageList = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:lastIndex count:-10 withUser:self.privateChatUser];
            if (!messageList.count || messageList.count < 10) {
                self.hasNewMessage = NO;
            }
            NSMutableArray *mutableMessages = [messageList mutableCopy];
            for (int i = 0; i < mutableMessages.count/2; i++) {
                int j = (int)mutableMessages.count - 1 - i;
                WFCCMessage *msg = [mutableMessages objectAtIndex:i];
                [mutableMessages insertObject:[mutableMessages objectAtIndex:j] atIndex:i];
                [mutableMessages removeObjectAtIndex:i+1];
                [mutableMessages insertObject:msg atIndex:j];
                [mutableMessages removeObjectAtIndex:j+1];
            }
            [NSThread sleepForTimeInterval:3];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf appendMessages:mutableMessages newMessage:YES highlightId:0];
                weakSelf.loadingNew = NO;
            });
        });
    }
}

- (void)sendChatroomWelcomeMessage {
    WFCCTipNotificationContent *tip = [[WFCCTipNotificationContent alloc] init];
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
    tip.tip = [NSString stringWithFormat:@"欢迎 %@ 加入聊天室", userInfo.displayName];
    [self sendMessage:tip];
}

- (void)sendChatroomLeaveMessage {
    __block WFCCConversation *strongConv = self.conversation;
    dispatch_async(dispatch_get_main_queue(), ^{
        WFCCTipNotificationContent *tip = [[WFCCTipNotificationContent alloc] init];
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
        tip.tip = [NSString stringWithFormat:@"%@ 离开了聊天室", userInfo.displayName];
        
        [[WFCCIMService sharedWFCIMService] send:strongConv content:tip success:^(long long messageUid, long long timestamp) {
            [[WFCCIMService sharedWFCIMService] quitChatroom:strongConv.target success:nil error:nil];
        } error:^(int error_code) {
            
        }];
    });
}

- (void)onLeftBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
    if(!parent){
        [self leftMessageVC];
    }
}

- (void)leftMessageVC {
    if (self.conversation.type == Chatroom_Type) {
        [self sendChatroomLeaveMessage];
    }
}

- (void)onRightBarBtn:(UIBarButtonItem *)sender {
//    WFCUConversationSettingViewController *gvc = [[WFCUConversationSettingViewController alloc] init];
//    gvc.conversation = self.conversation;
//    [self.navigationController pushViewController:gvc animated:YES];

}

- (void)setTargetUser:(WFCCUserInfo *)targetUser {
  _targetUser = targetUser;
    if(targetUser.friendAlias.length) {
        self.title = targetUser.friendAlias;
    } else if(targetUser.displayName.length == 0) {
        self.title = [NSString stringWithFormat:@"%@<%@>", kLocalizedTableString(@"user", @"CPLocalizable"), self.conversation.target];
    } else {
        if (targetUser.extra.length > 0) {
            self.title = targetUser.extra;
        }
        else {
            if ([[WFCCIMService sharedWFCIMService] isMyFriend:targetUser.userId]) {
                self.title = targetUser.displayName;
            }
            else {
                if ([targetUser.displayName containsString:@"stranger"]) {
                    self.title = targetUser.displayName;
                }
                else {
                    NSString *displayName = [targetUser.displayName substringToIndex:3];
                    self.title = [NSString stringWithFormat:@"%@...", displayName];
                }
            }
        }
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem.title = self.title;
}
  
- (void)setTargetGroup:(WFCCGroupInfo *)targetGroup {
  _targetGroup = targetGroup;
    if(targetGroup.name.length == 0) {
        self.title = [NSString stringWithFormat:@"群组<%@>", self.conversation.target];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = @"消息";
    } else {
        self.title = [NSString stringWithFormat:@"%@(%d)", targetGroup.name, (int)targetGroup.memberCount];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = targetGroup.name;
  }
}

- (void)setTargetChannel:(WFCCChannelInfo *)targetChannel {
    _targetChannel = targetChannel;
    if(targetChannel.name.length == 0) {
        self.title = [NSString stringWithFormat:@"频道<%@>", self.conversation.target];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = @"消息";
    } else {
        self.title = targetChannel.name;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = targetChannel.name;
    }
}

- (void)setTargetChatroom:(WFCCChatroomInfo *)targetChatroom {
    _targetChatroom = targetChatroom;
    if(targetChatroom.title.length == 0) {
        self.title = [NSString stringWithFormat:@"聊天室<%@>", self.conversation.target];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = @"消息";
    } else {
        self.title = targetChatroom.title;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = targetChatroom.title;
    }
}

- (void)setShowAlias:(BOOL)showAlias {
    _showAlias = showAlias;
    if (self.modelList) {
        for (WFCUMessageModel *model in self.modelList) {
            if (showAlias && model.message.direction == MessageDirection_Receive) {
                model.showNameLabel = YES;
            } else {
                model.showNameLabel = NO;
            }
        }
    }
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
  self.targetUser = notification.userInfo[@"userInfo"];
}
  
- (void)onGroupInfoUpdated:(NSNotification *)notification {
  self.targetGroup = notification.userInfo[@"groupInfo"];
}

- (void)onChannelInfoUpdated:(NSNotification *)notification {
//    self.targetGroup = notification.userInfo[@"groupInfo"];
    self.targetChannel = notification.userInfo[@"channelInfo"];
}

- (void)scrollToBottom:(BOOL)animated {

    NSUInteger rowCount = [self.collectionView numberOfItemsInSection:0];
    if (rowCount == 0) {
        return;
    }
    NSUInteger finalRow = rowCount - 1;
    
    for (int i = 0; i < self.modelList.count; i++) {
        if ([self.modelList objectAtIndex:i].highlighted) {
            finalRow = i;
            break;
        }
    }
    
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.collectionView scrollToItemAtIndexPath:finalIndexPath
                                atScrollPosition:UICollectionViewScrollPositionBottom
                                        animated:animated];

}

- (void)initializedSubViews {
    UICollectionViewFlowLayout *_customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _customFlowLayout.minimumLineSpacing = 0.0f;
    _customFlowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    _customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _customFlowLayout.headerReferenceSize = CGSizeMake(320.0f, 20.0f);
  
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = self.view.safeAreaInsets;
    }
    CGRect frame = self.view.bounds;
    frame.origin.y += kStatusBarAndNavigationBarHeight;
    frame.size.height -= (kTabbarSafeBottomMargin + kStatusBarAndNavigationBarHeight);
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:self.backgroundView];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.bounds.size.width, self.backgroundView.bounds.size.height - CHAT_INPUT_BAR_HEIGHT) collectionViewLayout:_customFlowLayout];

    [self.backgroundView addSubview:self.collectionView];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        self.backgroundView.backgroundColor = dyColor;
        self.view.backgroundColor = dyColor;
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];

        self.collectionView.backgroundColor = dyColor2;
        
        
    } else {
        // Fallback on earlier versions
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    

    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    
    
    [self registerCell:[WFCUTextCell class] forContent:[WFCCTextMessageContent class]];
    [self registerCell:[WFCUImageCell class] forContent:[WFCCImageMessageContent class]];
    [self registerCell:[WFCUVoiceCell class] forContent:[WFCCSoundMessageContent class]];
    [self registerCell:[WFCUVideoCell class] forContent:[WFCCVideoMessageContent class]];
    [self registerCell:[WFCULocationCell class] forContent:[WFCCLocationMessageContent class]];
    [self registerCell:[WFCUFileCell class] forContent:[WFCCFileMessageContent class]];
    [self registerCell:[WFCUStickerCell class] forContent:[WFCCStickerMessageContent class]];
    
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCCreateGroupNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCAddGroupeMemberNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCKickoffGroupMemberNotificaionContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCQuitGroupNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCDismissGroupNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCTransferGroupOwnerNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCModifyGroupAliasNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCChangeGroupNameNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCChangeGroupPortraitNotificationContent class]];
    [self registerCell:[WFCUCallSummaryCell class] forContent:[WFCCCallStartMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCTipNotificationContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCContractAttitudeTipPushNotificationMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCContractHasSendMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCRidingStatusNotificationMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCUnknownMessageContent class]];
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCRecallMessageContent class]];
    
    // add friend
    [self registerCell:[WFCUAddFriendCell class] forContent:[WFCCAddFriendMessageContent class]];
    // contract
    [self registerCell:[WFCUContractMessageCell class] forContent:[WFCCContractMessageContent class]];
    
    // realtime locaiton tip
    [self registerCell:[WFCUInformationCell class] forContent:[WFCCRealtimeLocationNotificationMessageContent class]];
    
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)registerCell:(Class)cellCls forContent:(Class)msgContentCls {
    [self.collectionView registerClass:cellCls
            forCellWithReuseIdentifier:[NSString stringWithFormat:@"%d", [msgContentCls getContentType]]];
    [self.cellContentDict setObject:cellCls forKey:@([msgContentCls getContentType])];
}

- (void)showTyping:(WFCCTypingType)typingType {
    if (self.showTypingTimer) {
        [self.showTypingTimer invalidate];
    }
    
    self.showTypingTimer = [NSTimer timerWithTimeInterval:TYPING_INTERVAL/2 target:self selector:@selector(stopShowTyping) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.showTypingTimer forMode:NSDefaultRunLoopMode];
    if (typingType == Typing_TEXT) {
        self.title = @"对方正在输入...";
    } else if(typingType == Typing_VOICE) {
        self.title = @"对方正在录音...";
    } else if(typingType == Typing_CAMERA) {
        self.title = @"对方正在拍照...";
    } else if(typingType == Typing_LOCATION) {
        self.title = @"对方正在选取位置...";
    } else if(typingType == Typing_FILE) {
        self.title = @"对方正在选取文件...";
    }
    
}

- (void)stopShowTyping {
    if(self.showTypingTimer != nil) {
        [self.showTypingTimer invalidate];
        self.showTypingTimer = nil;
        if (self.conversation.type == Single_Type) {
            self.targetUser = self.targetUser;
        } else if(self.conversation.type == Group_Type) {
            self.targetGroup = self.targetGroup;
        } else if(self.conversation.type == Channel_Type) {
            self.targetChannel = self.targetChannel;
        } else if(self.conversation.type == Group_Type) {
            self.targetGroup = self.targetGroup;
        }
    }
}

- (void)onResetKeyboard:(id)sender {
  [self.chatInputBar resetInputBarStatue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    if(self.conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:YES];
        self.targetUser = userInfo;
    } else if(self.conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:YES];
        self.targetGroup = groupInfo;
    } else if (self.conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:YES];
        self.targetChannel = channelInfo;
    } else if(self.conversation.type == Chatroom_Type) {
        __weak typeof(self)ws = self;
        [[WFCCIMService sharedWFCIMService] getChatroomInfo:self.conversation.target upateDt:ws.targetChatroom.updateDt success:^(WFCCChatroomInfo *chatroomInfo) {
            ws.targetChatroom = chatroomInfo;
        } error:^(int error_code) {
            
        }];
    }
    
  self.tabBarController.tabBar.hidden = YES;
    [self.collectionView reloadData];
    
    if (self.navigationController.viewControllers.count > 1) {          // 记录系统返回手势的代理
        _scrollBackDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;          // 设置系统返回手势的代理为当前控制器
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (self.conversation.type == Group_Type) {
        self.showAlias = ![[WFCCIMService sharedWFCIMService] isHiddenGroupMemberName:self.targetGroup.target];
    }
    
    if (self.firstAppear) {
        self.firstAppear = NO;
        [self scrollToBottom:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
    NSString *newDraft = self.chatInputBar.draft;
    if (![self.orignalDraft isEqualToString:newDraft]) {
        self.orignalDraft = newDraft;
        [[WFCCIMService sharedWFCIMService] setConversation:self.conversation draft:newDraft];
    }
    // 设置系统返回手势的代理为我们刚进入控制器的时候记录的系统的返回手势代理
    self.navigationController.interactivePopGestureRecognizer.delegate = _scrollBackDelegate;
    
    [self.chatInputBar resetInputBarStatue];
}


- (void)sendMessage:(WFCCMessageContent *)content {
    //发送消息时，client会发出"kSendingMessageStatusUpdated“的通知，消息界面收到通知后加入到列表中。
    __weak typeof(self) ws = self;
    NSMutableArray *tousers = nil;
    if (self.privateChatUser) {
        tousers = [[NSMutableArray alloc] init];
        [tousers addObject:self.privateChatUser];
    }
    [[WFCCIMService sharedWFCIMService] send:self.conversation content:content toUsers:tousers expireDuration:0 success:^(long long messageUid, long long timestamp) {
        NSLog(@"send message success");
        if ([content isKindOfClass:[WFCCStickerMessageContent class]]) {
            [ws saveStickerRemoteUrl:(WFCCStickerMessageContent *)content];
        }
    } error:^(int error_code) {
        NSLog(@"send message fail(%d)", error_code);
    }];
}

- (void)onReceiveMessages:(NSNotification *)notification {
    NSArray<WFCCMessage *> *messages = notification.object;
    [self appendMessages:messages newMessage:YES highlightId:0];
    [[WFCCIMService sharedWFCIMService] clearUnreadStatus:self.conversation];
}

- (void)onRecallMessages:(NSNotification *)notification {
    long long messageUid = [notification.object longLongValue];
    WFCCMessage *msg = [[WFCCIMService sharedWFCIMService] getMessageByUid:messageUid];
    if (msg != nil) {
        for (int i = 0; i < self.modelList.count; i++) {
            WFCUMessageModel *model = [self.modelList objectAtIndex:i];
            if (model.message.messageUid == messageUid) {
                model.message = msg;
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                break;
            }
        }
    }
}

- (void)onSendingMessage:(NSNotification *)notification {
    WFCCMessage *message = [notification.userInfo objectForKey:@"message"];
    WFCCMessageStatus status = [[notification.userInfo objectForKey:@"status"] integerValue];
    if (status == Message_Status_Sending) {
        if ([message.conversation isEqual:self.conversation]) {
            [self appendMessages:@[message] newMessage:YES highlightId:0];
        }
    }
    
}

- (void)onMessageListChanged:(NSNotification *)notification {
    [self reloadMessageList];
}

- (void)reloadMessageList {
    NSArray *messageList;
    if (self.highlightMessageId > 0) {
        NSArray *messageListOld = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:self.highlightMessageId+1 count:15 withUser:self.privateChatUser];
        NSArray *messageListNew = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:self.highlightMessageId count:-15 withUser:self.privateChatUser];
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [list addObjectsFromArray:messageListNew];
        [list addObjectsFromArray:messageListOld];
        messageList = [list copy];
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:self.conversation];
        if (messageListNew.count == 15) {
            self.hasNewMessage = YES;
        }
    } else {
        messageList = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:nil from:0 count:15 withUser:self.privateChatUser];
        [[WFCCIMService sharedWFCIMService] clearUnreadStatus:self.conversation];
    }
    
    self.modelList = [[NSMutableArray alloc] init];
    
    [self appendMessages:messageList newMessage:NO highlightId:self.highlightMessageId];
    self.highlightMessageId = 0;
}

- (void)appendMessages:(NSArray<WFCCMessage *> *)messages newMessage:(BOOL)newMessage highlightId:(long)highlightId {
    if (messages.count == 0) {
        return;
    }
  
    int count = 0;
    for (int i = 0; i < messages.count; i++) {
        WFCCMessage *message = [messages objectAtIndex:i];
        
        if (![message.conversation isEqual:self.conversation]) {
            continue;
        }
        
        // add friend text is empty
        if ([message.content isKindOfClass:[WFCCTextMessageContent class]]) {
            WFCCTextMessageContent *content = (WFCCTextMessageContent *)message.content;
            if (content.text.length == 0) {
                continue;
            }
        }
        
        if ([message.content isKindOfClass:[WFCCTypingMessageContent class]] && message.direction == MessageDirection_Receive) {
            double now = [[NSDate date] timeIntervalSince1970];
            if (now - message.serverTime + [WFCCNetworkService sharedInstance].serverDeltaTime < TYPING_INTERVAL) {
                WFCCTypingMessageContent *content = (WFCCTypingMessageContent *)message.content;
                [self showTyping:content.type];
            }
            continue;
        }
        
        if (!([message.content.class getContentFlags] & 0x1)) {
            continue;
        }
        BOOL duplcated = NO;
        for (WFCUMessageModel *model in self.modelList) {
            if (model.message.messageUid !=0 && model.message.messageUid == message.messageUid) {
                duplcated = YES;
                break;
            }
        }
        if (duplcated) {
            continue;
        }
        
        count++;
        
        if (newMessage) {
            BOOL showTime = YES;
            if (self.modelList.count > 0 && (message.serverTime -  (self.modelList[self.modelList.count - 1]).message.serverTime < 60 * 1000)) {
                showTime = NO;
            }
            WFCUMessageModel *model = [WFCUMessageModel modelOf:message showName:message.direction == MessageDirection_Receive && self.showAlias showTime:showTime];
            if (highlightId > 0 && message.messageId == highlightId) {
                model.highlighted = YES;
            }
            [self.modelList addObject:model];
            
        } else {
            if (self.modelList.count > 0 && (self.modelList[0].message.serverTime - message.serverTime < 60 * 1000) && i != 0) {
                self.modelList[0].showTimeLabel = NO;
            }
            WFCUMessageModel *model = [WFCUMessageModel modelOf:message showName:message.direction == MessageDirection_Receive&&self.showAlias showTime:YES];
            if (highlightId > 0 && message.messageId == highlightId) {
                model.highlighted = YES;
            }
            [self.modelList insertObject:model atIndex:0];
        }
    }
    
    if (count > 0) {
        [self stopShowTyping];
    }
    
    BOOL isAtButtom = NO;
    if (newMessage) {
        if (@available(iOS 12.0, *)) {
            CGPoint offset = self.collectionView.contentOffset;
            CGSize size = self.collectionView.contentSize;
            CGSize visiableSize = CGSizeZero;
            visiableSize = self.collectionView.visibleSize;
            isAtButtom = (offset.y + visiableSize.height - size.height) > -100;
        } else {
            isAtButtom = YES;
        }
    }
    
  [self.collectionView reloadData];
    if (newMessage || self.modelList.count == messages.count) {
        if(isAtButtom) {
            [self scrollToBottom:YES];
        }
    } else {
        CGFloat offset = 0;
        for (int i = 0; i < count; i++) {
            CGSize size = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            offset += size.height;
        }
        self.collectionView.contentOffset = CGPointMake(0, offset);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.collectionView.contentOffset = CGPointMake(0, offset - 20);
        }];
    }
}

- (WFCUMessageModel *)modelOfMessage:(long)messageId {
    if (messageId <= 0) {
        return nil;
    }
    for (WFCUMessageModel *model in self.modelList) {
        if (model.message.messageId == messageId) {
            return model;
        }
    }
    return nil;
}

- (void)stopPlayer {
    if (self.player && [self.player isPlaying]) {
        [self.player stop];
        if ([self.playTimer isValid]) {
            [self.playTimer invalidate];
            self.playTimer = nil;
        }
    }
    [self modelOfMessage:self.playingMessageId].voicePlaying = NO;
    self.playingMessageId = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kVoiceMessagePlayStoped object:nil];
}

-(void)prepardToPlay:(WFCUMessageModel *)model {

    if (self.playingMessageId == model.message.messageId) {
        [self stopPlayer];
    } else {
        [self stopPlayer];
        
        self.playingMessageId = model.message.messageId;
        
        WFCCSoundMessageContent *soundContent = (WFCCSoundMessageContent *)model.message.content;
        if (soundContent.localPath.length == 0) {
            model.mediaDownloading = YES;
            __weak typeof(self) weakSelf = self;
            
            [[WFCUMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
                model.mediaDownloading = NO;
                [weakSelf startPlay:model];
            } error:^(long long messageUid, int error_code) {
                model.mediaDownloading = NO;
            }];
            
        } else {
            [self startPlay:model];
        }
        
    }
}

-(void)startPlay:(WFCUMessageModel *)model {
    
    if ([model.message.content isKindOfClass:[WFCCSoundMessageContent class]]) {
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                   error:nil];
        
        
        WFCCSoundMessageContent *snc = (WFCCSoundMessageContent *)model.message.content;
        NSError *error = nil;
        self.player = [[AVAudioPlayer alloc] initWithData:[snc getWavData] error:&error];
        [self.player setDelegate:self];
        [self.player prepareToPlay];
        [self.player play];
        model.voicePlaying = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVoiceMessageStartPlaying object:@(self.playingMessageId)];
    } else if([model.message.content isKindOfClass:[WFCCVideoMessageContent class]]) {
        WFCCVideoMessageContent *videoMsg = (WFCCVideoMessageContent *)model.message.content;
        NSURL *url = [NSURL fileURLWithPath:videoMsg.localPath];
        
        if (!self.videoPlayerViewController) {
            self.videoPlayerViewController = [VideoPlayerKit videoPlayerWithContainingView:self.view optionalTopView:nil hideTopViewWithControls:YES];
//            self.videoPlayerViewController.delegate = self;
            self.videoPlayerViewController.allowPortraitFullscreen = YES;
        } else {
            [self.videoPlayerViewController.view removeFromSuperview];
        }
        
        [self.view addSubview:self.videoPlayerViewController.view];
        
        [self.videoPlayerViewController playVideoWithTitle:@" " URL:url videoID:nil shareURL:nil isStreaming:NO playInFullScreen:YES];
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.modelList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
  WFCUMessageModel *model = self.modelList[indexPath.row];
  NSString *objName = [NSString stringWithFormat:@"%d", [model.message.content.class getContentType]];
  
  WFCUMessageCellBase *cell = nil;
  if(![self.cellContentDict objectForKey:@([model.message.content.class getContentType])]) {
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%d", [WFCCUnknownMessageContent getContentType]] forIndexPath:indexPath];
  } else {
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:objName forIndexPath:indexPath];
  }
  
  cell.delegate = self;
    
  [[NSNotificationCenter defaultCenter] removeObserver:cell];
  cell.model = model;
  
  return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(!self.headerView) {
            self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            self.headerActivityView.center = CGPointMake(self.headerView.bounds.size.width/2, self.headerView.bounds.size.height/2);
            [self.headerView addSubview:self.headerActivityView];
        }
        return self.headerView;
    } else {
        if(!self.footerView) {
            self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
            self.footerActivityView.center = CGPointMake(self.footerView.bounds.size.width/2, self.footerView.bounds.size.height/2);
            [self.footerView addSubview:self.footerActivityView];
        }
        return self.footerView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  WFCUMessageModel *model = self.modelList[indexPath.row];
    Class cellCls = self.cellContentDict[@([[model.message.content class] getContentType])];
  if (!cellCls) {
    cellCls = self.cellContentDict[@([[WFCCUnknownMessageContent class] getContentType])];
  }
  return [cellCls sizeForCell:model withViewWidth:self.collectionView.frame.size.width];
}

#pragma mark - MessageCellDelegate
- (void)didTapMessageCell:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if ([model.message.content isKindOfClass:[WFCCImageMessageContent class]]) {
        self.imageMsgs = [[WFCCIMService sharedWFCIMService] getMessages:self.conversation contentTypes:@[@(MESSAGE_CONTENT_TYPE_IMAGE)] from:0 count:100 withUser:self.privateChatUser];
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.sourceImagesContainerView = self.backgroundView;
        
        browser.imageCount = self.imageMsgs.count;
        int i;
        for (i = 0; i < self.imageMsgs.count; i++) {
            if ([self.imageMsgs objectAtIndex:i].messageId == model.message.messageId) {
                break;
            }
        }
        if (i == self.imageMsgs.count) {
            i = 0;
        }
        browser.currentImageIndex = i;
        browser.delegate = self;
        [browser show]; // 展示图片浏览器
        
    } else if([model.message.content isKindOfClass:[WFCCSoundMessageContent class]]) {
        if (model.message.direction == MessageDirection_Receive && model.message.status != Message_Status_Played) {
            [[WFCCIMService sharedWFCIMService] setMediaMessagePlayed:model.message.messageId];
            model.message.status = Message_Status_Played;
            [self.collectionView reloadItemsAtIndexPaths:@[[self.collectionView indexPathForCell:cell]]];
        }
        
        [self prepardToPlay:model];
        
    } else if([model.message.content isKindOfClass:[WFCCLocationMessageContent class]]) {
      WFCCLocationMessageContent *locContent = (WFCCLocationMessageContent *)model.message.content;
        
        SSChatMapController *vc = [SSChatMapController new];
        vc.latitude = locContent.coordinate.latitude;
        vc.longitude = locContent.coordinate.longitude;
//        vc.addressName = layout.chatMessage.locationBody.address;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if ([model.message.content isKindOfClass:[WFCCFileMessageContent class]]) {
        WFCCFileMessageContent *fileContent = (WFCCFileMessageContent *)model.message.content;
        WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
        bvc.url = fileContent.remoteUrl;
        [self.navigationController pushViewController:bvc animated:YES];
    } else if ([model.message.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
        WFCCCallStartMessageContent *callStartMsg = (WFCCCallStartMessageContent *)model.message.content;
#if WFCU_SUPPORT_VOIP
        [self didTouchVideoBtn:callStartMsg.isAudioOnly];
#endif
    } else if([model.message.content isKindOfClass:[WFCCVideoMessageContent class]]) {
        WFCCVideoMessageContent *videoMsg = (WFCCVideoMessageContent *)model.message.content;
        if (model.message.direction == MessageDirection_Receive && model.message.status != Message_Status_Played) {
            [[WFCCIMService sharedWFCIMService] setMediaMessagePlayed:model.message.messageId];
            model.message.status = Message_Status_Played;
            [self.collectionView reloadItemsAtIndexPaths:@[[self.collectionView indexPathForCell:cell]]];
        }
        
        if (videoMsg.localPath.length == 0) {
            model.mediaDownloading = YES;
            __weak typeof(self) weakSelf = self;
            
            [[WFCUMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
                model.mediaDownloading = NO;
                [weakSelf startPlay:model];
            } error:^(long long messageUid, int error_code) {
                model.mediaDownloading = NO;
            }];
        } else {
            [self startPlay:model];
        }
        
    }
    else if ([model.message.content isKindOfClass:[WFCCAddFriendMessageContent class]]) {
//        WFCCAddFriendMessageContent *content = (WFCCFileMessageContent *)model.message.content;
    }
}

- (void)didTapMessagePortrait:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
//  WFCUProfileTableViewController *vc = [[WFCUProfileTableViewController alloc] init];
//  vc.userId = model.message.fromUser;
//  vc.hidesBottomBarWhenPushed = YES;
//  [self.navigationController pushViewController:vc animated:YES];
    NSLog(@"didTapMessagePortrait");
}

- (void)didLongPressMessageCell:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if ([cell isKindOfClass:[WFCUMessageCellBase class]]) {
        [self becomeFirstResponder];
        [self displayMenu:(WFCUMessageCellBase *)cell];
    }
}

- (void)didLongPressMessagePortrait:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model {
    if (self.conversation.type == Group_Type) {
        if (model.message.direction == MessageDirection_Receive) {
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:model.message.fromUser refresh:NO];
            [self.chatInputBar appendMention:model.message.fromUser name:sender.displayName];
        }
    } else if(self.conversation.type == Channel_Type) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"与订阅者私聊" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (model.message.direction == MessageDirection_Receive) {
                WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
                if ([channelInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
                    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                    mvc.conversation = [WFCCConversation conversationWithType:self.conversation.type target:self.conversation.target line:self.conversation.line];
                    mvc.privateChatUser = model.message.fromUser;
                    [self.navigationController pushViewController:mvc animated:YES];
                }
            }

        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (void)didTapResendBtn:(WFCUMessageModel *)model {
    NSInteger index = [self.modelList indexOfObject:model];
    if (index >= 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.modelList removeObjectAtIndex:index];
        [self.collectionView deleteItemsAtIndexPaths:@[path]];
        [[WFCCIMService sharedWFCIMService] deleteMessage:model.message.messageId];
        [self sendMessage:model.message.content];
    }
}

- (void)didSelectUrl:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model withUrl:(NSString *)urlString {
    WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
    bvc.url = urlString;
    [self.navigationController pushViewController:bvc animated:YES];
}

- (void)didSelectPhoneNumber:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model withPhoneNumber:(NSString *)phoneNumber {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"我猜%@是一个电话号码", phoneNumber] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"telprompt:%@", phoneNumber]];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制号码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = phoneNumber;
    }];
    
//    UIAlertAction *addContactAction = [UIAlertAction actionWithTitle:@"添加到通讯录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//
//    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:callAction];
    [alertController addAction:copyAction];
//    [alertController addAction:addContactAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - 同意或忽略好友请求
- (void)didAddFriend:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model withAgree:(BOOL)agree{
    NSLog(@"WFCUMessageListViewController didAddFriend agree:%d", agree);
    
    if (agree) {
        [[WFCCIMService sharedWFCIMService] handleFriendRequest:self.conversation.target accept:agree success:^{
            
            WFCCAddFriendMessageContent *content = (WFCCAddFriendMessageContent*)model.message.content;
            content.status = 1;
            
            // update message
            [[WFCCIMService sharedWFCIMService] updateMessage:model.message.messageId content:content];
            
            [self.collectionView reloadItemsAtIndexPaths:@[[self.collectionView indexPathForCell:cell]]];
            
            
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
        
        
    }
    else {
        NSLog(@"WFCUMessageListViewController didAddFriend 忽略好友请求");
        WFCCAddFriendMessageContent *content = (WFCCAddFriendMessageContent*)model.message.content;
        content.status = 2;
        
        // update message
        [[WFCCIMService sharedWFCIMService] updateMessage:model.message.messageId content:content];
        
        [self.collectionView reloadItemsAtIndexPaths:@[[self.collectionView indexPathForCell:cell]]];
    }
}

#pragma mark - 同意或拒绝合约
- (void)didDealContract:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model withAgree:(BOOL)agree{
    
    WFCCContractMessageContent *content = (WFCCContractMessageContent*)model.message.content;
    
    WS(weakSelf)
    NSInteger contractId = content.contractId;
    NSString *tipText = @"";
    
    if (agree) {
        NSLog(@"WFCUMessageListViewController didDealContract 同意合约");
        content.status = 1;
        tipText = kLocalizedTableString(@"Already Agree Contract", @"CPLocalizable");
        
        if (content.contractType == 0) {
            [self setupShortTermNotificationByDataid:content.contractId contractType:content.contractType beginTime:content.beginTime];
        }
        else if (content.contractType == 1) {
            [self setupLongTermNotificationsByDataid:content.contractId contractType:content.contractType beginTime:content.beginTime endTime:content.endTime endDate:content.endDate weekNum:content.weekNum];
        }
        
        //
        [self requestAcceptContractByContractId:contractId complete:^(BOOL success) {
            NSLog(@"CPStrangerChatVC requestAcceptContractByContractId success:%d", success);
            if (success) {
                // update message
                [[WFCCIMService sharedWFCIMService] updateMessage:model.message.messageId content:content];
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[weakSelf.collectionView indexPathForCell:cell]]];
                
                //
                WFCCContractAttitudeTipPushNotificationMessageContent *tipPushNotificationContent = [[WFCCContractAttitudeTipPushNotificationMessageContent alloc] init];
                tipPushNotificationContent.tip = tipText;
                tipPushNotificationContent.contractId = contractId;
                tipPushNotificationContent.beginTime = content.beginTime;
                tipPushNotificationContent.endTime = content.endTime;
                tipPushNotificationContent.endDate = content.endDate;
                tipPushNotificationContent.weekNum = content.weekNum;
                tipPushNotificationContent.contractType = content.contractType;
                tipPushNotificationContent.contractAttitude = content.status;
                [weakSelf sendMessage:tipPushNotificationContent];
            }
        }];
        
    }
    else {
        NSLog(@"WFCUMessageListViewController didDealContract 拒绝合约");
        content.status = 2;
        tipText = kLocalizedTableString(@"Already Reject Contract", @"CPLocalizable");
        
        
        // update message
        [[WFCCIMService sharedWFCIMService] updateMessage:model.message.messageId content:content];
        
        [weakSelf.collectionView reloadItemsAtIndexPaths:@[[weakSelf.collectionView indexPathForCell:cell]]];
        
        //
        WFCCContractAttitudeTipPushNotificationMessageContent *tipPushNotificationContent = [[WFCCContractAttitudeTipPushNotificationMessageContent alloc] init];
        tipPushNotificationContent.tip = tipText;
        tipPushNotificationContent.contractId = contractId;
        tipPushNotificationContent.beginTime = content.beginTime;
        tipPushNotificationContent.endTime = content.endTime;
        tipPushNotificationContent.endDate = content.endDate;
        tipPushNotificationContent.weekNum = content.weekNum;
        tipPushNotificationContent.contractType = content.contractType;
        tipPushNotificationContent.contractAttitude = content.status;
        [weakSelf sendMessage:tipPushNotificationContent];
    }
}


#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player finished");
    [self stopPlayer];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
    [[[UIAlertView alloc] initWithTitle:@"警告" message:@"网络错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    [self stopPlayer];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.chatInputBar resetInputBarStatue];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.hasNewMessage && targetContentOffset->y == (scrollView.contentSize.height - scrollView.bounds.size.height)) {
        [self loadMoreMessage:NO];
    }
    if (targetContentOffset->y == 0 && self.hasMoreOld) {
        [self loadMoreMessage:YES];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {


}

#pragma mark - ChatInputBarDelegate
- (void)imageDidCapture:(UIImage *)capturedImage {
    if (!capturedImage) {
        return;
    }
    
    WFCCImageMessageContent *imgContent = [WFCCImageMessageContent contentFrom:capturedImage];
    [self sendMessage:imgContent];
}

- (void)videoDidCapture:(NSString *)videoPath thumbnail:(UIImage *)image duration:(long)duration {
    WFCCVideoMessageContent *videoContent = [WFCCVideoMessageContent contentPath:videoPath thumbnail:image];
    [self sendMessage:videoContent];
}

- (void)didTouchSend:(NSString *)stringContent withMentionInfos:(NSMutableArray<WFCUMetionInfo *> *)mentionInfos {
  if (stringContent.length == 0) {
    return;
  }
  
    WFCCTextMessageContent *txtContent = [[WFCCTextMessageContent alloc] init];
    txtContent.text = stringContent;
    NSMutableArray *mentionTargets = [[NSMutableArray alloc] init];
    for (WFCUMetionInfo *mentionInfo in mentionInfos) {
        if (mentionInfo.mentionType == 2) {
            txtContent.mentionedType = 2;
            mentionTargets = nil;
            break;
        } else if(mentionInfo.mentionType == 1) {
            txtContent.mentionedType = 1;
            [mentionTargets addObject:mentionInfo.target];
        }
    }
    if (txtContent.mentionedType == 1) {
        txtContent.mentionedTargets = [mentionTargets copy];
    }
    
    [self sendMessage:txtContent];
}

- (void)recordDidEnd:(NSString *)dataUri duration:(long)duration error:(NSError *)error {
    [self sendMessage:[WFCCSoundMessageContent soundMessageContentForWav:dataUri duration:duration]];
}

- (void)willChangeFrame:(CGRect)newFrame withDuration:(CGFloat)duration keyboardShowing:(BOOL)keyboardShowing {
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.collectionView.frame;
        CGFloat diff = MIN(frame.size.height, self.collectionView.contentSize.height) - newFrame.origin.y;
        if(diff > 0) {
            frame.origin.y = -diff;
            self.collectionView.frame = frame;
        } else {
            self.collectionView.frame = CGRectMake(0, 0, self.backgroundView.bounds.size.width, newFrame.origin.y);
        }
    } completion:^(BOOL finished) {
        self.collectionView.frame = CGRectMake(0, 0, self.backgroundView.bounds.size.width, newFrame.origin.y);
        
        if (keyboardShowing) {
            [self scrollToBottom:NO];
        }
    }];
}

- (UINavigationController *)requireNavi {
    return self.navigationController;
}


- (void)didSelectFiles:(NSArray *)files {
    for (NSString *file in files) {
        WFCCFileMessageContent *content = [WFCCFileMessageContent fileMessageContentFromPath:file];
        [self sendMessage:content];
        [NSThread sleepForTimeInterval:0.05];
    }
}

// location
- (void)didSelectLocation{
    SSChatLocationController *vc = [SSChatLocationController new];
    vc.showType = SSChatLocationVCShowTypeChat;
    vc.locationBlock = ^(NSDictionary *locationDict, WFCULocationPoint *point) {
        // 发送位置
        WFCCLocationMessageContent *content = [WFCCLocationMessageContent contentWith:point.coordinate title:point.title thumbnail:point.thumbnail address:locationDict[@"address"] addressName:locationDict[@"addressName"] thoroughfare:locationDict[@"thoroughfare"] subThoroughfare:locationDict[@"subThoroughfare"] locality:locationDict[@"locality"] subLocality:locationDict[@"subLocality"] administrativeArea:locationDict[@"administrativeArea"] subAdministrativeArea:locationDict[@"subAdministrativeArea"] status:0];
        [self sendMessage:content];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

// contract
- (void)didSelectContract {
    // contract
    NSLog(@"didSelectContract contract");
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        [self setupAlertView];
    }
    else {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
    }
}

- (void)saveStickerRemoteUrl:(WFCCStickerMessageContent *)stickerContent {
    if (stickerContent.localPath.length && stickerContent.remoteUrl.length) {
        [[NSUserDefaults standardUserDefaults] setObject:stickerContent.remoteUrl forKey:[NSString stringWithFormat:@"sticker_remote_for_%ld", stickerContent.localPath.hash]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didSelectSticker:(NSString *)stickerPath {
    WFCCStickerMessageContent * content = [WFCCStickerMessageContent contentFrom:stickerPath];
    NSString *remoteUrl = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"sticker_remote_for_%ld", stickerPath.hash]];
    content.remoteUrl = remoteUrl;
    
    [self sendMessage:content];
}


#if WFCU_SUPPORT_VOIP
- (void)didTouchVideoBtn:(BOOL)isAudioOnly {
    if(self.conversation.type == Single_Type) {
        WFCUVideoViewController *videoVC = [[WFCUVideoViewController alloc] initWithTarget:self.conversation.target conversation:self.conversation audioOnly:isAudioOnly];
        [[WFAVEngineKit sharedEngineKit] presentViewController:videoVC];
    } else {
      WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
      pvc.selectContact = YES;
      pvc.multiSelect = YES;
      NSMutableArray *disabledUser = [[NSMutableArray alloc] init];
      [disabledUser addObject:[WFCCNetworkService sharedInstance].userId];
      pvc.disableUsers = disabledUser;
      NSMutableArray *candidateUser = [[NSMutableArray alloc] init];
      NSArray<WFCCGroupMember *> *members = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
      for (WFCCGroupMember *member in members) {
        [candidateUser addObject:member.memberId];
      }
      pvc.candidateUsers = candidateUser;
      __weak typeof(self)ws = self;
      pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        if (contacts.count == 1) {
          WFCUVideoViewController *videoVC = [[WFCUVideoViewController alloc] initWithTarget:[contacts objectAtIndex:0] conversation:ws.conversation audioOnly:isAudioOnly];
          [[WFAVEngineKit sharedEngineKit] presentViewController:videoVC];
        }
      };
      pvc.disableUsersSelected = YES;
      
      UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
      [self.navigationController presentViewController:navi animated:YES completion:nil];
    }
}
#endif

- (void)onTyping:(WFCCTypingType)type {
    if (self.conversation.type == Single_Type) {
        [self sendMessage:[WFCCTypingMessageContent contentType:type]];
    }
}


#pragma mark - SDPhotoBrowserDelegate
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    WFCCMessage *msg = [self.imageMsgs objectAtIndex:index];
    if ([[msg.content class] getContentType] == MESSAGE_CONTENT_TYPE_IMAGE) {
        WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)msg.content;
        return imgContent.thumbnail;
    }
    return nil;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    WFCCMessage *msg = [self.imageMsgs objectAtIndex:index];
    if ([[msg.content class] getContentType] == MESSAGE_CONTENT_TYPE_IMAGE) {
        WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)msg.content;
        return [NSURL URLWithString:imgContent.remoteUrl];
    }
    return nil;
}

- (void)photoBrowserDidDismiss:(SDPhotoBrowser *)browser {
    self.imageMsgs = nil;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.childViewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}


#pragma mark - menu
- (void)displayMenu:(WFCUMessageCellBase *)baseCell {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:kLocalizedTableString(@"Delete", @"CPLocalizable") action:@selector(performDelete:)];
    UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:kLocalizedTableString(@"Copy", @"CPLocalizable") action:@selector(performCopy:)];
//    UIMenuItem *forwardItem = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(performForward:)];
    UIMenuItem *recallItem = [[UIMenuItem alloc]initWithTitle:kLocalizedTableString(@"Recall", @"CPLocalizable") action:@selector(performRecall:)];
    
    CGRect menuPos;
    if ([baseCell isKindOfClass:[WFCUMessageCell class]]) {
        WFCUMessageCell *msgCell = (WFCUMessageCell *)baseCell;
        menuPos = msgCell.bubbleView.frame;
    } else {
        menuPos = baseCell.frame;
    }
    
    [menu setTargetRect:menuPos inView:baseCell];
    WFCCMessage *msg = baseCell.model.message;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:deleteItem];
    if ([msg.content isKindOfClass:[WFCCTextMessageContent class]]) {
        [items addObject:copyItem];
    }
    
    if ([msg.content isKindOfClass:[WFCCImageMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCTextMessageContent class]] ||
//        [msg.content isKindOfClass:[WFCCLocationMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCFileMessageContent class]] ||
        [msg.content isKindOfClass:[WFCCVideoMessageContent class]] ||
//        [msg.content isKindOfClass:[WFCCSoundMessageContent class]] || //语音消息禁止转发，出于安全原因考虑，微信就禁止转发。如果您能确保安全，可以把这行注释打开
        [msg.content isKindOfClass:[WFCCStickerMessageContent class]]) {
        
//        [items addObject:forwardItem];
    }
    
    if ([msg.content isKindOfClass:[WFCCLocationMessageContent class]]) {
        UIMenuItem *collectItem = [[UIMenuItem alloc]initWithTitle:kLocalizedTableString(@"Collect", @"CPLocalizable") action:@selector(performCollect:)];
        [items addObject:collectItem];
    }
    
    BOOL canRecall = NO;
    if ([baseCell isKindOfClass:[WFCUMessageCell class]] &&
        msg.direction == MessageDirection_Send
        ) {
        NSDate *cur = [NSDate date];
        if ([cur timeIntervalSince1970]*1000 - msg.serverTime < 60 * 1000) {
            canRecall = YES;
        }
    }
    
    if (!canRecall && self.conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:NO];
        if([groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            canRecall = YES;
            if ([groupInfo.owner isEqualToString:msg.fromUser]) {
                canRecall = NO;
            }
        } else {
            __block BOOL isManager = false;
            NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
            [memberList enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
                    if (obj.type != Member_Type_Normal && ![msg.fromUser isEqualToString:obj.memberId]) {
                        isManager = YES;
                    }
                    *stop = YES;
                }
            }];
            if(isManager && ![msg.fromUser isEqualToString:groupInfo.owner]) {
                canRecall = YES;
            }
        }
    }
    
    if (canRecall) {
        [items addObject:recallItem];
    }
    
    [menu setMenuItems:items];
    self.cell4Menu = baseCell;
    
    [menu setMenuVisible:YES];
}


-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(self.cell4Menu) {
        if (action == @selector(performDelete:) || action == @selector(performCopy:) || action == @selector(performForward:) || action == @selector(performRecall:) || action == @selector(performCollect:)) {
            return YES; //显示自定义的菜单项
        } else {
            return NO;
        }
    }
    
    if (action == @selector(paste:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        return pasteboard.string != nil;
    }
    return NO;//[super canPerformAction:action withSender:sender];
}

- (void)paste:(id)sender {
    [self.chatInputBar paste:sender];
}

-(void)performDelete:(UIMenuController *)sender {
    [[WFCCIMService sharedWFCIMService] deleteMessage:self.cell4Menu.model.message.messageId];
    [self.modelList removeObject:self.cell4Menu.model];
    [self.collectionView deleteItemsAtIndexPaths:@[[self.collectionView indexPathForCell:self.cell4Menu]]];
}

-(void)performCopy:(UIMenuItem *)sender {
    if (self.cell4Menu) {
        if ([self.cell4Menu.model.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = ((WFCCTextMessageContent *)self.cell4Menu.model.message.content).text;
        }
    }
}

-(void)performForward:(UIMenuItem *)sender {
    if (self.cell4Menu) {
        WFCUForwardViewController *controller = [[WFCUForwardViewController alloc] init];
        controller.message = self.cell4Menu.model.message;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    }
}

-(void)performCollect:(UIMenuItem *)sender {
    if (self.cell4Menu) {
        [self requestCollectAddress:self.cell4Menu];
    }
}


-(void)performRecall:(UIMenuItem *)sender {
    if (self.cell4Menu.model.message) {
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = kLocalizedTableString(@"Recalling message", @"CPLocalizable");
        [hud showAnimated:YES];
        __weak typeof(self) ws = self;
        [[WFCCIMService sharedWFCIMService] recall:self.cell4Menu.model.message success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                ws.cell4Menu.model.message = [[WFCCIMService sharedWFCIMService] getMessage:ws.cell4Menu.model.message.messageId];
                [ws.collectionView reloadItemsAtIndexPaths:@[[ws.collectionView indexPathForCell:ws.cell4Menu]]];
            });
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = MBProgressHUDModeText;
                hud.label.text = kLocalizedTableString(@"Recalling message fail", @"CPLocalizable");
                [hud hideAnimated:YES afterDelay:1.f];
            });
        }];
    }
}

- (void)onMenuHidden:(id)sender {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:nil];
    __weak typeof(self)ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ws.cell4Menu = nil;
    });
    
}



#pragma mark - set up UIAlertController
- (void)setupAlertView{
    self.selectedContractType = 0;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, alertController.view.frame.size.width-50, 135)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, alertController.view.frame.size.width, 135)];
    [alertController.view addSubview:view];
    self.viewOnAlertView = view;
    
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

    
    NSString *str1 = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
    CGSize size1 = [str1 sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f]}];
    CGFloat width1 = size1.width+40;
    if (width1 < 180) {
        width1 = 150;
    }
    
    UIImageView *imgV1 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 30, 20, 20)];
    imgV1.tag = 10010;
    imgV1.image = [UIImage imageNamed:@"comment_state1"];
    [view addSubview:imgV1];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.tag = 10011;
    NSLog(@"alertController.view.bounds.size.width:%@", NSStringFromCGRect(alertController.view.frame));
    btn1.frame = CGRectMake(CGRectGetMinX(imgV1.frame), 20, width1, 40);
    //    btn1.layer.borderWidth = 1;
    [btn1 setTitle:str1 forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:17.f];
    
    [btn1 setTitleColor:[UIColor colorWithRed:38/255.f green:96/255.f blue:111/255.f alpha:1] forState:UIControlStateNormal];
    btn1.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    //    btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn1 addTarget:self action:@selector(selectContractAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn1];
    
    
    UIImageView *imgV2 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 80, 20, 20)];
    imgV2.tag = 10012;
    imgV2.image = [UIImage imageNamed:@"comment_state2"];
    [view addSubview:imgV2];
    
    
    NSString *str2 = kLocalizedTableString(@"Longterm Contract", @"CPLocalizable");
    CGSize size2 = [str2 sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f]}];
    CGFloat width2 = size2.width+40;
    if (width2 < 180) {
        width2 = 150;
    }
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.tag = 10013;
    btn2.frame = CGRectMake(CGRectGetMinX(imgV2.frame), 70, width2, 40);
    [btn2 setTitle:str2 forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [btn2 setTitleColor:[UIColor colorWithRed:38/255.f green:96/255.f blue:111/255.f alpha:1] forState:UIControlStateNormal];
    btn2.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [btn2 addTarget:self action:@selector(selectContractAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn2];
    
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.selectedContractType == 0) {// 短期合约
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPInitShortTermContractVC *initShortTermContractVC = [storyboard instantiateViewControllerWithIdentifier:@"CPInitShortTermContractVC"];
            initShortTermContractVC.targetIMUserId = self.conversation.target;
            initShortTermContractVC.scheduleMJModel = self.scheduleMJModel;
            initShortTermContractVC.passValueblock = ^(NSDictionary * _Nonnull dict) {
                self.contractDict = dict;
                [self sendContractMessage];
            };
            [self.navigationController pushViewController:initShortTermContractVC animated:YES];
        }
        else if (self.selectedContractType == 1) {// 长期合约
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPInitLongTermContractVC *initLongTermContractVC = [storyboard instantiateViewControllerWithIdentifier:@"CPInitLongTermContractVC"];
            initLongTermContractVC.targetIMUserId = self.conversation.target;
            initLongTermContractVC.scheduleMJModel = self.scheduleMJModel;
            initLongTermContractVC.passValueblock = ^(NSDictionary * _Nonnull dict) {
                self.contractDict = dict.mutableCopy;
                [self.contractDict setValue:self.conversation.target forKey:@"targetIMUserId"];
                [self sendContractMessage];
            };
            [self.navigationController pushViewController:initLongTermContractVC animated:YES];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:confirm];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

- (void)selectContractAction:(UIButton*)btn{
    UIImageView *imgV1 = [self.viewOnAlertView viewWithTag:10010];
    UIButton *btn1 = [self.viewOnAlertView viewWithTag:10011];
    UIImageView *imgV2 = [self.viewOnAlertView viewWithTag:10012];
    UIButton *btn2 = [self.viewOnAlertView viewWithTag:10013];
    
    if (btn == btn1) {
        btn1.selected = YES;
        btn2.selected = NO;
        imgV1.image = [UIImage imageNamed:@"comment_state1"];
        imgV2.image = [UIImage imageNamed:@"comment_state2"];
        _selectedContractType = 0;
    }
    else if (btn == btn2) {
        btn2.selected = YES;
        btn1.selected = NO;
        imgV1.image = [UIImage imageNamed:@"comment_state2"];
        imgV2.image = [UIImage imageNamed:@"comment_state1"];
        _selectedContractType = 1;
    }
    NSLog(@"btn1.selected:%d, btn2.selected:%d, _selectedContractType:%ld", btn1.selected, btn2.selected, (long)_selectedContractType);
}


#pragma mark - 发送发起合约消息
- (void)sendContractMessage{
    NSInteger contractType = [[self.contractDict valueForKey:@"contractType"] integerValue];
    
    NSString *time = @"";
    
    if (contractType == 0) {
        
        NSDate *date1 = [Utils stringToDate:[self.contractDict valueForKey:@"beginTime"] withDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *beginTime = [Utils dateToString:date1 withDateFormat:@"MM/dd EEE HH:mm"];
        NSDate *date2 = [Utils stringToDate:[self.contractDict valueForKey:@"endTime"] withDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *endTime = [Utils dateToString:date2 withDateFormat:@"MM/dd EEE HH:mm"];
        
        time = [NSString stringWithFormat:@"%@~%@", beginTime, endTime];

    }
    else if (contractType == 1) {
        time = [NSString stringWithFormat:@"%@ %@~%@", [self.contractDict valueForKey:@"contractCycle"], [self.contractDict valueForKey:@"beginTime"], [self.contractDict valueForKey:@"endTime"]];
    }
    
    WFCCContractMessageContent *content = [WFCCContractMessageContent contentWithContractType:[[self.contractDict valueForKey:@"contractType"] integerValue] from:[[self.contractDict valueForKey:@"fromAddressVo"] valueForKey:@"address"] to:[[self.contractDict valueForKey:@"toAddressVo"] valueForKey:@"address"] beginTime:[self.contractDict valueForKey:@"beginTime"] endTime:[self.contractDict valueForKey:@"endTime"] endDate:[self.contractDict valueForKey:@"endDate"] weekNum:[self.contractDict valueForKey:@"weekNum"] time:time remark:[self.contractDict valueForKey:@"remark"] contractId:[[self.contractDict valueForKey:@"contractId"] integerValue] status:0 summary:kLocalizedTableString(@"MessageTypeSendContract", @"CPLocalizable")];
    
    
    // send contract message
    [self sendMessage:content];
    
    //
    WFCCContractHasSendMessageContent *contractHasSendMessageContent = [[WFCCContractHasSendMessageContent alloc] init];
    contractHasSendMessageContent.tip = kLocalizedTableString(@"waitingforreply", @"CPLocalizable");
    [self sendMessage:contractHasSendMessageContent];
    
}

#pragma mark - 聊天界面中收藏地址
- (void)requestCollectAddress:(WFCUMessageCellBase*)cell{
    WFCCLocationMessageContent *content = (WFCCLocationMessageContent*)self.cell4Menu.model.message.content;

    NSMutableDictionary *param = @{
                                   @"longitude":[NSNumber numberWithDouble:content.coordinate.longitude],
                                   @"latitude":[NSNumber numberWithDouble:content.coordinate.latitude],
                                   @"address":content.address,
                                   @"addressName":content.addressName,
                                   @"administrativeArea":content.administrativeArea,
                                   @"subAdministrativeArea":content.subAdministrativeArea,
                                   @"locality":content.locality,
                                   @"subLocality":content.subLocality,
                                   @"thoroughfare":content.thoroughfare,
                                   @"subThoroughfare":content.subThoroughfare
                                   }.mutableCopy;
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/address/v1/collectAddress", BaseURL] parameters:param.mutableCopy success:^(id responseObject) {
        NSLog(@"WFCUMessageListViewController requestCollectAddress responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSLog(@"WFCUMessageListViewController requestCollectAddress 成功");
                content.status = 1;
                [[WFCCIMService sharedWFCIMService] updateMessage:weakSelf.cell4Menu.model.message.messageId content:content];
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[weakSelf.collectionView indexPathForCell:weakSelf.cell4Menu]]];
                
            }
            else{
                NSLog(@"WFCUMessageListViewController requestCollectAddress 失败");
            }
        }
        else {
            NSLog(@"WFCUMessageListViewController requestCollectAddress 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"WFCUMessageListViewController requestCollectAddress error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

#pragma mark - 同意接受合约的http请求
- (void)requestAcceptContractByContractId:(NSUInteger)contractId complete:(void (^)(BOOL success))callbackBlock{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/acceptContract", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:contractId]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"WFCUMessageListViewController requestAcceptContractByContractId responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AcceptContractSuccess" object:nil];
                callbackBlock(YES);
            }
            else{
                callbackBlock(NO);
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
            }
            
        }
        else {
            callbackBlock(NO);
            NSLog(@"WFCUMessageListViewController requestAcceptContractByContractId 失败");
            [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"]];
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        callbackBlock(NO);
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"WFCUMessageListViewController requestAcceptContractByContractId error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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


//#pragma mark - cancel notice
//- (void)cancelLocalNoticeByDataid:(NSUInteger)dataid
//                     contractType:(NSUInteger)contractType
//                          weekNum:(NSString*)weekNum {
//    if (contractType == 0) {
//        NSString *identifier = @"";
//
//        // 将提醒类型和合约id作为通知的identifier
//        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)dataid, 0];
//        [self cancelNotificationWithIdentifier:identifier];
//
//
//        // 将提醒类型和合约id作为通知的identifier
//        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)dataid, 1];
//        [self cancelNotificationWithIdentifier:identifier];
//
//        // 将提醒类型和合约id作为通知的identifier
//        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)dataid, 2];
//        [self cancelNotificationWithIdentifier:identifier];
//
//        // 将提醒类型和合约id作为通知的identifier
//        identifier = [NSString stringWithFormat:@"%lu-%d", (unsigned long)dataid, 3];
//        [self cancelNotificationWithIdentifier:identifier];
//
//
//    }
//    else if (contractType == 1) {
//        NSString *identifier = @"";
//
//        NSArray *weekNumArr = [weekNum componentsSeparatedByString:@","];
//        for (int i = 0; i < weekNumArr.count; i++) {
//            NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
//
//            NSInteger theNotifyWeekday = notifyWeekday;
//            theNotifyWeekday -= 1;
//            if (theNotifyWeekday == 0) {
//                theNotifyWeekday = 7;
//            }
//            // 将提醒类型和合约id作为通知的identifier
//            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)dataid, 0, theNotifyWeekday];
//            [self cancelNotificationWithIdentifier:identifier];
//
//
//            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)dataid, 1, notifyWeekday];
//            [self cancelNotificationWithIdentifier:identifier];
//
//
//            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)dataid, 2, notifyWeekday];
//            [self cancelNotificationWithIdentifier:identifier];
//
//
//            // 将提醒类型和合约id作为通知的identifier
//            identifier = [NSString stringWithFormat:@"%lu-%d-%ld", (unsigned long)dataid, 3, notifyWeekday];
//            [self cancelNotificationWithIdentifier:identifier];
//        }
//    }
//}
//
///**  取消一个特定的通知*/
//- (void)cancelNotificationWithIdentifier:(NSString *)identifier{
//    NSLog(@"WFCUMessageListViewController cancelNotificationWithIdentifier identifier:%@", identifier);
//
//    if (@available(iOS 10.0, *)) {
//        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
//    }
//    else{
//
//        // 获取当前所有的本地通知
//        NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
//        if (!notificaitons || notificaitons.count <= 0) { return; }
//        for (UILocalNotification *notify in notificaitons) {
//            if ([[notify.userInfo objectForKey:@"identifier"] isEqualToString:identifier]) {
//                [[UIApplication sharedApplication] cancelLocalNotification:notify];
//                break;
//            }
//        }
//    }
//}
//
//- (void)cancelAllNotification{
//    if (@available(iOS 10.0, *)) {
//        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
//        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
//    }
//    else{
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    }
//}
//
///**  取消已经推过的通知*/
//- (void)removeAllDeliveredNotifications __IOS_AVAILABLE(10.0){
//    if (@available(iOS 10.0, *)) {
//        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
//    }
//}
@end
