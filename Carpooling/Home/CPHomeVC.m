//
//  CPHomeVC.m
//  Carpooling
//
//  Created by bw on 2019/5/15.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeVC.h"
#import "VHLNavigation.h"

#import "CPHomeFirstOpenCell.h"
#import "CPHomeHeaderCell.h"
#import "CPHomeNoDataCell1.h"
#import "CPHomeSetScheduleCell1.h"
#import "CPHomeHorizontalScrollCell1.h"
#import "CPHomeHorizontalScrollCell2.h"
#import "CPHomeCell2.h"
#import "HorzonItemCell.h"
#import "CPUserLoginVC.h"

#import "SDCycleScrollView.h"

#import "CPActivityDetailVC.h"
#import "CPMyActivityVC.h"
#import "CPSetupActivityVC.h"
#import "CPHomeReqResultModel.h"
#import "CPHomeReqResultSubModel.h"
#import "CPBannerMJModel.h"
#import "CPActivityMJModel.h"
#import "CPContractMJModel.h"
#import "CPScheduleMJModel.h"
#import "CPAddressModel.h"
#import "CPMyContractPageVC.h"
#import "CPContractDetailVC.h"
#import "CPMyScheduleVC.h"
#import "CPMatchingScheduleVC.h"
#import "CPSetupScheduleVC.h"

#import <WFChatClient/WFCChatClient.h>

#import <SafariServices/SafariServices.h>

#import <UserNotifications/UserNotifications.h>


#define NAVBAR_COLORCHANGE_POINT kNAVIBARANDSTATUSBARHEIGHT
#define kDistanceFilter  1.0

@interface CPHomeVC ()<SDCycleScrollViewDelegate, CPHomeHorizontalScrollCell1Delegate, CPHomeHorizontalScrollCell2Delegate, CPHomeCell2Delegate, CPHomeSetScheduleCell1Delegate, SFSafariViewControllerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SDCycleScrollView *bannerView;
@property (nonatomic, strong) NSMutableArray *bannerDataSource;

@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;

@property (nonatomic, strong) NSMutableArray *dataSource; // 多少个section
@property (nonatomic, strong) NSDictionary *specialDict;
@property (nonatomic, strong) NSArray *specialArray;

@property (nonatomic, strong) NSMutableArray *bannerImgURLStrings;
@property (nonatomic, strong) NSMutableArray *myContracts;
@property (nonatomic, strong) NSMutableArray *mySchedules;
@property (nonatomic, strong) NSMutableArray *myActivitys;
@property (nonatomic, strong) NSMutableArray *allActivitys;
@property (nonatomic, strong) NSMutableArray *hotActivitys;
@property (nonatomic, assign) BOOL isFirstOpen;
@property (nonatomic, copy) NSString *firstOpenDesc; // 首次登录描述

// for realtime location
@property (nonatomic, strong) WFCCConversation *conversation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coord;
@end

@implementation CPHomeVC {
    NSArray *_imagesURLStrings;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self vhl_setNavBarShadowImageHidden:YES];
    
    self.navigationController.tabBarItem.title = kLocalizedTableString(@"Index", @"CPLocalizable");
    
    // image width/height 750/560 1.33
    _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kSCREENWIDTH, kSCREENWIDTH/1.33) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _bannerView.delegate = self;
    _bannerView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    _bannerView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _bannerView.autoScrollTimeInterval = 4.0;
    
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
        _bannerView.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
        _bannerView.backgroundColor = RGBA(243, 244, 246, 1);
        
        [self vhl_setNavBarBackgroundAlpha:0];
    }
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = _bannerView;
    self.tableView.estimatedRowHeight = 0;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    [self initRightBarItem];
    
    //
    [self setupChatConnect];
    //
    
    
    _pageSize = 10;
    _currIndex = 1;
    
    
    _dataSource = @[].mutableCopy;
    _bannerDataSource = @[].mutableCopy;
    _myContracts = @[].mutableCopy;
    _mySchedules = @[].mutableCopy;
    _myActivitys = @[].mutableCopy;
    _allActivitys = @[].mutableCopy;
    _hotActivitys = @[].mutableCopy;
    
    // 首次进入app
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstOpen]) {
        _isFirstOpen = NO;
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsFirstOpen];
        _isFirstOpen = YES;
    }
    
    //
    if (_isFirstOpen) {
        self.showStyle = CPHomeVCShowStyleFirstOpen;
    }
    else if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        self.showStyle = CPHomeVCShowStyleLogin;
    }
    else if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        self.showStyle = CPHomeVCShowStyleNotLogin;
    }
    
    
    //注册并登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupAndLoginSuccess:) name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
    //退出登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogoutSuccess:) name:@"USERLOGOUTSUCCESS" object:nil];
    
    //报名活动成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshActivity:) name:@"EnrollActivitySuccess" object:nil];
    
    //创建活动成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshActivity:) name:@"SetupActivitySuccess" object:nil];
    
    //发起合约成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"LaunchContractSuccess" object:nil];
    
    //取消合约的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"CANCELCONTRACT" object:nil];
    
    //新建、编辑、删除行程成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSchedule:) name:@"ScheduleUpdateSuccess" object:nil];
    
    
    //接受合约成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"AcceptContractSuccess" object:nil];

    // 上车
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"ONCARSUCCESS" object:nil];
    // 他人上车
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"OTHERUSERONCARSUCCESS" object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"RIDINGSTATUSCHANGEFROMOTHER" object:nil];
    
    
    // CONTRACT BEGINTIME begin
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"CONTRACTBEGINTIME" object:nil];
    
    
    // other agree contract
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"OTHERUSERACCEPTCONTRACT" object:nil];
    
    // 到达
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContract:) name:@"ARRIVESUCCESS" object:nil];
    
    // 对方准备分享实时位置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareLocationToSomebody:) name:@"SHARINGLOCATIONTOOTHERTIP" object:nil];
    
    // 对方结束分享实时位置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endingShareLocationToSomebody:) name:@"ENDINGSHARINGLOCATIONTOOTHERTIP" object:nil];

    
    WS(weakSelf)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currIndex = 1;
        [weakSelf requestHomeDataByCurrentIndex:weakSelf.currIndex];
    }];
    
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingBlock:^{
//        [self requestHomeDataByCurrentIndex:weakSelf.currIndex];
    }];
    
    [SVProgressHUD show];
    [self requestHomeDataByCurrentIndex:weakSelf.currIndex];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERLOGOUTSUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnrollActivitySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SetupActivitySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LaunchContractSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CANCELCONTRACT" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScheduleUpdateSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AcceptContractSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ONCARSUCCESS" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OTHERUSERONCARSUCCESS" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RIDINGSTATUSCHANGEFROMOTHER" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CONTRACTBEGINTIME" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OTHERUSERACCEPTCONTRACT" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ARRIVESUCCESS" object:nil];
    
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHARINGLOCATIONTOOTHERTIP" object:nil];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ENDINGSHARINGLOCATIONTOOTHERTIP" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
        [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleLightContent;
    }
}

- (void)userSignupAndLoginSuccess:(NSNotification*)notification{
    self.showStyle = CPHomeVCShowStyleLogin;
    self.isFirstOpen = NO;
    _currIndex = 1;
   [self requestHomeDataByCurrentIndex:_currIndex];
}

- (void)userLogoutSuccess:(NSNotification*)notification{
    self.showStyle = CPHomeVCShowStyleNotLogin;
    _currIndex = 1;
    [self requestHomeDataByCurrentIndex:_currIndex];
}

- (void)refreshActivity:(NSNotification*)notification{
    self.showStyle = CPHomeVCShowStyleLogin;
    self.isFirstOpen = NO;
    _currIndex = 1;
    [self requestHomeDataByCurrentIndex:_currIndex];
}

- (void)refreshContract:(NSNotification*)notification{
    self.showStyle = CPHomeVCShowStyleLogin;
    self.isFirstOpen = NO;
    _currIndex = 1;
    [self requestHomeDataByCurrentIndex:_currIndex];
}


- (void)refreshSchedule:(NSNotification*)notification{
    self.showStyle = CPHomeVCShowStyleLogin;
    self.isFirstOpen = NO;
    _currIndex = 1;
    [self requestHomeDataByCurrentIndex:_currIndex];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_bannerView) {
        [_bannerView adjustWhenControllerViewWillAppera];
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //
    CGFloat insetTop = 0;
    if (@available(iOS 11,*)) {
//        insetTop = -kNAVIBARANDSTATUSBARHEIGHT;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kTABBARHEIGHT, 0);
    } else {
        insetTop = 0;
        self.tableView.contentInset = UIEdgeInsetsMake(insetTop, 0, kTABBARHEIGHT, 0);
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > NAVBAR_COLORCHANGE_POINT)
        {
            CGFloat alpha = MIN((offsetY - NAVBAR_COLORCHANGE_POINT) / kNAVIBARHEIGHT, 1);
            
            NSLog(@"CPHomeVC alpha:%f", alpha);
            
            [self vhl_setNavBarBackgroundAlpha:alpha];
            [self vhl_setNavBarShadowImageHidden:NO];
            self.navigationItem.title = kLocalizedTableString(@"Home", @"CPLocalizable");
            
        }
        else
        {
            [self vhl_setNavBarBackgroundAlpha:0];
            [self vhl_setNavBarShadowImageHidden:YES];
            self.navigationItem.title = @"";
        }
    }
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"schedule_btn"] style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
        userLoginVC.passValueblock = ^(BOOL login) {
            if (login) {
                [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        [self.navigationController pushViewController:userLoginVC animated:YES];
        
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPSetupActivityVC *setupActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupActivityVC"];
        setupActivityVC.showType = SetupActivityVCTypeSetup;
        [self.navigationController pushViewController:setupActivityVC animated:YES];
    }
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSArray *array = [self.dataSource objectAtIndex:section];
    _specialArray = [self.dataSource objectAtIndex:section];
    _specialDict = [_specialArray firstObject];
    if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"hotActivitys"]) {
        return self.hotActivitys.count + 1;
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"allActivitys"]) {
        return self.allActivitys.count + 1;
    }
    
    return _specialArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _specialDict = [[self.dataSource objectAtIndex:indexPath.section] firstObject];
    if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"firstopentips"]) {
        CGSize size1 = W_GET_STRINGSIZE(self.firstOpenDesc, kSCREENWIDTH-30, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
        return size1.height+24;
        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"firstopenSetSchedule"]) {
        return 90;
        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"contracts"]) {
        if (self.myContracts.count > 0) {
            if (indexPath.row == 0) {
                return 44;
            }
            return 140;
        }
        else{
            if (indexPath.row == 0) {
                return 44;
            }
            return CPREGULARCELLHEIGHT;
        }

        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"schedules"]) {
        if (self.mySchedules.count > 0) {
            if (indexPath.row == 0) {
                return 44;
            }
            return 180;
        }
        else{
            if (indexPath.row == 0) {
                return 44;
            }
            return CPREGULARCELLHEIGHT;
        }
        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"activitys"]) {
        if (self.myActivitys.count > 0) {
            if (indexPath.row == 0) {
                return 44;
            }
            CPActivityMJModel *model = [self.myActivitys objectAtIndex:0];
            CGSize size1 = W_GET_STRINGSIZE(model.addressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
            CGFloat height1 =  size1.height;
            
            // image width/height 590/240 2.45
            CGFloat height2 = 0;
            CGFloat totalHeight = 0;
            if (model.imgUrl.length > 0) {
                height2 = kSCREENWIDTH/2.45;
                totalHeight = height1 +height2 +115;
            }
            else{
                totalHeight = height1 +125;
            }
            model.cellHeight = totalHeight;
            return model.cellHeight;
            
        }
        else{
            if (indexPath.row == 0) {
                return 44;
            }
            return CPREGULARCELLHEIGHT;
        }
        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"hotActivitys"]) {
        if (indexPath.row == 0) {
            return 44;
        }
        CPActivityMJModel *model = [self.hotActivitys objectAtIndex:indexPath.row-1];
        CGSize size1 = W_GET_STRINGSIZE(model.addressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
        CGFloat height1 =  size1.height;
        
        // image width/height 590/240 2.45
        CGFloat height2 = 0;
        CGFloat totalHeight = 0;
        if (model.imgUrl.length > 0) {
            height2 = kSCREENWIDTH/2.45;
            totalHeight = height1 +height2 +115;
        }
        else{
            totalHeight = height1 +125;
        }
        model.cellHeight = totalHeight;
        return model.cellHeight;
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"allActivitys"]) {
        if (indexPath.row == 0) {
            return 44;
        }
        CPActivityMJModel *model = [self.allActivitys objectAtIndex:indexPath.row-1];
        CGSize size1 = W_GET_STRINGSIZE(model.addressVo.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
        CGFloat height1 =  size1.height;
        
        // image width/height 590/240 2.45
        CGFloat height2 = 0;
        CGFloat totalHeight = 0;
        if (model.imgUrl.length > 0) {
            height2 = kSCREENWIDTH/2.45;
            totalHeight = height1 +height2 +115;
        }
        else{
            totalHeight = height1 +125;
        }
        model.cellHeight = totalHeight;
        return model.cellHeight;
    }
    
    return 44;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10;
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
    UITableViewCell *cell;
//    NSDictionary *dict = [[self.dataSource objectAtIndex:indexPath.section] firstObject];
    _specialDict = [[self.dataSource objectAtIndex:indexPath.section] firstObject];
    NSLog(@"CPHomeVC cellForRowAtIndexPath indexPath.section:%ld, _specialDict:%@", (long)indexPath.section, _specialDict);
    // 首次使用app 提示
    if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"firstopentips"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeFirstOpenCell"];
            ((CPHomeFirstOpenCell*)cell).titleLbl.text = self.firstOpenDesc;
        }
        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"firstopenSetSchedule"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeSetScheduleCell1"];
            ((CPHomeSetScheduleCell1*)cell).delegate = self;
            ((CPHomeSetScheduleCell1*)cell).titleLbl.text = kLocalizedTableString(@"My Contract Empty", @"CPLocalizable");
        }
        
    }
    // 我的合约
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"contracts"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHeaderCell"];
            ((CPHomeHeaderCell*)cell).titleLbl.text = kLocalizedTableString(@"My Contract", @"CPLocalizable");
        }
        else{
            if (self.myContracts.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHorizontalScrollCell1"];
                ((CPHomeHorizontalScrollCell1*)cell).delegate = self;
                ((CPHomeHorizontalScrollCell1*)cell).tag = 90000;
                ((CPHomeHorizontalScrollCell1*)cell).itemsArray = self.myContracts;
                ((CPHomeHorizontalScrollCell1*)cell).itemSize = CGSizeMake(kSCREENWIDTH-40, 125);
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeNoDataCell1"];
                ((CPHomeNoDataCell1*)cell).indexPath = indexPath;
                ((CPHomeNoDataCell1*)cell).tipsType = 1;
            }
        }
        
    }
    // 我的行程
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"schedules"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHeaderCell"];
            ((CPHomeHeaderCell*)cell).titleLbl.text = kLocalizedTableString(@"My Schedule", @"CPLocalizable");
        }
        else{
            if (self.mySchedules.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHorizontalScrollCell2"];
                ((CPHomeHorizontalScrollCell2*)cell).delegate = self;
                ((CPHomeHorizontalScrollCell2*)cell).tag = 90001;
                ((CPHomeHorizontalScrollCell2*)cell).itemsArray = self.mySchedules;
                ((CPHomeHorizontalScrollCell2*)cell).itemSize = CGSizeMake(kSCREENWIDTH-40, 165);
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeNoDataCell1"];
                ((CPHomeNoDataCell1*)cell).indexPath = indexPath;
                ((CPHomeNoDataCell1*)cell).tipsType = 2;
            }
        }
        
    }
    // 活动列表
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"activitys"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHeaderCell"];
            ((CPHomeHeaderCell*)cell).titleLbl.text = kLocalizedTableString(@"My Activity", @"CPLocalizable");
        }
        else{
            if (self.myActivitys.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeCell2"];
                ((CPHomeCell2*)cell).delegate = self;
                ((CPHomeCell2*)cell).showType = MyActivityShowTypeHome;
                ((CPHomeCell2*)cell).indexPath = indexPath;
                CPActivityMJModel *activityModel = [self.myActivitys objectAtIndex:0];
                ((CPHomeCell2*)cell).activityModel = activityModel;
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeNoDataCell1"];
                ((CPHomeNoDataCell1*)cell).indexPath = indexPath;
                ((CPHomeNoDataCell1*)cell).tipsType = 3;
            }
        }
        
    }
    // 热门活动
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"hotActivitys"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHeaderCell"];
            ((CPHomeHeaderCell*)cell).titleLbl.text = kLocalizedTableString(@"Hot Activity", @"CPLocalizable");
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeCell2"];
            if (self.hotActivitys.count) {
                ((CPHomeCell2*)cell).delegate = self;
                ((CPHomeCell2*)cell).showType = MyActivityShowTypeHotActivity;
                ((CPHomeCell2*)cell).indexPath = indexPath;
                CPActivityMJModel *activityModel = [self.hotActivitys objectAtIndex:indexPath.row-1];
                ((CPHomeCell2*)cell).activityModel = activityModel;
            }
        }
    }
    // 平台全部活动
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"allActivitys"]) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeHeaderCell"];
            ((CPHomeHeaderCell*)cell).titleLbl.text = kLocalizedTableString(@"All Activity", @"CPLocalizable");
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeCell2"];
            if (self.allActivitys.count) {
                ((CPHomeCell2*)cell).delegate = self;
                ((CPHomeCell2*)cell).showType = MyActivityShowTypeAllActivity;
                ((CPHomeCell2*)cell).indexPath = indexPath;
                CPActivityMJModel *activityModel = [self.allActivitys objectAtIndex:indexPath.row-1];
                ((CPHomeCell2*)cell).activityModel = activityModel;
            }
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _specialDict = [[self.dataSource objectAtIndex:indexPath.section] firstObject];
    NSLog(@"CPHomeVC cellForRowAtIndexPath indexPath.section:%ld, _specialDict:%@", (long)indexPath.section, _specialDict);
    // 我的合约
    if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"contracts"]) {
        if (indexPath.row == 0 || self.myContracts.count == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyContractPageVC *myContractPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyContractPageVC"];
            [self.navigationController pushViewController:myContractPageVC animated:YES];
        }
        else {
            
        }
        
    }
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"firstopenSetSchedule"]) {
        if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
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
    // 我的行程
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"schedules"]) {
        
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyScheduleVC *myScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyScheduleVC"];
            [self.navigationController pushViewController:myScheduleVC animated:YES];
        }
        else if (self.mySchedules.count == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPSetupScheduleVC *setupScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupScheduleVC"];
            setupScheduleVC.showType = ScheduleVCShowTypeSetup;
            [self.navigationController pushViewController:setupScheduleVC animated:YES];
        }
        else {
            
        }
    }
    // 我的活动
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"activitys"]) {
        if (indexPath.row == 0 || self.myActivitys.count == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyActivityVC *myActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyActivityVC"];
            myActivityVC.showType = MyActivityShowTypeHome;
            [self.navigationController pushViewController:myActivityVC animated:YES];
        }
        else {
            if (self.myActivitys.count > 0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPActivityDetailVC *activityDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivityDetailVC"];
                CPActivityMJModel *activityMJModel = [self.myActivitys objectAtIndex:0];
                activityDetailVC.activityModel = activityMJModel;
                [self.navigationController pushViewController:activityDetailVC animated:YES];
            }
        }
        
    }
    // 热门活动
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"hotActivitys"]) {
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyActivityVC *myActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyActivityVC"];
            myActivityVC.showType = MyActivityShowTypeHotActivity;
            [self.navigationController pushViewController:myActivityVC animated:YES];
            
        }
        else{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPActivityDetailVC *activityDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivityDetailVC"];
            CPActivityMJModel *activityMJModel = [self.hotActivitys objectAtIndex:indexPath.row-1];
            activityDetailVC.activityModel = activityMJModel;
            [self.navigationController pushViewController:activityDetailVC animated:YES];
        }
    }
    // 平台全部活动
    else if ([[_specialDict valueForKey:@"headercell"] isEqualToString:@"allActivitys"]) {
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyActivityVC *myActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyActivityVC"];
            myActivityVC.showType = MyActivityShowTypeAllActivity;
            [self.navigationController pushViewController:myActivityVC animated:YES];
            
        }
        else{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPActivityDetailVC *activityDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivityDetailVC"];
            CPActivityMJModel *activityMJModel = [self.allActivitys objectAtIndex:indexPath.row-1];
            activityDetailVC.activityModel = activityMJModel;
            [self.navigationController pushViewController:activityDetailVC animated:YES];
        }
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    CPBannerMJModel *bannerMJModel = [self.bannerDataSource objectAtIndex:index];
    
    if (bannerMJModel.url) {
        if ([bannerMJModel.url containsString:@"http://"]) {
            
        }
        else if ([bannerMJModel.url containsString:@"https://"]) {
            
        }
        else if (![bannerMJModel.url containsString:@"http://"] || ![bannerMJModel.url containsString:@"https://"]) {
            if (![bannerMJModel.url containsString:@"http://"]) {
                bannerMJModel.url = [NSString stringWithFormat:@"http://%@", bannerMJModel.url];
            }
            else if (![bannerMJModel.url containsString:@"https://"]) {
                bannerMJModel.url = [NSString stringWithFormat:@"https://%@", bannerMJModel.url];
            }
        }
    }
    
    NSURL *url = [NSURL URLWithString:bannerMJModel.url];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    safariVC.modalPresentationCapturesStatusBarAppearance = true;
    safariVC.delegate = self;

    [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleDefault;
    // 建议
    [self presentViewController:safariVC animated:YES completion:nil];
    NSLog(@"---点击了第%ld张图片", (long)index);
}

#pragma mark - CPHomeHorizontalScrollCell1Delegate
- (void)horizontalScrollCell1ClickIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"CPHomeVC horizontalScrollCellAction 90000 indexPath:%@", indexPath);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
    CPContractMJModel *contractMJModel = [self.myContracts objectAtIndex:indexPath.row];
    contractDetailVC.contractId = contractMJModel.dataid;
    [self.navigationController pushViewController:contractDetailVC animated:YES];
}


- (void)horizontalScrollCell1NaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
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
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)horizontalScrollCell2ClickIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"CPHomeVC horizontalScrollCellAction 90000 indexPath:%@", indexPath);
    
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    CPActivityDetailVC *activityDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivityDetailVC"];
    //    [self.navigationController pushViewController:activityDetailVC animated:YES];
}

- (void)horizontalScrollCell2MatchingByIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"CPHomeVC horizontalScrollCell2MatchingByIndexPath indexPath.row:%ld", (long)indexPath.row);
    CPScheduleMJModel *scheduleMJModel = [self.mySchedules objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPMatchingScheduleVC *matchingScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMatchingScheduleVC"];
    matchingScheduleVC.scheduleMJModel = scheduleMJModel;
    matchingScheduleVC.requestParams = [scheduleMJModel mj_keyValues];
    [self.navigationController pushViewController:matchingScheduleVC animated:YES];
}

- (void)horizontalScrollCell2NaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
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
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)homeCell2LikeAction:(NSIndexPath *)indexPath{
    NSLog(@"CPHomeVC homeCell2LikeAction indexPath.row:%ld", (long)indexPath.row);
    
    CPActivityMJModel *activityMJModel;
    NSArray *arr = [self.dataSource objectAtIndex:indexPath.section];
    NSDictionary *dict = [arr firstObject];
    if ([[dict valueForKey:@"headercell"] isEqualToString:@"activitys"]) {
        activityMJModel = [self.myActivitys objectAtIndex:indexPath.row-1];
    }
    else if ([[dict valueForKey:@"headercell"] isEqualToString:@"hotActivitys"]) {
        activityMJModel = [self.hotActivitys objectAtIndex:indexPath.row-1];
    }
    else if ([[dict valueForKey:@"headercell"] isEqualToString:@"allActivitys"]) {
        activityMJModel = [self.allActivitys objectAtIndex:indexPath.row-1];
    }
//    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/activity/v1/collectActivity", BaseURL] parameters:@{@"activityId":[NSNumber numberWithInteger:activityMJModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPHomeVC homeCell2LikeAction responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSLog(@"CPHomeVC homeCell2LikeAction 成功");
                activityMJModel.collect += 1;
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                if ([[responseObject valueForKey:@"code"] integerValue] == 401) {
                    // 未登录
                    [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
                }
                else if ([[responseObject valueForKey:@"code"] integerValue] == 500) {
                    //
                    NSString *msg = [responseObject valueForKey:@"msg"];
                    if (msg && [msg containsString:@"该用户已点过赞"]) {
                        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"already liked", @"CPLocalizable")];
                    }
                }
                
                NSLog(@"CPHomeVC homeCell2LikeAction 失败");
            }
        }
        else {
            NSLog(@"CPHomeVC homeCell2LikeAction 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPHomeVC homeCell2LikeAction error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
//    }
}

- (void)homeCell2NaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination{
    //
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
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)homeSetScheduleCell1BtnActionByIndexPath:(NSIndexPath *)indexPath{
    if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPSetupScheduleVC *setupScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupScheduleVC"];
        setupScheduleVC.showType = ScheduleVCShowTypeSetup;
        [self.navigationController pushViewController:setupScheduleVC animated:YES];
        
    }
    else {
        
    }
}



#pragma mark - home request
- (void)requestHomeDataByCurrentIndex:(NSUInteger)index{
    
    NSLog(@"CPHomeVC requestHomeDataByCurrentIndex self.currIndex:%ld", self.currIndex);
    NSMutableDictionary *param = @{
                            @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                            @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                            }.mutableCopy;
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/index/v1/homePage.json", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        
        NSLog(@"CPHomeVC requestHomeDataByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPHomeReqResultModel *masterModel = [CPHomeReqResultModel mj_objectWithKeyValues:responseObject];
            CPHomeReqResultSubModel *subModel = masterModel.data;
            if (masterModel.code == 200) {

                if (weakSelf.currIndex == 1) {// refresh
                    [weakSelf.dataSource removeAllObjects];
                    [weakSelf.bannerDataSource removeAllObjects];
                    [weakSelf.myContracts removeAllObjects];
                    [weakSelf.mySchedules removeAllObjects];
                    [weakSelf.myActivitys removeAllObjects];
                    [weakSelf.allActivitys removeAllObjects];
                    [weakSelf.hotActivitys removeAllObjects];
                    
                    
                    weakSelf.bannerDataSource = subModel.banner;
                    NSMutableArray *bannerImgURLStrings = @[].mutableCopy;
                    for (int i = 0; i < weakSelf.bannerDataSource.count; i++) {
                        CPBannerMJModel *bannerModel = [weakSelf.bannerDataSource objectAtIndex:i];
                        [bannerImgURLStrings addObject:bannerModel.imgUrl];
                    }
                    weakSelf.bannerImgURLStrings = bannerImgURLStrings;
                    weakSelf.bannerView.imageURLStringsGroup = bannerImgURLStrings;
                    
                    
                    weakSelf.myContracts = subModel.contracts;
                    weakSelf.mySchedules = subModel.schedules;
                    weakSelf.myActivitys = subModel.activitys;
                    
                    // check show style
                    // CPHomeVCShowStyleFirstOpen
                    if (weakSelf.isFirstOpen) {
                        weakSelf.showStyle = CPHomeVCShowStyleFirstOpen;
                        if (subModel.describe) {
//                            weakSelf.firstOpenDesc = subModel.describe;
                            NSArray *languages = [NSLocale preferredLanguages];
                            NSString *systemLanguage = @"";
                            if (languages.count > 0) {
                                systemLanguage = languages.firstObject;
                            }
                            NSString *currentLanguage = [[BWLocalizableHelper shareInstance] currentLanguage];
                            
                            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                            // app名称
                            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
                            
                            if ([currentLanguage isEqualToString:systemLanguage]) {
                                NSString *desc = [NSString stringWithFormat:kLocalizedTableString(@"First Open Tips", @"CPLocalizable"), app_Name];
                                weakSelf.firstOpenDesc = desc;
                            }
                            else if ([currentLanguage isEqualToString:@"zh-Hans-CN"]) {
                                NSString *desc = [NSString stringWithFormat:@"哈喽，欢迎来到%@，一个用来通过大家相同的活动行程来交友的平台，大家可以通过本平台查看具有相同行程的好友，并约定同行。", app_Name];
                                weakSelf.firstOpenDesc = desc;
                            }
                            else if ([currentLanguage isEqualToString:@"en-CN"]) {
                                NSString *desc = [NSString stringWithFormat:@"Hello, welcome to %@, a platform for making friends through the same activity itinerary. You can view friends with the same itinerary through this platform and make an appointment with peers.", app_Name];
                                weakSelf.firstOpenDesc = desc;
                            }
                            
                            
                            NSMutableArray *array = @[].mutableCopy;
                            NSDictionary *headerCellDict = @{@"headercell":@"firstopentips"}; // header tableview cell
                            [array addObject:headerCellDict];
                            [weakSelf.dataSource addObject:array];
                        }
                        // 确定section的个数
                        NSMutableArray *array1 = @[].mutableCopy;
                        NSDictionary *headerCellDict1 = @{@"headercell":@"firstopenSetSchedule"}; // header tableview cell
                        [array1 addObject:headerCellDict1];
                        [weakSelf.dataSource addObject:array1];
                        
                    }
                    // CPHomeVCShowStyleLogin
                    else if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
                        
                        if (subModel.contracts.count > 0 || subModel.schedules > 0 || subModel.activitys > 0) {
                            weakSelf.showStyle = CPHomeVCShowStyleLogin;
                            // 确定section的个数
                            NSMutableArray *array1 = @[].mutableCopy;
                            NSDictionary *headerCellDict1 = @{@"headercell":@"contracts"}; // header tableview cell
                            [array1 addObject:headerCellDict1];
                            [array1 addObject:subModel.contracts];
                            [weakSelf.dataSource addObject:array1];
                            
                            NSMutableArray *array2 = @[].mutableCopy;
                            NSDictionary *headerCellDict2 = @{@"headercell":@"schedules"}; // header tableview cell
                            [array2 addObject:headerCellDict2];
                            [array2 addObject:subModel.schedules];
                            [weakSelf.dataSource addObject:array2];
                            
                            NSMutableArray *array3 = @[].mutableCopy;
                            NSDictionary *headerCellDict3 = @{@"headercell":@"activitys"}; // header tableview cell
                            [array3 addObject:headerCellDict3];
                            [array3 addObject:subModel.activitys];
                            [weakSelf.dataSource addObject:array3];
                            
                        }
                        else {
                            weakSelf.showStyle = CPHomeVCShowStyleLoginNoData;
                            // 确定section的个数
                            NSMutableArray *array2 = @[].mutableCopy;
                            NSDictionary *headerCellDict2 = @{@"headercell":@"firstopenSetSchedule"}; // header tableview cell
                            [array2 addObject:headerCellDict2];
                            [array2 addObject:subModel.schedules];
                            [weakSelf.dataSource addObject:array2];
                            
                            NSMutableArray *array1 = @[].mutableCopy;
                            NSDictionary *headerCellDict1 = @{@"headercell":@"contracts"}; // header tableview cell
                            [array1 addObject:headerCellDict1];
                            [array1 addObject:subModel.contracts];
                            [weakSelf.dataSource addObject:array1];
                            
                            NSMutableArray *array3 = @[].mutableCopy;
                            NSDictionary *headerCellDict3 = @{@"headercell":@"activitys"}; // header tableview cell
                            [array3 addObject:headerCellDict3];
                            [array3 addObject:subModel.activitys];
                            [weakSelf.dataSource addObject:array3];
                        }
                        
                        
                    }
                    // CPHomeVCShowStyleNotLogin
                    else if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
                        weakSelf.showStyle = CPHomeVCShowStyleNotLogin;
                        // 确定section的个数
                        NSMutableArray *array1 = @[].mutableCopy;
                        NSDictionary *headerCellDict1 = @{@"headercell":@"firstopenSetSchedule"}; // header tableview cell
                        [array1 addObject:headerCellDict1];
                        [weakSelf.dataSource addObject:array1];
                    }
                    
                    // hot Activitys
                    [weakSelf.hotActivitys addObjectsFromArray:subModel.hotActivitys];
                    if (subModel.hotActivitys.count) {
                        NSMutableArray *array = @[].mutableCopy;
                        NSDictionary *headerCellDict = @{@"headercell":@"hotActivitys"}; // header tableview cell
                        [array addObject:headerCellDict];
                        [array addObject:weakSelf.hotActivitys];
                        [weakSelf.dataSource addObject:array];
                    }
                    
                    // all Activitys
                    [weakSelf.allActivitys addObjectsFromArray:subModel.allActivity];
                    if (subModel.allActivity.count) {
                        NSMutableArray *array = @[].mutableCopy;
                        NSDictionary *headerCellDict = @{@"headercell":@"allActivitys"}; // header tableview cell
                        [array addObject:headerCellDict];
                        [array addObject:weakSelf.allActivitys];
                        [weakSelf.dataSource addObject:array];
                    }
                    
                    
                }
                else{// loadmore
//                    [weakSelf.hotActivitys addObjectsFromArray:subModel.hotActivitys];
//                    NSLog(@"CPHomeVC loadmore weakSelf.hotActivitys:%@", weakSelf.hotActivitys);
                }
                
                NSLog(@"CPHomeVC requestHomeDataByCurrentIndex self.dataSource:%@", self.dataSource);
                weakSelf.currIndex++;
                
//                if (subModel.hotActivitys.count >= weakSelf.pageSize) {
//                    weakSelf.currIndex++;
//                }
//                else {
////                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
//                }
                [weakSelf.tableView reloadData];
                
            }
            else{
                NSLog(@"CPHomeVC requestHomeDataByCurrentIndex requestRegister 失败");
            }
            
        }
        else {
            NSLog(@"CPHomeVC requestHomeDataByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        [SVProgressHUD showInfoWithStatus:[error localizedDescription]];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPHomeVC  requestHomeDataByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}




#pragma mark -- share location
- (void)shareLocationToSomebody:(NSNotification*)notification{
    NSString *othersIMUserId = [notification.userInfo valueForKey:@"othersIMUserId"];
    [self setupConversation:othersIMUserId];
    
    NSLog(@"CPHomeVC shareLocationToSomebody");
    
    [self checkIfAuthLocation];
}

- (void)endingShareLocationToSomebody:(NSNotification*)notification{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
        NSLog(@"CPHomeVC endingShareLocationToSomebody");
    }
}

- (void)setupChatConnect{
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    
    NSLog(@"CPHomeVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@, [WFCCNetworkService sharedInstance].currentConnectionStatus:%ld", savedUserId, [WFCCNetworkService sharedInstance].userId, (long)[WFCCNetworkService sharedInstance].currentConnectionStatus);
    
    if (savedToken.length > 0 && savedUserId.length > 0) {
        if (![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]) {
            NSLog(@"CPHomeVC ![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]");
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
}

- (void)setupConversation:(NSString*)imUserId{
    //
    
    NSLog(@"CPHomeVC imUserId:%@", imUserId);
    
    self.conversation = [WFCCConversation conversationWithType:Single_Type target:imUserId line:0];
}

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
    DDLogDebug(@"CPHomeVC didUpdateLocations latitude:%f, longitude:%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude);
    
    
    WFCCShareLocationContent *shareLocationContent = [WFCCShareLocationContent contentWithLatitude:currLocation.coordinate.latitude longitude:currLocation.coordinate.longitude];
    [self sendMessageWithConversation:self.conversation message:shareLocationContent];
}


#pragma mark - send message
- (void)sendMessageWithConversation:(WFCCConversation*)conversation message:(WFCCMessageContent *)content {
    //发送消息时，client会发出"kSendingMessageStatusUpdated“的通知，消息界面收到通知后加入到列表中。
    [[WFCCIMService sharedWFCIMService] send:conversation content:content expireDuration:0 success:^(long long messageUid, long long timestamp) {
        NSLog(@"CPHomeVC send message success");
    } error:^(int error_code) {
        NSLog(@"CPHomeVC send message fail(%d)", error_code);
    }];
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
