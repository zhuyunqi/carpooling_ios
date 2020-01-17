//
//  CPMyActivityVC.m
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyActivityVC.h"
#import "LTSCalendarManager.h"
#import "CPHomeCell2.h"
#import "CPCalendarSelectMonthHeader.h"
#import "CPSetupActivityVC.h"
#import "CPActivityReqResultModel.h"
#import "CPActivityReqResultSubModel.h"
#import "CPActivityMJModel.h"
#import "CPActivityDetailVC.h"
#import "CPAddressModel.h"
#import "CPSetupActivityVC.h"


@interface CPMyActivityVC ()<CPCalendarSelectMonthHeaderDelegate, LTSCalendarEventSource, CPHomeCell2Delegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) CPCalendarSelectMonthHeader *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noDataLbl;
@property (nonatomic, strong) LTSCalendarManager *manager;
@property (nonatomic, strong) NSMutableDictionary *eventsByDate;

@property (nonatomic, strong) NSString *selectedDateString;

@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, strong) NSString *url;
@end

@implementation CPMyActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initRightBarItem];
    
    [self setupHeaderView];
    [self initCalendarUI];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-110-kTABBARHEIGHT-40)/2, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    noDataLbl.text = kLocalizedTableString(@"has NO Result", @"CPLocalizable");
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    
    
    _isRefresh = YES;
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
}

- (void)footerLoadMore{
    _isRefresh = NO;
    [self requestMyActivityByCurrentIndex:_currIndex url:_url];
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"schedule_btn"] style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSetupActivityVC *setupActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupActivityVC"];
    setupActivityVC.showType = SetupActivityVCTypeSetup;
    setupActivityVC.passValueblock = ^(BOOL success) {
        [SVProgressHUD show];
        self.currIndex = 1;
        [self requestMyActivityByCurrentIndex:self.currIndex url:self.url];
    };
    [self.navigationController pushViewController:setupActivityVC animated:YES];
}

- (void)setupHeaderView{
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CPCalendarSelectMonthHeader class]) owner:nil options:nil] lastObject];
    self.headerView.frame = CGRectMake(0, kNAVIBARANDSTATUSBARHEIGHT, kSCREENWIDTH, 40);
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        
        self.headerView.backgroundColor = dyColor;
        self.headerView.line.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.headerView.backgroundColor = [UIColor whiteColor];
        self.headerView.line.backgroundColor = [UIColor whiteColor];
    }
    
    self.headerView.delegate = self;
    [self.view addSubview:self.headerView];
    [self.view bringSubviewToFront:self.headerView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"CPMyActivityVC viewDidAppear [LTSCalendarAppearance share]");
    [self setupCalendarAppearance];
}

- (void)setupCalendarAppearance{
    [LTSCalendarAppearance share].weeksToDisplay = 1;
    [LTSCalendarAppearance share].weekDayHeight = 50;
    [LTSCalendarAppearance share].isShowSingleWeek = true;
    [LTSCalendarAppearance share].weekDayFormat = LTSCalendarWeekDayFormatShort;
    [LTSCalendarAppearance share].isShowLunarCalender = false;
    //设置默认滑动选中
    [LTSCalendarAppearance share].defaultSelected = false;
    //设置显示单周时滑动默认选中星期几
    //[LTSCalendarAppearance share].singWeekDefaultSelectedIndex = 2;
//    [LTSCalendarAppearance share].dayTextColor = [UIColor blackColor];
//    [LTSCalendarAppearance share].dayTextColorOtherMonth = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1];
}

- (void)initCalendarUI{
    [self setupCalendarAppearance];
    
    self.manager = [LTSCalendarManager new];
    self.manager.eventSource = self;
    self.manager.weekDayView = [[LTSCalendarWeekDayView alloc] init];
    
    CGFloat weekDayViewOriginY = 0;
    CGFloat weekDayViewHeight = 0;
    if (self.showType == MyActivityShowTypeMe) {
        self.title = kLocalizedTableString(@"My Activity", @"CPLocalizable");
        _topConstraint.constant = 120;
        weekDayViewOriginY = CGRectGetHeight(self.headerView.frame);
        weekDayViewHeight = 30;
        _url = @"/api/activity/v1/myActivity.json";
    }
    else if (self.showType == MyActivityShowTypeHome) {
        self.title = kLocalizedTableString(@"My Activity", @"CPLocalizable");
        _topConstraint.constant = 0;
        weekDayViewOriginY = 0;
        weekDayViewHeight = 0;
        self.headerView.hidden = true;
        self.manager.weekDayView.hidden = true;
//        _url = @"/api/activity/v1/activityList";
        _url = @"/api/activity/v1/enrollActivityList.json";
        
    }
    else if (self.showType == MyActivityShowTypeHotActivity) {
        self.title = kLocalizedTableString(@"Hot Activity", @"CPLocalizable");
        _topConstraint.constant = 0;
        weekDayViewOriginY = 0;
        weekDayViewHeight = 0;
        self.headerView.hidden = true;
        self.manager.weekDayView.hidden = true;
        _url = @"/api/activity/v1/hotActivity.json";
    }
    else if (self.showType == MyActivityShowTypeAllActivity) {
        self.title = kLocalizedTableString(@"All Activity", @"CPLocalizable");
        _topConstraint.constant = 0;
        weekDayViewOriginY = 0;
        weekDayViewHeight = 0;
        self.headerView.hidden = true;
        self.manager.weekDayView.hidden = true;
        _url = @"/api/activity/v1/allActivity.json";
    }
    
    self.manager.weekDayView.frame = CGRectMake(0, kNAVIBARANDSTATUSBARHEIGHT+weekDayViewOriginY, self.view.frame.size.width, weekDayViewHeight);
    [self.view addSubview:self.manager.weekDayView];
    
    
    self.manager.calenderScrollView = [[LTSCalendarScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.manager.weekDayView.frame) + weekDayViewHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.manager.weekDayView.frame))];
    [self.view addSubview:self.manager.calenderScrollView];
    

    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    self.manager.calenderScrollView.tableView = _tableView;
    
    //    [self createRandomEvents];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        
        self.manager.weekDayView.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.manager.weekDayView.backgroundColor = [UIColor whiteColor];
    }
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPActivityMJModel *model = [self.dataSource objectAtIndex:indexPath.section];
    return model.cellHeight;
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

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return [UIView new];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 10)];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPHomeCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPHomeCell2"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.showType = self.showType;
    cell.activityModel = [self.dataSource objectAtIndex:indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CPActivityMJModel *activityModel = [self.dataSource objectAtIndex:indexPath.section];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPActivityDetailVC *activityDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivityDetailVC"];
    activityDetailVC.activityModel = activityModel;
    [self.navigationController pushViewController:activityDetailVC animated:YES];
}


- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMMM yyyy";
    }
    
    return dateFormatter;
}

- (void)selectMonthLeftBtnAction:(id)sender{
    [self.manager loadPreviousPage];
}

- (void)selectMonthRightBtnAction:(id)sender{
    [self.manager loadNextPage];
}

//当前 选中的日期  执行的方法
- (void)calendarDidSelectedDate:(NSDate *)date {
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    NSLog(@"CPMyActivityVC calendarDidSelectedDate key:%@", key);
    self.headerView.titleLbl.text = key;
    
    NSString *dateString = [Utils dateToString:date withDateFormat:@"yyyy-MM-dd"];
    _selectedDateString = dateString;
    
    NSLog(@"CPMyActivityVC calendarDidSelectedDate requestMyActivityByCurrentIndex");
    [SVProgressHUD show];
    self.currIndex = 1;
    self.pageSize = 10;
    self.isRefresh = YES;
    [self requestMyActivityByCurrentIndex:_currIndex url:_url];
}

- (void)calendarDidLoadPageCurrentDate:(NSDate *)date {
    NSLog(@"CPMyActivityVC calendarDidLoadPageCurrentDate %@", [NSString stringWithFormat:@"%@",date]);
    NSString *key = [[self dateFormatter] stringFromDate:date];
    self.headerView.titleLbl.text = key;
}

- (void)calendarDidScrolledYear:(NSInteger)year month:(NSInteger)month{
    NSLog(@"CPMyActivityVC calendarDidScrolledYear 当前年份：%ld,当前月份：%ld", (long)year, (long)month);
}


- (void)requestMyActivityByCurrentIndex:(NSUInteger)index url:(NSString*)url{
    NSLog(@"requestMyActivityByCurrentIndex self.currIndex:%lu, self.selectedDateString:%@, self.pageSize:%lu", (unsigned long)self.currIndex, self.selectedDateString, (unsigned long)self.pageSize);
    
    NSMutableDictionary *param = @{}.mutableCopy;
//    if (self.showType == MyActivityShowTypeHome) {
    if (self.showType == MyActivityShowTypeHome || self.showType == MyActivityShowTypeHotActivity || self.showType == MyActivityShowTypeAllActivity) {
        param = @{
                                       @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                       @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                       }.mutableCopy;
    }
    else {
        
        if (![self.selectedDateString containsString:@"00:00:00"]) {
            self.selectedDateString = [NSString stringWithFormat:@"%@ 00:00:00", self.selectedDateString];
        }
        
        NSTimeInterval timestamp1 = [Utils getTimeStampUTCWithTimeString:self.selectedDateString format:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeInterval timestamp2 = timestamp1 + 86340;
        
        param = @{
                                       @"startDate":[NSNumber numberWithDouble:timestamp1],
                                       @"endDate":[NSNumber numberWithDouble:timestamp2],
                                       @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                       @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                       }.mutableCopy;
    }
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@%@", BaseURL, url] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyActivityVC requestMyActivityByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPActivityReqResultModel *masterModel = [CPActivityReqResultModel mj_objectWithKeyValues:responseObject];
            CPActivityReqResultSubModel *subModel = masterModel.data;

            if (masterModel.code == 200) {
                if (weakSelf.isRefresh == YES) {
                    if (subModel.data.count == 0) {
                        weakSelf.noDataLbl.hidden = NO;
                    }
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                
                for (int i = 0; i < subModel.data.count; i++) {
                    CPActivityMJModel *model = [subModel.data objectAtIndex:i];
                    
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
                }
                
//                if (subModel.data.count >= weakSelf.pageSize) {
//                    weakSelf.currIndex++;
//                }
//                else {
//                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
//                }
                weakSelf.currIndex++;
                
                if (weakSelf.dataSource.count > 0) {
                    weakSelf.noDataLbl.hidden = YES;
                }
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
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyActivityVC  requestMyActivityByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)homeCell2LikeAction:(NSIndexPath *)indexPath{
    NSLog(@"CPMyActivityVC homeCell2LikeAction indexPath.row:%ld", (long)indexPath.row);
    
    CPActivityMJModel *model = [self.dataSource objectAtIndex:indexPath.section];
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/activity/v1/collectActivity", BaseURL] parameters:@{@"activityId":[NSNumber numberWithInteger:model.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyActivityVC homeCell2LikeAction responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSLog(@"CPMyActivityVC homeCell2LikeAction 成功");
                model.collect += 1;
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
                
                NSLog(@"CPMyActivityVC homeCell2LikeAction 失败");
            }
        }
        else {
            NSLog(@"CPMyActivityVC homeCell2LikeAction 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyActivityVC homeCell2LikeAction error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
//    }
}



- (void)homeCell2EditAction:(NSIndexPath *)indexPath{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSetupActivityVC *setupActivityVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupActivityVC"];
    setupActivityVC.showType = SetupActivityVCTypeEdit;
    setupActivityVC.activityModel = [self.dataSource objectAtIndex:indexPath.section];
    setupActivityVC.passValueblock = ^(BOOL success) {
        [SVProgressHUD show];
        self.currIndex = 1;
        [self requestMyActivityByCurrentIndex:self.currIndex url:self.url];
    };
    [self.navigationController pushViewController:setupActivityVC animated:YES];
    
    NSLog(@"CPMyActivityVC homeCell2EditAction indexPath.section:%ld", (long)indexPath.section);
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
