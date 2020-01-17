//
//  CPScheduleVC.m
//  Carpooling
//
//  Created by bw on 2019/5/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPScheduleVC.h"
#import "LTSCalendarManager.h"
#import "CPScheduleCell1.h"
#import "CPMyScheduleCell.h"
#import "CPSetupScheduleVC.h"
#import "CPMatchingScheduleVC.h"
#import "CPContractDetailVC.h"
#import "CPScheduleReqResultModel.h"
#import "CPScheduleReqResultSubModel.h"
#import "CPScheduleMJModel.h"
#import "CPAddressModel.h"

#import "SAMKeychain.h"

#import <Realm.h>
#import "CPUserInfoModel.h"

#import <WFChatClient/WFCCNetworkService.h>
#import "WFCUMessageListViewController.h"
#import "WFCUStrangerMessageController.h"

@interface CPScheduleVC ()<LTSCalendarEventSource, UITableViewDelegate, UITableViewDataSource, CPScheduleCell1Delegate, CPMyScheduleCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noDataLbl;
@property (nonatomic, strong) LTSCalendarManager *manager;
@property (nonatomic, strong) NSMutableDictionary *eventsByDate;

@property (nonatomic, strong) NSString *selectedDateString;

@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, strong) NSIndexPath *selectIndexPath; // select chat with somebody
@end

@implementation CPScheduleVC

- (void)awakeFromNib{
    [super awakeFromNib];
    
    //接受合约成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSchedule) name:@"AcceptContractSuccess" object:nil];
    
    //注册并登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupAndLoginSuccess:) name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
    
    //退出登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSchedule) name:@"USERLOGOUTSUCCESS" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AcceptContractSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERSIGNUPANDLOGINSUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERLOGOUTSUCCESS" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = kLocalizedTableString(@"Schedule", @"CPLocalizable");;
    if (@available(iOS 11,*)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
    }
    
    [self initCalendarUI];
    
    [self initRightBarItem];
    
    _isRefresh = YES;
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    

    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kTABBARHEIGHT, 0);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshSchedule)];
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-80-kTABBARHEIGHT-40)/2, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
}

- (void)refreshSchedule{
    if (self.selectedDateString) {
        self.isRefresh = YES;
        _currIndex = 1;
        [self requestMyScheduleByCurrentIndex:_currIndex];
    }
}

- (void)userSignupAndLoginSuccess:(NSNotification*)notification{
    if (self.selectedDateString) {
        self.noDataLbl.hidden = YES;
        self.isRefresh = YES;
        _currIndex = 1;
        [self requestMyScheduleByCurrentIndex:_currIndex];
    }
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"schedule_btn"] style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSetupScheduleVC *setupScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupScheduleVC"];
    setupScheduleVC.showType = ScheduleVCShowTypeSetup;
    setupScheduleVC.passValueblock = ^(BOOL success) {
        [SVProgressHUD show];
        self.currIndex = 1;
        [self requestMyScheduleByCurrentIndex:self.currIndex];
    };
    [self.navigationController pushViewController:setupScheduleVC animated:YES];
}

- (void)footerLoadMore{
    self.isRefresh = NO;
    [self requestMyScheduleByCurrentIndex:_currIndex];
}

- (void)initCalendarUI{
    [self setupCalendarAppearance];

    self.manager = [LTSCalendarManager new];
    self.manager.eventSource = self;
    self.manager.weekDayView = [[LTSCalendarWeekDayView alloc]initWithFrame:CGRectMake(0, kNAVIBARANDSTATUSBARHEIGHT, self.view.frame.size.width, 30)];
    [self.view addSubview:self.manager.weekDayView];
    
    self.manager.calenderScrollView = [[LTSCalendarScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.manager.weekDayView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.manager.weekDayView.frame))];
    [self.view addSubview:self.manager.calenderScrollView];
    

    self.manager.calenderScrollView.tableView = _tableView;
    
    
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"CPScheduleVC viewDidAppear [LTSCalendarAppearance share]");
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


- (void)calendarDidLoadPageCurrentDate:(NSDate *)date {
    NSLog(@"CPScheduleVC calendarDidLoadPageCurrentDate %@", [NSString stringWithFormat:@"%@",date]);
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    self.navigationItem.title = key;
}


// 该日期是否有事件
- (BOOL)calendarHaveEventWithDate:(NSDate *)date {
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(self.eventsByDate[key] && [self.eventsByDate[key] count] > 0){
        return YES;
    }
    return NO;
}

//当前 选中的日期  执行的方法
- (void)calendarDidSelectedDate:(NSDate *)date {
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
//    self.label.text =  key;
    NSArray *events = self.eventsByDate[key];
    self.navigationItem.title = key;
    NSLog(@"CPScheduleVC calendarDidSelectedDate:%@", date);
    if (events.count>0) {
        
        //该日期有事件    tableView 加载数据
    }
    
    NSString *dateString = [Utils dateToString:date withDateFormat:@"yyyy-MM-dd"];
    _selectedDateString = dateString;
    
    NSLog(@"CPScheduleVC calendarDidSelectedDate requestMyScheduleByCurrentIndex");
    [SVProgressHUD show];
    self.currIndex = 1;
    self.pageSize = 10;
    self.isRefresh = YES;
    [self requestMyScheduleByCurrentIndex:_currIndex];
}

- (void)calendarDidScrolledYear:(NSInteger)year month:(NSInteger)month{
    NSLog(@"CPScheduleVC calendarDidScrolledYear 当前年份：%ld,当前月份：%ld", (long)year, (long)month);
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


#pragma mark - UITableView UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return _dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPScheduleMJModel *model = [self.dataSource objectAtIndex:indexPath.section];
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
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    
    if (scheduleMJModel.status == 0) {
        CPMyScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMyScheduleCell"];
        cell.delegate = self;
        cell.scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
        cell.indexPath = indexPath;
        
        return cell;
    }
    else {
        CPScheduleCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPScheduleCell1"];
        cell.delegate = self;
        cell.scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
        cell.indexPath = indexPath;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    if (scheduleMJModel.status == 2 || scheduleMJModel.status == 3) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
        contractDetailVC.contractId = scheduleMJModel.contractId;
        [self.navigationController pushViewController:contractDetailVC animated:YES];
        
    }
    else {
        if (scheduleMJModel.status == 0 || scheduleMJModel.status == 1) {
            [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Schedule not contracted", @"CPLocalizable")];
        }
    }
}

#pragma mark - 左滑删除, 单个删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    if (scheduleMJModel.status == 0 || scheduleMJModel.status == 3) {
        return YES;
    }
    return NO;
}

- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self requestDeleteScheduleByIndexPath:indexPath];
        //        completionHandler (YES);
    }];
    //    deleteRowAction.image = [UIImage imageNamed:@"icon_del"];
    //    deleteRowAction.backgroundColor = [UIColor blueColor];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    config.performsFirstActionWithFullSwipe = NO;
    
    return config;
}

//2
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

//3
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kLocalizedTableString(@"Delete", @"CPLocalizable");
}

//4
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"tableView editingStyle forRowAtIndexPath indexPath.row %ld",(long)indexPath.row);
        [self requestDeleteScheduleByIndexPath:indexPath];
    }
}


- (void)scheduleCell1ChatBtnAction:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    [self requestIfUserIsLogin];
}

- (void)scheduleCell1PhoneBtnAction:(NSIndexPath *)indexPath{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    if (scheduleMJModel.cjContractUserVo.mobile) {
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@", scheduleMJModel.cjContractUserVo.mobile];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

- (void)scheduleCell1DetailBtnAction:(NSIndexPath *)indexPath{
    //
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPContractDetailVC *contractDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"CPContractDetailVC"];
    CPScheduleMJModel *cheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    contractDetailVC.contractId = cheduleMJModel.contractId;
    [self.navigationController pushViewController:contractDetailVC animated:YES];
}

- (void)myScheduleCellDeleteBtnAction:(NSIndexPath *)indexPath{
    [self requestDeleteScheduleByIndexPath:indexPath];
}

- (void)scheduleCell1NaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
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

#pragma mark - CPMyScheduleCellDelegate
- (void)myScheduleCellEditBtnAction:(NSIndexPath *)indexPath{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSetupScheduleVC *setupScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupScheduleVC"];
    setupScheduleVC.showType = ScheduleVCShowTypeEdit;
    setupScheduleVC.scheduleMJModel = scheduleMJModel;
    setupScheduleVC.passValueblock = ^(BOOL success) {
        [SVProgressHUD show];
        self.currIndex = 1;
        [self requestMyScheduleByCurrentIndex:self.currIndex];
    };
    [self.navigationController pushViewController:setupScheduleVC animated:YES];
}

- (void)myScheduleCellMatchingBtnAction:(NSIndexPath *)indexPath{
    
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPMatchingScheduleVC *matchingScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMatchingScheduleVC"];
    matchingScheduleVC.scheduleMJModel = scheduleMJModel;
    matchingScheduleVC.requestParams = [scheduleMJModel mj_keyValues];
    [matchingScheduleVC.requestParams removeObjectForKey:@"userVo"];
    [self.navigationController pushViewController:matchingScheduleVC animated:YES];
}


- (void)requestMyScheduleByCurrentIndex:(NSUInteger)index{
    NSLog(@"requestMyScheduleByCurrentIndex self.currIndex:%lu, self.selectedDateString:%@, self.pageSize:%lu", (unsigned long)self.currIndex, self.selectedDateString, (unsigned long)self.pageSize);
    
    if (![self.selectedDateString containsString:@"00:00:00"]) {
        self.selectedDateString = [NSString stringWithFormat:@"%@ 00:00:00", self.selectedDateString];
    }
    
    NSTimeInterval timestamp1 = [Utils getTimeStampUTCWithTimeString:self.selectedDateString format:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval timestamp2 = timestamp1 + 86340;
    
    NSMutableDictionary *param = @{
                            @"startArriveTime":[NSNumber numberWithDouble:timestamp1],
                            @"endArriveTime":[NSNumber numberWithDouble:timestamp2],
                            @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                            @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                            }.mutableCopy;
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/scheduling/v1/mySchedulingContract.json", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPScheduleVC requestMyScheduleByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPScheduleReqResultModel *masterModel = [CPScheduleReqResultModel mj_objectWithKeyValues:responseObject];
            CPScheduleReqResultSubModel *subModel = masterModel.data;

            if (masterModel.code == 200) {
                if (weakSelf.isRefresh == YES) {
                    if (subModel.data.count == 0) {
                        weakSelf.noDataLbl.hidden = NO;
                        weakSelf.noDataLbl.text = kLocalizedTableString(@"The date has NO schedule Result", @"CPLocalizable");
                    }
                    
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                
                for (int i = 0; i < subModel.data.count; i++) {
                    CPScheduleMJModel *model = [subModel.data objectAtIndex:i];
                    
                    CGSize size1 = W_GET_STRINGSIZE(model.fromAddressVo.address, kSCREENWIDTH-72, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height1 =  size1.height;
                    
                    CGSize size2 = W_GET_STRINGSIZE(model.toAddressVo.address, kSCREENWIDTH-72, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height2 = size2.height;
                    
                    NSDate *date = [Utils getDateWithTimestamp:model.arriveTime];
                    NSString *time = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
                    NSString *str = time;
                    if (model.schedulingCycle && model.schedulingCycle.length > 0) {
                        str = [NSString stringWithFormat:@"%@ %@(%@)", time, kLocalizedTableString(@"repeat", @"CPLocalizable"), model.schedulingCycle];
                    }
                    
                    CGSize size3 = W_GET_STRINGSIZE(str, kSCREENWIDTH-86, MAXFLOAT, [UIFont systemFontOfSize:14.f]);
                    CGFloat height3 = size3.height;
                    
                    CGFloat totalHeight = height1 +height2 +height3 +180;
                    
                    if (model.status == 0) {
                        model.cellHeight = totalHeight - 30;
                    }
                    else if (model.status == 1) {
                        model.cellHeight = totalHeight - 70;
                    }
                    else {
                        model.cellHeight = totalHeight;
                    }
                    
                }
                
                weakSelf.currIndex++;
                if (weakSelf.dataSource.count > 0) {
                    weakSelf.noDataLbl.hidden = YES;
                    weakSelf.noDataLbl.text = kLocalizedTableString(@"The date has NO schedule Result", @"CPLocalizable");
                }
                [weakSelf.tableView reloadData];
                
            }
            else{
                if (masterModel.code == 401) {
                    weakSelf.noDataLbl.hidden = NO;
                    weakSelf.noDataLbl.text = kLocalizedTableString(@"Please Login", @"CPLocalizable");
                }
                NSLog(@"CPScheduleVC requestMyScheduleByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPScheduleVC requestMyScheduleByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPScheduleVC  requestMyScheduleByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)requestDeleteScheduleByIndexPath:(NSIndexPath*)indexPath{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/scheduling/v1/deleteScheduling", BaseURL] parameters:@{@"id":[NSNumber numberWithInteger:scheduleMJModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPScheduleVC requestDeleteSchedule responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ScheduleUpdateSuccess" object:nil];
                //删除数据，和删除动画
                [weakSelf.dataSource removeObjectAtIndex:indexPath.section];
                [weakSelf.tableView deleteSection:indexPath.section withRowAnimation:UITableViewRowAnimationTop];
            }
            else{
                NSLog(@"CPScheduleVC requestDeleteSchedule 失败");
            }
        }
        else {
            NSLog(@"CPScheduleVC requestDeleteSchedule 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPScheduleVC requestDeleteSchedule error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
    
}


#pragma mark - 请求用户是否登录
- (void)requestIfUserIsLogin{
    WS(weakSelf)
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/islogin", BaseURL] parameters:nil success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPScheduleVC requestIfUserIsLogin responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
                NSLog(@"CPScheduleVC requestIfUserIsLogin 拼车号:%@ has login ", account);
                
                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
                NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
                
                NSLog(@"CPScheduleVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", savedUserId, [WFCCNetworkService sharedInstance].userId);
                
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
                NSLog(@"CPScheduleVC requestIfUserIsLogin not login");
                
                // im 登录
                NSString *anonymousChatAccount = [SAMKeychain passwordForService:kKeychainAnonymousChatAccountService account:kKeychainAnonymousChatAccount];
                
                [weakSelf anonymousUserGetIMTokenAndUserId:anonymousChatAccount];
            }
            
        }
        else {
            NSLog(@"CPScheduleVC requestIfUserIsLogin 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPScheduleVC requestIfUserIsLogin error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)anonymousUserGetIMTokenAndUserId:(NSString*)anonymousAccount{
    [SVProgressHUD show];
    NSString *clientId = [[WFCCNetworkService sharedInstance] getClientId];
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/auth/v1/anonymousimlogin", BaseURL] parameters:@{@"phone":anonymousAccount, @"clientId":clientId}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPScheduleVC anonymousUserGetIMTokenAndUserId responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSDictionary *dict = [[responseObject valueForKey:@"data"] valueForKey:@"imResult"];
                
                if (nil != dict) {
                    // 匿名im 登录
                    NSString *anonymousUserId = [dict valueForKey:@"userId"];
                    NSString *anonymousToken = [dict valueForKey:@"token"];
                    NSLog(@"CPScheduleVC anonymousUserGetIMTokenAndUserId anonymousUserId:%@, [WFCCNetworkService sharedInstance].userId:%@", anonymousUserId, [WFCCNetworkService sharedInstance].userId);
                    
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
                    
                    [weakSelf goChatWithSomebody:weakSelf.selectIndexPath.section];
                }
            }
            
        }
        else {
            NSLog(@"CPScheduleVC anonymousUserGetIMTokenAndUserId 失败");
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPScheduleVC anonymousUserGetIMTokenAndUserId error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)goChatWithSomebody:(NSInteger)index{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:index];
    NSString *currentUserAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, scheduleMJModel.cjContractUserVo.imUserId:%@", account, scheduleMJModel.cjContractUserVo.imUserId);
    CPUserInfoModel *otherUserRLMModel = scheduleMJModel.cjContractUserVo;
    
    // 已登录
    if (currentUserAccount) {
        if (scheduleMJModel.isFriend) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
