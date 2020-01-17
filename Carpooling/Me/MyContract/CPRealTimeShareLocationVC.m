//
//  CPRealTimeShareLocationVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/14.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPRealTimeShareLocationVC.h"
#import <WFChatClient/WFCCNetworkService.h>
#import <WFChatClient/WFCChatClient.h>
#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"
#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"
#import "MKMapView+BWZoomLevel.h"

#define kDistanceFilter  1.0

@interface CPRealTimeShareLocationVC ()<CLLocationManagerDelegate, MKMapViewDelegate>{
    NSMutableArray *_pinViews;
}
//地图
@property(nonatomic,strong) MKMapView *mMapView;
//定位
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coord;

@property (nonatomic, strong) WFCCConversation *conversation;
@property (nonatomic, strong) UILabel *tipLbl;
@end


@implementation CPRealTimeShareLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = kLocalizedTableString(@"Location", @"CPLocalizable");
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    
    NSLog(@"CPRealTimeShareLocationVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@, [WFCCNetworkService sharedInstance].currentConnectionStatus:%ld", savedUserId, [WFCCNetworkService sharedInstance].userId, (long)[WFCCNetworkService sharedInstance].currentConnectionStatus);
    
    if (savedToken.length > 0 && savedUserId.length > 0) {
        if (![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]) {
            NSLog(@"CPRealTimeShareLocationVC ![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]");
            [[WFCCNetworkService sharedInstance] disconnect:YES];
            [[WFCCNetworkService sharedInstance] connect:savedUserId token:savedToken];
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
            if (nil != deviceToken){
                [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
            }
            //connect im notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IMCONNECTEDONOTHERVIEWCONTROLLER" object:nil];
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
    
    
    _mMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0 , kSCREENWIDTH, kSCREENHEIGHT-0)];
    _mMapView.delegate = self;
    _mMapView.hidden = YES;
    _mMapView.mapType = MKMapTypeStandard;
    _mMapView.showsUserLocation = YES;
    _mMapView.userTrackingMode = MKUserTrackingModeNone;
    //设置地图范围
    CLLocationCoordinate2D center = self.mMapView.region.center;
    [self.mMapView setCenterCoordinate:center zoomLevel:15 animated:NO];
    [self.view addSubview:_mMapView];
    
    
    _tipLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, (kSCREENHEIGHT-50)/2, kSCREENWIDTH-40, 50)];
    _tipLbl.text = kLocalizedTableString(@"waiting check location tip", @"CPLocalizable");
    _tipLbl.textAlignment = NSTextAlignmentCenter;
    _tipLbl.textColor = [UIColor lightGrayColor];
    if (@available(iOS 8.2, *)) {
        _tipLbl.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightMedium];
    } else {
        // Fallback on earlier versions
        _tipLbl.font = [UIFont systemFontOfSize:17.f];
    }
    [self.view addSubview:_tipLbl];
    
    
    
    [self setupConversation];
    
    //
    [self checkIfAuthLocation];
}

//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
    
//    WFCCRealtimeLocationNotificationMessageContent *realtimeLocationTipContent = [[WFCCRealtimeLocationNotificationMessageContent alloc] init];
//    realtimeLocationTipContent.tip = kLocalizedTableString(@"receive Realtime Location End tip", @"CPLocalizable");
//
//    NSString *myselfUserId = @"";
//    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
//    if (savedUserId.length > 0) {
//        myselfUserId = savedUserId;
//    }
//    realtimeLocationTipContent.othersIMUserId = myselfUserId;
//    realtimeLocationTipContent.shareLocationStatus = RealtimeLocation_End;
//    [self sendMessageWithConversation:self.conversation message:realtimeLocationTipContent];
}


// !!!: navigationShouldPopOnBackButton
//- (BOOL)navigationShouldPopOnBackButton{
//    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:kLocalizedTableString(@"finish Realtime Location tip", @"CPLocalizable") preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleDefault handler:nil];
//
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//
//    [alert addAction:cancelAction];
//    [alert addAction:okAction];
//
//    [self presentViewController:alert animated:YES completion:nil];
//
//    return NO;
//}


#pragma mark -------#pragma mark 地理位置相关
- (void)checkIfAuthLocation{
    if (![CLLocationManager locationServicesEnabled]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Tips", @"CPLocalizable") message:kLocalizedTableString(@"Location Service Off", @"CPLocalizable") preferredStyle:UIAlertControllerStyleAlert];
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
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
        
        return;
    }
    
    if (!_locationManager) {
        NSLog(@"checkIfAuthLocation [CLLocationManager authorizationStatus]:%d", [CLLocationManager authorizationStatus]);
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
        _locationManager.delegate = self;
        if (@available(iOS 9.0, *)) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        } else {
            // Fallback on earlier versions
            [self.locationManager requestAlwaysAuthorization];
        }
        
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kDistanceFilter;
        
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"locationManager didChangeAuthorizationStatus status:%d", status);
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            if (@available(iOS 9.0, *)) {
                _locationManager.allowsBackgroundLocationUpdates = YES;
            } else {
                // Fallback on earlier versions
                [self.locationManager requestAlwaysAuthorization];
            }
            
            _locationManager.pausesLocationUpdatesAutomatically = NO;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kDistanceFilter;
            
        }
        
        [_locationManager startUpdatingLocation];
        
    }
    else if (status != kCLAuthorizationStatusNotDetermined) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Tips", @"CPLocalizable") message:kLocalizedTableString(@"Need Location Auth", @"CPLocalizable") preferredStyle:UIAlertControllerStyleAlert];
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
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation = [locations lastObject];

    self.coord = currLocation.coordinate;
    NSLog(@"currLocation.coordinate.latitude:%f, currLocation.coordinate.longitude:%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude);
    
    
    WFCCShareLocationContent *shareLocationContent = [WFCCShareLocationContent contentWithLatitude:currLocation.coordinate.latitude longitude:currLocation.coordinate.longitude];
    [self sendMessageWithConversation:self.conversation message:shareLocationContent];
}


- (void)setupConversation{
    //
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, contractModel.cjUserVo.username:%@, contractMJModel.qyUserVo.username:%@", account, self.contractMJModel.cjUserVo.username, self.contractMJModel.qyUserVo.username);
    NSString *somebody = @"";
    if ([account isEqualToString:self.contractMJModel.cjUserVo.username]) {
        somebody = self.contractMJModel.qyUserVo.imUserId;
    }
    else {
        somebody = self.contractMJModel.cjUserVo.imUserId;
    }
    
    NSLog(@"CPRealTimeShareLocationVC somebody:%@", somebody);
    
    self.conversation = [WFCCConversation conversationWithType:Single_Type target:somebody line:0];
}



#pragma mark - send message
- (void)sendMessageWithConversation:(WFCCConversation*)conversation message:(WFCCMessageContent *)content {
    //发送消息时，client会发出"kSendingMessageStatusUpdated“的通知，消息界面收到通知后加入到列表中。
    [[WFCCIMService sharedWFCIMService] send:conversation content:content expireDuration:0 success:^(long long messageUid, long long timestamp) {
        NSLog(@"CPRealTimeShareLocationVC send message success");
    } error:^(int error_code) {
        NSLog(@"CPRealTimeShareLocationVC send message fail(%d)", error_code);
    }];
}

- (void)onReceiveMessages:(NSNotification *)notification {
    if (_mMapView.isHidden) {
        _tipLbl.hidden = YES;
        _mMapView.hidden = NO;
    }
    
    NSArray<WFCCMessage *> *messages = notification.object;
    for (int i = 0; i < messages.count; i++) {
        WFCCMessage *message = [messages objectAtIndex:i];
        //
        if ([message.content isKindOfClass:[WFCCShareLocationContent class]] && message.direction == MessageDirection_Receive) {
            
            if (!_pinViews) {
                _pinViews = [[NSMutableArray alloc] init];
            }
            MKPointAnnotation *annotation = [self markPinWithMessage:message];
            NSMutableArray *tempPinViews = [_pinViews mutableCopy];
            for (MKPointAnnotation *pinView in tempPinViews) {
                if ([annotation.title isEqualToString:pinView.title]) {
                    [_pinViews removeObject:pinView];
                    break;
                }
            }
            [_pinViews addObject:annotation];
            [self.mMapView removeAnnotations:tempPinViews];
            [self.mMapView addAnnotations:_pinViews];
            [self.mMapView setCenterCoordinate:annotation.coordinate];
        }
    }
}

-(MKPointAnnotation *)markPinWithMessage:(WFCCMessage *)cmdMessage{
    WFCCShareLocationContent *content = (WFCCShareLocationContent*)cmdMessage.content;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(content.latitude, content.longitude);
//    DDLogDebug(@"CPRealTimeShareLocationVC markPinWithMessage latitude:%f, longitude:%f", annotation.coordinate.latitude, annotation.coordinate.longitude);
    annotation.title = cmdMessage.fromUser;
    return annotation;
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
