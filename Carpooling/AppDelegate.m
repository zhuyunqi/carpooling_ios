//
//  AppDelegate.m
//  Carpooling
//
//  Created by bw on 2019/5/15.
//  Copyright © 2019 bw. All rights reserved.
//

#import "AppDelegate.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCConfig.h"
#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SAMKeychain.h"
#import "BWLocalizableHelper.h"

#import "CPContractDetailVC.h"
#import "WFChatUIKit.h"

// google map
//#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate () <ConnectionStatusDelegate, ReceiveMessageDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [VHLNavigation vhl_setDefaultNavBackgroundColor:[UIColor clearColor]];
    
    
    if (@available(iOS 10.0, *)) {
        //第一步：获取推送通知中心
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!error) {
                                      NSLog(@"UNUserNotificationCenter succeeded!");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [application registerForRemoteNotifications];
                                      });
                                  }
                              }];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    // 添加DDFileLogger，你的日志语句将写入到一个文件中，默认路径在沙盒的Library/Caches/Logs/目录下，文件名为bundleid+空格+日期.log。
//    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
//    fileLogger.rollingFrequency = 60 * 60 * 24;
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    [DDLog addLogger:fileLogger];
    
    
    // AnonymousChatAccount
    [self generateChatAccountByUUIDAndTimestamp];
    
    
    // wfchat
    [WFCCNetworkService startLog];
    [WFCCNetworkService sharedInstance].connectionStatusDelegate = self;
    [WFCCNetworkService sharedInstance].receiveMessageDelegate = self;
    [[WFCCNetworkService sharedInstance] setServerAddress:IM_SERVER_HOST port:IM_SERVER_PORT];

    
//    [SAMKeychain deletePasswordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
//    NSArray *array = [SAMKeychain accountsForService:kKeychainAnonymousChatAccountService];
//    NSLog(@"application array:%@", array);
    

    // facebook login
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    // ChangeLanguage
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLanguageChangedNotification:) name:ChangeLanguageNotificationName object:nil];
    
    // google map
//    [GMSServices provideAPIKey:@"AIzaSyBw_jEtiIopsXL4E6gFHTdgXiMSNeBJvMQ"];
    
    
    // launch screen delay
    NSTimeInterval delayDuration = 1.5;
    NSTimer *connectionTimer = [NSTimer scheduledTimerWithTimeInterval:delayDuration target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:connectionTimer forMode:NSDefaultRunLoopMode];
    do {
        // 设置1.0秒检测做一次do...while的循环
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    } while (!done);
    
    return YES;
}

BOOL done;
- (void)timerFired:(NSTimer *)timer {
    done = YES;
}


- (NSString *)generateChatAccountByUUIDAndTimestamp {
    NSTimeInterval timestamp = [Utils getCurrentTimestampMillisecond];
    NSString *chatAccount = [SAMKeychain passwordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
    if (!chatAccount) {
        CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
        assert(UUIDRef != NULL);
        CFStringRef UUIDStrRef = CFUUIDCreateString(NULL, UUIDRef);

        chatAccount = [NSString stringWithFormat:@"%@", UUIDStrRef];
        chatAccount = [[chatAccount lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        chatAccount = [NSString stringWithFormat:@"%@%lu", chatAccount, (unsigned long)timestamp];
        NSLog(@"AppDelegate generateChatAccountByUUIDAndTimestamp chatAccount:%@", chatAccount);
        [SAMKeychain setPassword:chatAccount forService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
    }
    return chatAccount;
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    
    WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0), @(1)]];
    [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount.unread;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RECEIVEREMOTENOTIFICATIONWHENAPPACTIVE" object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [WFCCNetworkService startLog];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    // Add any custom logic here.
    return handled;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

#pragma mark - app内切换语言
- (void)didReceiveLanguageChangedNotification:(NSNotification*)notification{
    //收到通知重新加载界面并且回到切换语言的界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [storyboard instantiateInitialViewController];
    self.window.rootViewController = nav;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken 成功");
    NSString *token = [deviceToken description];
    NSLog(@"---deviceToken string--%@", token);
    if (nil != token) {
        NSString *deviceTokenStr = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        deviceTokenStr = [deviceTokenStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"---deviceTokenStr after:%@", deviceTokenStr);
        
        NSString *oldToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
        if (![oldToken isEqual:deviceTokenStr] || oldToken == nil){
            [[NSUserDefaults standardUserDefaults] setValue:deviceTokenStr forKey:kDeviceToken];
            //
            [[WFCCNetworkService sharedInstance] setDeviceToken:deviceTokenStr];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError error ==%@, error.code:%ld", [error localizedDescription], (long)error.code);
}

//接收remote推送的消息,(在前台/后台时,点击接收到的推送,进入app,再次显示)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"didReceiveRemoteNotification userInfo == %@", userInfo);
    
    if (application.applicationState == UIApplicationStateActive) {
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RECEIVEREMOTENOTIFICATIONWHENAPPACTIVE" object:nil];
    }
    else {
        //
        
    }
}

//接收local推送的消息 didReceiveLocalNotification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"didReceiveLocalNotification userInfo == %@", userInfo);
    
    if (application.applicationState == UIApplicationStateActive) {

        //获得当前活动窗口的根视图
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentShowingVC = [Utils findCurrentShowingViewControllerFrom:vc];
        
        if (![currentShowingVC isKindOfClass:NSClassFromString(@"CPContractDetailVC")]) {
            
            if ([[userInfo valueForKey:@"kLocalNotificationID"] isEqualToString:@"contractAgreeNotification"]) {
                NSLog(@"didReceiveLocalNotification postnoti");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRACTBEGINTIME" object:nil userInfo:userInfo];
            }
            
            if ([userInfo valueForKey:@"contractId"]) {
                NSInteger contractId = [[userInfo valueForKey:@"contractId"] integerValue];
                NSLog(@"willPresentNotification contractId: %ld", (long)contractId);
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
                contractDetailVC.contractId = contractId;
                
                // 跳转合约详情
                UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
                tab.selectedIndex = 3;
                UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
                [nav pushViewController:contractDetailVC animated:YES];
            }
        }
        
    }
    else {
        NSInteger contractId = [[userInfo valueForKey:@"contractId"] integerValue];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
        contractDetailVC.contractId = contractId;
        
        // 跳转合约详情
        UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
        tab.selectedIndex = 3;
        UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
        [nav pushViewController:contractDetailVC animated:YES];
    }
}



- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"willPresentNotification userInfo == %@", userInfo);
    
    NSString *endDateStr = [NSString stringWithFormat:@"%@ %@", [userInfo valueForKey:@"endDate"], [userInfo valueForKey:@"endTime"]];
    
    NSDate *endDate = [Utils stringToDate:endDateStr withDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSComparisonResult result = [self compareNowAndEndDate:endDate];
    if (result == NSOrderedDescending) {
        // 将提醒类型和合约id作为通知的identifier
        NSString *identifier = [userInfo valueForKey:@"identifier"];
        
        [center removePendingNotificationRequestsWithIdentifiers:@[identifier]];
        
        
    }
    else {
        
        //获得当前活动窗口的根视图
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentShowingVC = [Utils findCurrentShowingViewControllerFrom:vc];
        if (![currentShowingVC isKindOfClass:NSClassFromString(@"CPContractDetailVC")]) {
            
            if ([[userInfo valueForKey:@"kLocalNotificationID"] isEqualToString:@"contractAgreeNotification"]) {
                NSLog(@"didReceiveLocalNotification postnoti");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRACTBEGINTIME" object:nil userInfo:userInfo];
            }
            
            NSLog(@"willPresentNotification contractId: %@", [userInfo valueForKey:@"contractId"]);
            if ([userInfo valueForKey:@"contractId"]) {
                NSInteger contractId = [[userInfo valueForKey:@"contractId"] integerValue];
                NSLog(@"willPresentNotification contractId: %ld", (long)contractId);
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
                contractDetailVC.contractId = contractId;
                
                // 跳转合约详情
                UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
                tab.selectedIndex = 3;
                UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
                [nav pushViewController:contractDetailVC animated:YES];
            }
        }
    }
}


//在后台或者程序被杀死的时候，点击通知栏调用的。  在前台的时候不会被调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"didReceiveNotificationResponse userInfo == %@", userInfo);


    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [Utils findCurrentShowingViewControllerFrom:vc];
    if (![currentShowingVC isKindOfClass:NSClassFromString(@"CPContractDetailVC")]) {
        
        if ([[userInfo valueForKey:@"kLocalNotificationID"] isEqualToString:@"contractAgreeNotification"]) {
            NSLog(@"didReceiveLocalNotification postnoti");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRACTBEGINTIME" object:nil userInfo:userInfo];
        }
        
        if ([userInfo valueForKey:@"contractId"]) {
            NSInteger contractId = [[userInfo valueForKey:@"contractId"] integerValue];
            NSLog(@"willPresentNotification contractId: %ld", (long)contractId);
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
            contractDetailVC.contractId = contractId;
            
            // 跳转合约详情
            UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
            tab.selectedIndex = 3;
            UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
            [nav pushViewController:contractDetailVC animated:YES];
        }
    }

}




#pragma mark - wfchat
- (void)onReceiveMessage:(NSArray<WFCCMessage *> *)messages hasMore:(BOOL)hasMore {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0), @(1)]];
        int count = unreadCount.unread;
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        
        for (WFCCMessage *msg in messages) {
            //当在后台活跃时收到新消息，需要弹出本地通知。有一种可能时客户端已经收到远程推送，然后由于voip/backgroud fetch在后台拉活了应用，此时会收到接收下来消息，因此需要避免重复通知
            if (([[NSDate date] timeIntervalSince1970] - (msg.serverTime - [WFCCNetworkService sharedInstance].serverDeltaTime)/1000) > 3) {
                continue;
            }
            
            int flag = (int)[msg.content.class performSelector:@selector(getContentFlags)];
            WFCCConversationInfo *info = [[WFCCIMService sharedWFCIMService] getConversationInfo:msg.conversation];
            if((flag & 0x03) && !info.isSilent && ![msg.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
                UILocalNotification *localNote = [[UILocalNotification alloc] init];
                
                localNote.alertBody = [msg digest];
                if (msg.conversation.type == Single_Type) {
                    WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.conversation.target refresh:NO];
                    if (sender.displayName) {
                        if (@available(iOS 8.2, *)) {
                            localNote.alertTitle = sender.displayName;
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                } else if(msg.conversation.type == Group_Type) {
                    WFCCGroupInfo *group = [[WFCCIMService sharedWFCIMService] getGroupInfo:msg.conversation.target refresh:NO];
                    WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.fromUser refresh:NO];
                    if (sender.displayName && group.name) {
                        if (@available(iOS 8.2, *)) {
                            localNote.alertTitle = [NSString stringWithFormat:@"%@@%@:", sender.displayName, group.name];
                        } else {
                            // Fallback on earlier versions
                        }
                    }else if (sender.displayName) {
                        if (@available(iOS 8.2, *)) {
                            localNote.alertTitle = sender.displayName;
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                
                localNote.applicationIconBadgeNumber = count;
                localNote.userInfo = @{@"conversationType" : @(msg.conversation.type), @"conversationTarget" : msg.conversation.target, @"conversationLine" : @(msg.conversation.line) };
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
                });
            }
        }
        
    }
}

- (void)onConnectionStatusChanged:(ConnectionStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == kConnectionStatusRejected || status == kConnectionStatusTokenIncorrect || status == kConnectionStatusSecretKeyMismatch) {
            [[WFCCNetworkService sharedInstance] disconnect:YES];
        } else if (status == kConnectionStatusLogout) {

            
        }
    });
}

#pragma mark - compareNowAndEndDate
// !!!: compareNowAndEndDate
- (NSComparisonResult)compareNowAndEndDate:(NSDate*)endDate{
    NSDate *today = [NSDate date];
    
    return [today compare:endDate];
}
@end
