//
//  CPSetupScheduleVC.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSetupScheduleVC.h"
#import "CPInitShortTermContractCell2.h"
#import "CPUserInfoCell2.h"
#import "CPInitShortTermContractCell3.h"
#import "CPInitShortTermContractCell4.h"
#import "CPSchedulePeriodVC.h"
#import "BWSheetBottmView.h"
#import "SSChatLocationController.h"
#import "CPMyAddressPageVC.h"
#import "CPSelectContractThemeVC.h"
#import "CPScheduleMJModel.h"
#import "CPAddressModel.h"
#import "CPMatchingScheduleVC.h"

#import "CPInitShortTermContractCell4.h"
#import "CPSchedulePeriodVC.h"
#import "IQActionSheetPickerView.h"

@interface CPSetupScheduleVC ()<BWSheetBottmViewDelegate, IQActionSheetPickerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property(nonatomic, strong) NSMutableDictionary *param;

@property (nonatomic, assign) NSIndexPath *addressSelectIndexPath; // 选择地址时的indexpath
// 位置 dict
@property(nonatomic, strong) NSMutableDictionary *locationDict1;
@property(nonatomic, strong) NSMutableDictionary *locationDict2;
@property(nonatomic, strong) NSString *theme;
@property(nonatomic, strong) NSMutableAttributedString *etaTime; // 预计驾车时间
@property(nonatomic, strong) NSString *weekString;
@property (nonatomic, strong) NSString *selectedWeekNum;
@property (nonatomic, assign) BOOL isCalendarSelected;
@property(nonatomic, strong) NSString *calendarSelectedDateString;
@property(nonatomic, strong) NSString *selectedTimeString;
@property(nonatomic, strong) NSString *arriveTimeString;
@property(nonatomic, strong) NSString *remark;

@property(nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSUInteger dataid;
@end

@implementation CPSetupScheduleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
//                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                return RGBA(243, 244, 246, 1);
            }
            else {
//                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        _bottomView.backgroundColor = dyColor3;
        self.view.backgroundColor = dyColor3;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    
    if (_showType == ScheduleVCShowTypeSetup) {
        self.title = kLocalizedTableString(@"Setup Schedule", @"CPLocalizable");
        self.url = @"/api/scheduling/v1/saveScheduling.json";
    }
    else if (_showType == ScheduleVCShowTypeEdit) {
        self.title = kLocalizedTableString(@"Edit Schedule", @"CPLocalizable");
        self.url = @"/api/scheduling/v1/updateScheduling.json";
        // schedulingCarpoolVo
    }
    
    
    if (kBOTTOMSAFEHEIGHT == 0) {
        _bottomConstraint.constant = 0;
    }
    else {
        _bottomConstraint.constant = kBOTTOMSAFEHEIGHT;
    }
    
    if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        _leftBtn.backgroundColor = RGBA(220, 220, 220, 1);
        _leftBtn.enabled = NO;
    }
    else {
        _leftBtn.backgroundColor = RGBA(120, 202, 195, 1);
        _leftBtn.enabled = YES;
    }
    _leftBtn.layer.cornerRadius = _leftBtn.frame.size.height/2;
    _leftBtn.layer.masksToBounds = YES;
    [_leftBtn setTitle:kLocalizedTableString(@"Save", @"CPLocalizable") forState:UIControlStateNormal];
    
    
    _rightBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _rightBtn.layer.cornerRadius = _rightBtn.frame.size.height/2;
    _rightBtn.layer.masksToBounds = YES;
    [_rightBtn setTitle:kLocalizedTableString(@"Go Matching", @"CPLocalizable") forState:UIControlStateNormal];
    
    self.etaTime = [[NSMutableAttributedString alloc] initWithString:@""];
    
    //注册并登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectContractAddress:) name:@"SELECTCONTRACTADDRESSSUCCESS" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SELECTCONTRACTADDRESSSUCCESS" object:nil];
}

- (void)selectContractAddress:(NSNotification*)notification{
    NSDictionary *dict = notification.userInfo;
    if (_addressSelectIndexPath.row == 1) {
        _locationDict1 = dict.mutableCopy;
        if (nil != self.locationDict2) {
            CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
            CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
            
            [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:_addressSelectIndexPath.section];
        [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        
    }
    else if (_addressSelectIndexPath.row == 3) {
        _locationDict2 = dict.mutableCopy;
        if (nil != self.locationDict1) {
            CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
            CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
            
            [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:_addressSelectIndexPath.section];
        [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setScheduleMJModel:(CPScheduleMJModel *)scheduleMJModel{
    if (_scheduleMJModel != scheduleMJModel) {
        _scheduleMJModel = scheduleMJModel;
        
        _dataid = scheduleMJModel.dataid;
        _theme = scheduleMJModel.subject;
        
        _locationDict1 = @{}.mutableCopy;
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.address forKey:@"address"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.addressName forKey:@"addressName"];
        [_locationDict1 setValue:[NSNumber numberWithDouble:scheduleMJModel.fromAddressVo.latitude] forKey:@"latitude"];
        [_locationDict1 setValue:[NSNumber numberWithDouble:scheduleMJModel.fromAddressVo.longitude] forKey:@"longitude"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.thoroughfare forKey:@"thoroughfare"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.subThoroughfare forKey:@"subThoroughfare"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.locality forKey:@"locality"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.subLocality forKey:@"subLocality"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.administrativeArea forKey:@"administrativeArea"];
        [_locationDict1 setValue:scheduleMJModel.fromAddressVo.subAdministrativeArea forKey:@"subAdministrativeArea"];
        
        
        _locationDict2 = @{}.mutableCopy;
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.address forKey:@"address"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.addressName forKey:@"addressName"];
        [_locationDict2 setValue:[NSNumber numberWithDouble:scheduleMJModel.toAddressVo.latitude] forKey:@"latitude"];
        [_locationDict2 setValue:[NSNumber numberWithDouble:scheduleMJModel.toAddressVo.longitude] forKey:@"longitude"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.thoroughfare forKey:@"thoroughfare"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.subThoroughfare forKey:@"subThoroughfare"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.locality forKey:@"locality"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.subLocality forKey:@"subLocality"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.administrativeArea forKey:@"administrativeArea"];
        [_locationDict2 setValue:scheduleMJModel.toAddressVo.subAdministrativeArea forKey:@"subAdministrativeArea"];
        
        
        _weekString = scheduleMJModel.schedulingCycle;
        _selectedWeekNum = scheduleMJModel.weekNum;
        
        
        NSDate *date = [Utils getDateWithTimestamp:scheduleMJModel.arriveTime];
        NSString *dateStr = [Utils dateToString:date withDateFormat:@"yyyy-MM-dd HH:mm"];
        _arriveTimeString = dateStr;
        
        
        CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
        CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
        [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
        
        
        [self.tableView reloadData];
    }
}

#pragma mark - UITableView UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 || indexPath.row == 4) {
        return 90;
    }
    return CPREGULARCELLHEIGHT;
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
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell1"];
        ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Theme", @"CPLocalizable");
        ((CPUserInfoCell2*)cell).subTitleLbl.text =  _theme == nil ? @"" : _theme;
    }
    else if (indexPath.row == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell2"];
        ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Stroke Start", @"CPLocalizable");
    }
    else if (indexPath.row == 2) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell3"];
        ((CPInitShortTermContractCell2*)cell).titleLbl.text = [_locationDict1 valueForKey:@"address"];
    }
    else if (indexPath.row == 3) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell4"];
        ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Stroke End", @"CPLocalizable");
    }
    else if (indexPath.row == 4) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell5"];
        ((CPInitShortTermContractCell2*)cell).titleLbl.text = [_locationDict2 valueForKey:@"address"];
    }
    else if (indexPath.row == 5) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell6"];
        ((CPInitShortTermContractCell3*)cell).subTitleLbl.attributedText = self.etaTime;
    }
    else if (indexPath.row == 6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell8"];
        ((CPInitShortTermContractCell4*)cell).titleLbl.text = kLocalizedTableString(@"Schedule Cycle", @"CPLocalizable");
        ((CPInitShortTermContractCell4*)cell).subTitleLbl.text = _weekString;
        
    }
    else if (indexPath.row == 7) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupScheduleCell7"];
        ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Arrive Time", @"CPLocalizable");
        
        NSDate *date = [Utils stringToDate:_arriveTimeString withDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *dateStr = [Utils dateToString:date withDateFormat:@"YYYY/MM/dd EEE HH:mm"];
        ((CPUserInfoCell2*)cell).subTitleLbl.text = dateStr;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPSelectContractThemeVC *selectContractThemeVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSelectContractThemeVC"];
        selectContractThemeVC.titleType = 0;
        if (self.theme) {
            selectContractThemeVC.aString = self.theme;
        }
        selectContractThemeVC.passValueblock = ^(NSString * _Nonnull aSting) {
            //
            self.theme = aSting;
            NSLog(@"selectContractThemeVC 0 result:%@", aSting);
            [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:selectContractThemeVC animated:YES];
        
    }
    else if (indexPath.row == 1) {
        // 通过我的地址列表选择
        self.addressSelectIndexPath = indexPath;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPMyAddressPageVC *myAddressPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyAddressPageVC"];
        [self.navigationController pushViewController:myAddressPageVC animated:YES];
    }
    else if (indexPath.row == 2) {
        // 通过地图选择地址
        SSChatLocationController *chatLocationController = [[SSChatLocationController alloc] init];
        chatLocationController.locationBlock = ^(NSDictionary *locationDict, WFCULocationPoint *point) {
            
            self.param = nil;
            self.locationDict1 = locationDict.mutableCopy;
            
            [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            if (nil != self.locationDict2) {
                CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
                CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
                
                [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
            }
        };
        [self.navigationController pushViewController:chatLocationController animated:YES];
        
    }
    else if (indexPath.row == 3) {
        // 通过我的地址列表选择
        self.addressSelectIndexPath = indexPath;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPMyAddressPageVC *myAddressPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyAddressPageVC"];
        [self.navigationController pushViewController:myAddressPageVC animated:YES];
        
    }
    else if (indexPath.row == 4) {
        // 通过地图选择地址
        SSChatLocationController *chatLocationController = [[SSChatLocationController alloc] init];
        chatLocationController.locationBlock = ^(NSDictionary *locationDict, WFCULocationPoint *point) {
            self.param = nil;
            self.locationDict2 = locationDict.mutableCopy;
            
            [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            if (nil != self.locationDict1) {
                CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
                CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
                
                [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
            }
        };
        [self.navigationController pushViewController:chatLocationController animated:YES];
        
    }
    else if (indexPath.row == 6) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPSchedulePeriodVC *schedulePeriodVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSchedulePeriodVC"];
        schedulePeriodVC.selectedWeekNum = self.scheduleMJModel.weekNum;
        schedulePeriodVC.passValueblock = ^(NSString * _Nonnull aSting, NSString * _Nonnull aSting2) {
            //
            self.weekString = aSting;
            self.selectedWeekNum = aSting2;
            
            if (self.scheduleMJModel) {
                self.scheduleMJModel.schedulingCycle = aSting;
                self.scheduleMJModel.weekNum = aSting2;
            }
            NSLog(@"CPSchedulePeriodVC 0 weekString:%@, self.selectedWeekNum:%@", aSting, aSting2);
            [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:schedulePeriodVC animated:YES];
    }
    else if (indexPath.row == 7) {
        BWSheetBottmView *bottomView = [[BWSheetBottmView alloc] initWithTitle:@"" delegate:self];
        bottomView.actionSheetPickerStyle = BWActionSheetPickerStyleOnlyTimePicker;
        [bottomView.actionToolbar.cancelButton setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBA(100, 100, 100, 1), NSFontAttributeName:[UIFont systemFontOfSize:17.f]} forState:UIControlStateNormal];
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return RGBA(37, 37, 37, 1);
                }
                else {
                    return [UIColor labelColor];
                }
                
            }];
            
            [bottomView.actionToolbar.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:dyColor, NSFontAttributeName:[UIFont boldSystemFontOfSize:17.f]} forState:UIControlStateNormal];
            
        } else {
            // Fallback on earlier versions
            [bottomView.actionToolbar.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBA(37, 37, 37, 1), NSFontAttributeName:[UIFont boldSystemFontOfSize:17.f]} forState:UIControlStateNormal];
        }
        
        //            bottomView.actionToolbar.cancelButton = nil;
        bottomView.actionToolbar.doneButton.title = kLocalizedTableString(@"Confirm", @"CPLocalizable");
        bottomView.height = 350+kBOTTOMSAFEHEIGHT;
        [bottomView setTag:10001];
        [bottomView show];
    }
}


#pragma mark - BWSheetBottmViewDelegate
// date time
- (void)bwActionSheetPickerView:(BWSheetBottmView *)pickerView didSelectDate:(NSDate *)date{
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView didSelectDate:%@", date);
    //创建一个日期格式
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    if (!_isCalendarSelected) {
        fmt.dateFormat = @"YYYY-MM-dd";
        _calendarSelectedDateString = [fmt stringFromDate:date];
    }
    
    fmt.dateFormat = @"HH:mm";
    _selectedTimeString = [fmt stringFromDate:date];
    
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView didSelectDate _calendarSelectedDateString:%@, _selectedTimeString:%@", _calendarSelectedDateString, _selectedTimeString);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
    _arriveTimeString = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, _selectedTimeString];
    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}

// date
- (void)bwActionSheetPickerView:(BWSheetBottmView *)pickerView calendarDidSelectDate:(NSDate *)date{
    _isCalendarSelected = YES;
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView calendarDidSelectDate:%@", date);
    //    _calendarSelectedDate = date;
    //创建一个日期格式
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"YYYY-MM-dd";
    _calendarSelectedDateString = [fmt stringFromDate:date];
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView calendarDidSelectDate _calendarSelectedDateString:%@, _selectedTimeString:%@", _calendarSelectedDateString, _selectedTimeString);
}

#pragma mark - IQActionSheetPickerView IQActionSheetPickerViewDelegate
- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date{
    NSLog(@"CPInitLongTermContractVC actionSheetPickerView didSelectDate:%@", date);
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm";
    
    _selectedTimeString = [fmt stringFromDate:date];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
    _arriveTimeString = _selectedTimeString;
    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}



#pragma mark - MKDirections calculateETA
- (void)getTransitETAWithBeginCoord:(CLLocationCoordinate2D)beginCoord andEndCoord:(CLLocationCoordinate2D)endCoord{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *placemark1 = [[MKPlacemark alloc] initWithCoordinate:beginCoord addressDictionary:nil];
    MKMapItem *beginItem = [[MKMapItem alloc] initWithPlacemark:placemark1];
    
    MKPlacemark *placemark2 = [[MKPlacemark alloc] initWithCoordinate:endCoord addressDictionary:nil];
    MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:placemark2];
    
    [request setSource:beginItem];
    [request setDestination:endItem];
    
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"calculateETAWithCompletionHandler error");
        }
        else{
            NSLog(@"response.expectedTravelTime:%f", response.expectedTravelTime);
            NSString *time = @"";
            NSInteger hour = response.expectedTravelTime / 3600;
            NSInteger min = (response.expectedTravelTime -hour*3600) /60;
            
            // CN
            NSInteger strLength1 = 2; // "预计"
            NSInteger strLength2 = 0;
            NSInteger strLength3 = 2; // "小时"
            // US
            //            NSInteger strLength1 = 8; // "estimate"
            //            NSInteger strLength2 = 0;
            //            NSInteger strLength3 = 4; // "hour"
            NSInteger strLength4 = [NSString stringWithFormat:@"%ld", min].length;
            
            NSString *estimateStr = kLocalizedTableString(@"Estimate", @"CPLocalizable");
            if ([estimateStr isEqualToString:@"Estimate"]) {
                strLength1 = 8;
            }
            NSString *hourStr = kLocalizedTableString(@"Hour", @"CPLocalizable");
            if ([hourStr isEqualToString:@"Hour"]) {
                strLength3 = 4;
            }
            
            
            if (hour > 0) {
                time = [NSString stringWithFormat:@"%@%ld%@%ld%@", estimateStr, (long)hour, hourStr, (long)min, kLocalizedTableString(@"Minute", @"CPLocalizable")];
                strLength2 = [NSString stringWithFormat:@"%ld", hour].length;
            }
            else if (hour == 0) {
                time = [NSString stringWithFormat:@"%@%ld%@", estimateStr, (long)min, kLocalizedTableString(@"Minute", @"CPLocalizable")];
                strLength3 = 0;
            }
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:time];
            // hour
            [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.f],
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]} range:NSMakeRange(strLength1, strLength2)];
            // min
            [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.f],
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]} range:NSMakeRange(strLength1+strLength2+strLength3, strLength4)];
            
            self.etaTime = attrStr;
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:2 inSection:0];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:4 inSection:0];
            NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:5 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath1, indexPath2, indexPath3] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

// 新建行程
- (IBAction)leftAction:(id)sender {
    if (_showType == ScheduleVCShowTypeSetup) {
        [self requestSetupSchedule];
    }
    else if (_showType == ScheduleVCShowTypeEdit) {
        [self requestEditSchedule];
        // schedulingCarpoolVo
    }
}

// 去匹配
- (IBAction)rightAction:(id)sender {
    if (![[self checkIfParamsComplete] isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:[self checkIfParamsComplete]];
        return;
    }
    
    if (!_param) {
        NSTimeInterval timestamp = [Utils getTimeStampUTCWithTimeString:self.arriveTimeString format:@"yyyy-MM-dd HH:mm"];
        
        self.weekString = self.weekString == nil ? @"" : self.weekString;
        self.selectedWeekNum = self.selectedWeekNum == nil ? @"" : self.selectedWeekNum;
        
        self.param = @{
                       @"subject":self.theme,
                       @"fromAddressVo":@{
                               @"address":[_locationDict1 valueForKey:@"address"],
                               @"addressName":[_locationDict1 valueForKey:@"addressName"],
                               @"latitude":[_locationDict1 valueForKey:@"latitude"],
                               @"longitude":[_locationDict1 valueForKey:@"longitude"],
                               @"thoroughfare":[_locationDict1 valueForKey:@"thoroughfare"],
                               @"subThoroughfare":[_locationDict1 valueForKey:@"subThoroughfare"],
                               @"locality":[_locationDict1 valueForKey:@"locality"],
                               @"subLocality":[_locationDict1 valueForKey:@"subLocality"],
                               @"administrativeArea":[_locationDict1 valueForKey:@"administrativeArea"],
                               @"subAdministrativeArea":[_locationDict1 valueForKey:@"subAdministrativeArea"],
                               },
                       @"toAddressVo":@{
                               @"address":[_locationDict2 valueForKey:@"address"],
                               @"addressName":[_locationDict2 valueForKey:@"addressName"],
                               @"latitude":[_locationDict2 valueForKey:@"latitude"],
                               @"longitude":[_locationDict2 valueForKey:@"longitude"],
                               @"thoroughfare":[_locationDict2 valueForKey:@"thoroughfare"],
                               @"subThoroughfare":[_locationDict2 valueForKey:@"subThoroughfare"],
                               @"locality":[_locationDict2 valueForKey:@"locality"],
                               @"subLocality":[_locationDict2 valueForKey:@"subLocality"],
                               @"administrativeArea":[_locationDict2 valueForKey:@"administrativeArea"],
                               @"subAdministrativeArea":[_locationDict2 valueForKey:@"subAdministrativeArea"],
                               },
                       @"arriveTime":[NSNumber numberWithUnsignedInteger:timestamp],
                       @"schedulingCycle":self.weekString,
                       @"weekNum":self.selectedWeekNum,
                       }.mutableCopy;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPMatchingScheduleVC *matchingScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMatchingScheduleVC"];
    matchingScheduleVC.requestParams = self.param;
    [self.navigationController pushViewController:matchingScheduleVC animated:YES];
}

- (NSString*)checkIfParamsComplete{
    NSString *tips = @"";
    if (!self.theme) {
        tips = kLocalizedTableString(@"Please enter theme", @"CPLocalizable");
    }
    else if (nil == [_locationDict1 valueForKey:@"address"]) {
        tips = kLocalizedTableString(@"Please enter start", @"CPLocalizable");
    }
    else if (nil == [_locationDict2 valueForKey:@"address"]) {
        tips = kLocalizedTableString(@"Please enter end", @"CPLocalizable");
    }
    else if (!self.arriveTimeString) {
        tips = kLocalizedTableString(@"Please choice arrive time", @"CPLocalizable");
    }
    
    return tips;
}


#pragma mark - 新建行程
- (void)requestSetupSchedule{
    NSLog(@"requestSetupSchedule _locationDict1:%@", _locationDict1);
    
    if (![[self checkIfParamsComplete] isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:[self checkIfParamsComplete]];
        return;
    }
    
    
    if (!_param) {
        NSTimeInterval timestamp = [Utils getTimeStampUTCWithTimeString:self.arriveTimeString format:@"yyyy-MM-dd HH:mm"];
        
        self.weekString = self.weekString == nil ? @"" : self.weekString;
        self.selectedWeekNum = self.selectedWeekNum == nil ? @"" : self.selectedWeekNum;
        
        self.param = @{
                       @"subject":self.theme,
                       @"fromAddressVo":@{
                               @"address":[_locationDict1 valueForKey:@"address"],
                               @"addressName":[_locationDict1 valueForKey:@"addressName"],
                               @"latitude":[_locationDict1 valueForKey:@"latitude"],
                               @"longitude":[_locationDict1 valueForKey:@"longitude"],
                               @"thoroughfare":[_locationDict1 valueForKey:@"thoroughfare"],
                               @"subThoroughfare":[_locationDict1 valueForKey:@"subThoroughfare"],
                               @"locality":[_locationDict1 valueForKey:@"locality"],
                               @"subLocality":[_locationDict1 valueForKey:@"subLocality"],
                               @"administrativeArea":[_locationDict1 valueForKey:@"administrativeArea"],
                               @"subAdministrativeArea":[_locationDict1 valueForKey:@"subAdministrativeArea"],
                               },
                       @"toAddressVo":@{
                               @"address":[_locationDict2 valueForKey:@"address"],
                               @"addressName":[_locationDict2 valueForKey:@"addressName"],
                               @"latitude":[_locationDict2 valueForKey:@"latitude"],
                               @"longitude":[_locationDict2 valueForKey:@"longitude"],
                               @"thoroughfare":[_locationDict2 valueForKey:@"thoroughfare"],
                               @"subThoroughfare":[_locationDict2 valueForKey:@"subThoroughfare"],
                               @"locality":[_locationDict2 valueForKey:@"locality"],
                               @"subLocality":[_locationDict2 valueForKey:@"subLocality"],
                               @"administrativeArea":[_locationDict2 valueForKey:@"administrativeArea"],
                               @"subAdministrativeArea":[_locationDict2 valueForKey:@"subAdministrativeArea"],
                               },
                       @"arriveTime":[NSNumber numberWithUnsignedInteger:timestamp],
                       @"schedulingCycle":self.weekString,
                       @"weekNum":self.selectedWeekNum,
                       }.mutableCopy;
    }
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@%@", BaseURL, self.url] parameters:self.param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPSetupScheduleVC requestSetupSchedule responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ScheduleUpdateSuccess" object:nil];
                
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPSetupScheduleVC requestSetupSchedule 失败");
            }
        }
        else {
            NSLog(@"CPSetupScheduleVC requestSetupSchedule 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPSetupScheduleVC requestSetupSchedule error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


#pragma mark - 编辑行程
- (void)requestEditSchedule{
    NSLog(@"requestEditSchedule _locationDict1:%@, _locationDict2:%@", _locationDict1, _locationDict2);
    
    if (![[self checkIfParamsComplete] isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:[self checkIfParamsComplete]];
        return;
    }
    
    
    if (!_param) {
        NSTimeInterval timestamp = [Utils getTimeStampUTCWithTimeString:self.arriveTimeString format:@"yyyy-MM-dd HH:mm"];
        
        self.weekString = self.weekString == nil ? @"" : self.weekString;
        self.selectedWeekNum = self.selectedWeekNum == nil ? @"" : self.selectedWeekNum;
        
        self.param = @{
                       @"id":[NSNumber numberWithInteger:self.dataid],
                       @"subject":self.theme,
                       @"fromAddressVo":@{
                               @"address":[_locationDict1 valueForKey:@"address"],
                               @"addressName":[_locationDict1 valueForKey:@"addressName"],
                               @"latitude":[_locationDict1 valueForKey:@"latitude"],
                               @"longitude":[_locationDict1 valueForKey:@"longitude"],
                               @"thoroughfare":[_locationDict1 valueForKey:@"thoroughfare"],
                               @"subThoroughfare":[_locationDict1 valueForKey:@"subThoroughfare"],
                               @"locality":[_locationDict1 valueForKey:@"locality"],
                               @"subLocality":[_locationDict1 valueForKey:@"subLocality"],
                               @"administrativeArea":[_locationDict1 valueForKey:@"administrativeArea"],
                               @"subAdministrativeArea":[_locationDict1 valueForKey:@"subAdministrativeArea"],
                               },
                       @"toAddressVo":@{
                               @"address":[_locationDict2 valueForKey:@"address"],
                               @"addressName":[_locationDict2 valueForKey:@"addressName"],
                               @"latitude":[_locationDict2 valueForKey:@"latitude"],
                               @"longitude":[_locationDict2 valueForKey:@"longitude"],
                               @"thoroughfare":[_locationDict2 valueForKey:@"thoroughfare"],
                               @"subThoroughfare":[_locationDict2 valueForKey:@"subThoroughfare"],
                               @"locality":[_locationDict2 valueForKey:@"locality"],
                               @"subLocality":[_locationDict2 valueForKey:@"subLocality"],
                               @"administrativeArea":[_locationDict2 valueForKey:@"administrativeArea"],
                               @"subAdministrativeArea":[_locationDict2 valueForKey:@"subAdministrativeArea"],
                               },
                       @"arriveTime":[NSNumber numberWithUnsignedInteger:timestamp],
                       @"schedulingCycle":self.weekString,
                       @"weekNum":self.selectedWeekNum,
                       }.mutableCopy;
    }
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@%@", BaseURL, self.url] parameters:self.param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPSetupScheduleVC requestEditSchedule responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ScheduleUpdateSuccess" object:nil];
                
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPSetupScheduleVC requestEditSchedule 失败");
            }
        }
        else {
            NSLog(@"CPSetupScheduleVC requestEditSchedule 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPSetupScheduleVC requestEditSchedule error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
