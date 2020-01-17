//
//  CPInitShortTermContractVC.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPInitShortTermContractVC.h"
#import "CPInitShortTermContractCell1.h"
#import "CPInitShortTermContractCell2.h"
#import "CPInitShortTermContractCell3.h"
#import "CPInitShortTermContractCell4.h"
#import "CPUserInfoCell2.h"
#import "BWSheetBottmView.h"
#import "SSChatLocationController.h"
#import "CPSelectContractThemeVC.h"
#import "CPMyAddressPageVC.h"
#import "CPScheduleMJModel.h"
#import "CPAddressModel.h"

@interface CPInitShortTermContractVC ()<BWSheetBottmViewDelegate, CPInitShortTermContractCell1Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *contractConfirmBtn;

@property (nonatomic, assign) NSInteger passengerType;
@property (nonatomic, assign) NSIndexPath *addressSelectIndexPath; // 选择地址时的indexpath
// 位置 dict
@property(nonatomic, strong) NSDictionary *locationDict1;
@property(nonatomic, strong) NSDictionary *locationDict2;
@property(nonatomic, strong) NSString *theme;
@property(nonatomic, strong) NSMutableAttributedString *etaTime; // 预计驾车时间
@property (nonatomic, assign) BOOL isCalendarSelected;
@property(nonatomic, strong) NSString *calendarSelectedDateString;
@property(nonatomic, strong) NSString *selectedTimeString;
@property(nonatomic, strong) NSString *startTimeString;
@property(nonatomic, strong) NSString *endTimeString;
@property(nonatomic, strong) NSString *remark;

@end


@implementation CPInitShortTermContractVC

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
    
    
    self.title = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
    if (kBOTTOMSAFEHEIGHT == 0) {
        _bottomConstraint.constant = 0;
    }
    else {
        _bottomConstraint.constant = kBOTTOMSAFEHEIGHT;
    }
    
    [_contractConfirmBtn setTitle:kLocalizedTableString(@"Initiation Contract", @"CPLocalizable") forState:UIControlStateNormal];
    _contractConfirmBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _contractConfirmBtn.layer.cornerRadius = _contractConfirmBtn.frame.size.height/2;
    _contractConfirmBtn.layer.masksToBounds = YES;
    
    _passengerType = 0;
    self.etaTime = [[NSMutableAttributedString alloc] initWithString:@""];
    
    //注册并登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectContractAddress:) name:@"SELECTCONTRACTADDRESSSUCCESS" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SELECTCONTRACTADDRESSSUCCESS" object:nil];
}

- (void)selectContractAddress:(NSNotification*)notification{
    NSDictionary *dict = notification.userInfo;
    if (_addressSelectIndexPath.section == 2) {
        _locationDict1 = dict;
        if (nil != self.locationDict2) {
            CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
            CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
            
            [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
        }
    }
    else if (_addressSelectIndexPath.section == 3) {
        _locationDict2 = dict;
        if (nil != self.locationDict1) {
            CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
            CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
            
            [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:_addressSelectIndexPath.section];
    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 2;
    }
    else if (section == 3) {
        return 2;
    }
    else if (section == 4) {
        return 1;
    }
    else if (section == 5) {
        return 3;
    }
    
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CPREGULARCELLHEIGHT;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            return CPREGULARCELLHEIGHT;
        }
        return 90;
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return CPREGULARCELLHEIGHT;
        }
        return 90;
    }
    else if (indexPath.section == 5) {
        if (indexPath.row == 2) {
            return 100;
        }
        return 44;
    }
    return CPREGULARCELLHEIGHT;
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
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell1"];
        ((CPInitShortTermContractCell1*)cell).delegate = self;
        
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell2"];
        ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Theme", @"CPLocalizable");
        if (self.scheduleMJModel) {
            ((CPUserInfoCell2*)cell).subTitleLbl.text = self.scheduleMJModel.subject;
        }
        else {
            ((CPUserInfoCell2*)cell).subTitleLbl.text = _theme == nil ? @"" : _theme;
        }

    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell3"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Stroke Start", @"CPLocalizable");
            ((CPUserInfoCell2*)cell).subTitleLbl.text = @"";

        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell4"];
            NSLog(@"CPInitShortTermContractVC cellForRowAtIndexPath address:%@", [_locationDict1 valueForKey:@"address"]);
            if (self.scheduleMJModel) {
                ((CPInitShortTermContractCell2*)cell).titleLbl.text = self.scheduleMJModel.fromAddressVo.address;
            }
            else {
                ((CPInitShortTermContractCell2*)cell).titleLbl.text = [_locationDict1 valueForKey:@"address"];
            }
            
        }
        
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell5"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Stroke End", @"CPLocalizable");
            ((CPUserInfoCell2*)cell).subTitleLbl.text = @"";

        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell6"];
            if (self.scheduleMJModel) {
                ((CPInitShortTermContractCell2*)cell).titleLbl.text = self.scheduleMJModel.toAddressVo.address;
            }
            else {
                ((CPInitShortTermContractCell2*)cell).titleLbl.text = [_locationDict2 valueForKey:@"address"];
            }
        }
        
    }
    else if (indexPath.section == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell7"];
        ((CPInitShortTermContractCell3*)cell).subTitleLbl.attributedText = self.etaTime;
        
    }
    else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell8"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Start Time", @"CPLocalizable");
            NSDate *date = [Utils stringToDate:_startTimeString withDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *dateStr = [Utils dateToString:date withDateFormat:@"YYYY/MM/dd EEE HH:mm"];
            ((CPUserInfoCell2*)cell).subTitleLbl.text = dateStr;
        }
        else if (indexPath.row == 1) {
        
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell9"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"End Time", @"CPLocalizable");
            
            NSDate *date = [Utils stringToDate:_endTimeString withDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *dateStr = [Utils dateToString:date withDateFormat:@"YYYY/MM/dd EEE HH:mm"];
            ((CPUserInfoCell2*)cell).subTitleLbl.text = dateStr;
            
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell10"];
            ((CPInitShortTermContractCell4*)cell).titleLbl.text = kLocalizedTableString(@"Remark", @"CPLocalizable");
            ((CPInitShortTermContractCell4*)cell).subTitleLbl.text = _remark;
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // 
        
    }
    else if (indexPath.section == 1) {
        if (!self.scheduleMJModel) {
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
        
    }
    else if (indexPath.section == 2) {
        if (!self.scheduleMJModel) {
            if (indexPath.row == 0) {
                // 通过我的地址列表选择
                self.addressSelectIndexPath = indexPath;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPMyAddressPageVC *myAddressPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyAddressPageVC"];
                [self.navigationController pushViewController:myAddressPageVC animated:YES];
            }
            else if (indexPath.row == 1) {
                // 通过地图选择地址
                SSChatLocationController *chatLocationController = [[SSChatLocationController alloc] init];
                chatLocationController.locationBlock = ^(NSDictionary *locationDict, WFCULocationPoint *point) {
                    self.locationDict1 = locationDict;
                    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                    if (nil != self.locationDict2) {
                        CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
                        CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
                        
                        [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
                    }
                };
                [self.navigationController pushViewController:chatLocationController animated:YES];
            }
        }
        
        
    }
    else if (indexPath.section == 3) {
        if (!self.scheduleMJModel) {
            if (indexPath.row == 0) {
                // 通过我的地址列表选择
                self.addressSelectIndexPath = indexPath;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                CPMyAddressPageVC *myAddressPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyAddressPageVC"];
                [self.navigationController pushViewController:myAddressPageVC animated:YES];
                
            }
            else if (indexPath.row == 1) {
                // 通过地图选择地址
                SSChatLocationController *chatLocationController = [[SSChatLocationController alloc] init];
                chatLocationController.locationBlock = ^(NSDictionary *locationDict, WFCULocationPoint *point) {
                    self.locationDict2 = locationDict;
                    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                    if (nil != self.locationDict1) {
                        CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([[self.locationDict1 valueForKey:@"latitude"] doubleValue], [[self.locationDict1 valueForKey:@"longitude"] doubleValue]);
                        CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([[self.locationDict2 valueForKey:@"latitude"] doubleValue], [[self.locationDict2 valueForKey:@"longitude"] doubleValue]);
                        
                        [self getTransitETAWithBeginCoord:coord1 andEndCoord:coord2];
                    }
                };
                [self.navigationController pushViewController:chatLocationController animated:YES];
            }
        }
        
    }
    else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            _isCalendarSelected = NO;
            BWSheetBottmView *bottomView = [[BWSheetBottmView alloc] initWithTitle:@"" delegate:self];
            bottomView.actionSheetPickerStyle = BWActionSheetPickerStyleCalendarDateAndTimePicker;
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
        else if (indexPath.row == 1) {
//            if (!self.scheduleMJModel) {
                _isCalendarSelected = NO;
                BWSheetBottmView *bottomView = [[BWSheetBottmView alloc] initWithTitle:@"" delegate:self];
                bottomView.actionSheetPickerStyle = BWActionSheetPickerStyleCalendarDateAndTimePicker;
                
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
                [bottomView setTag:10002];
                [bottomView show];
//            }
            
        }
        else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPSelectContractThemeVC *selectContractThemeVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSelectContractThemeVC"];
            selectContractThemeVC.titleType = 1;
            if (self.remark) {
                selectContractThemeVC.aString = self.remark;
            }
            selectContractThemeVC.passValueblock = ^(NSString * _Nonnull aSting) {
                //
                self.remark = aSting;
                NSLog(@"selectContractThemeVC 1 result:%@", aSting);
                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:selectContractThemeVC animated:YES];
        }
    }
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
            NSInteger strLength4 = [NSString stringWithFormat:@"%ld", (long)min].length;
            
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
                strLength2 = [NSString stringWithFormat:@"%ld", (long)hour].length;
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
            [self.tableView reloadSection:4 withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}


#pragma mark - CPInitShortTermContractCell1Delegate
- (void)contractCellSelectPassengerType:(NSInteger)type{
    _passengerType = type;
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
    
    NSIndexPath *indexPath;
    if (pickerView.tag == 10001) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:5];
        _startTimeString = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, _selectedTimeString];
    
//        if (self.scheduleMJModel) {// from matching
//            NSInteger elapseSec = self.scheduleMJModel.arriveTime;
//            NSInteger hour = elapseSec / 3600;
//            NSInteger min = (elapseSec / 60) % 60;
//            NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)hour, (long)min];
//            NSString *dateStr = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, timeStr];
//
//            NSDate *date1 = [Utils stringToDate:dateStr withDateFormat:@"yyyy-MM-dd HH:mm"];
//            NSDate *date2 = [Utils stringToDate:_endTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
//
//            NSComparisonResult result = [date1 compare:date2];
//            if (result == NSOrderedAscending || result == NSOrderedSame) {
//                NSLog(@"CPInitShortTermContractVC time right");
//            }
//            else {
//                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Time error tip", @"CPLocalizable")];
//            }
            
            
//            NSDate *date = [Utils getDateWithTimestamp:self.scheduleMJModel.arriveTime];
//            NSString *dateStr = [Utils dateToString:date withDateFormat:@"YYYY/MM/dd EEE HH:mm"];
//
//            NSDate *startDate = [Utils stringToDate:_startTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
//            NSDate *endDate = [Utils stringToDate:dateStr withDateFormat:@"YYYY/MM/dd EEE HH:mm"];
//
//            NSComparisonResult result = [startDate compare:endDate];
//            if (result == NSOrderedAscending || result == NSOrderedSame) {
//                NSLog(@"CPInitShortTermContractVC time right");
//            }
//            else {
//                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Time error tip", @"CPLocalizable")];
//            }
            
//        }
//        else if (_endTimeString) {
//            NSDate *startDate = [Utils stringToDate:_startTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
//            NSDate *endDate = [Utils stringToDate:_endTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
//
//            NSComparisonResult result = [startDate compare:endDate];
//            if (result == NSOrderedAscending || result == NSOrderedSame) {
//                NSLog(@"CPInitShortTermContractVC time right");
//            }
//            else {
//                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Time error tip", @"CPLocalizable")];
//            }
//        }
        
        if (_endTimeString) {
            NSDate *startDate = [Utils stringToDate:_startTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *endDate = [Utils stringToDate:_endTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
            
            NSComparisonResult result = [startDate compare:endDate];
            if (result == NSOrderedAscending || result == NSOrderedSame) {
                NSLog(@"CPInitShortTermContractVC time right");
            }
            else {
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Time error tip", @"CPLocalizable")];
            }
        }
        
    }
    else if (pickerView.tag == 10002) {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:5];
        _endTimeString = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, _selectedTimeString];
        if (self.scheduleMJModel) {
            NSInteger elapseSec = self.scheduleMJModel.arriveTime;
            NSInteger hour = elapseSec / 3600;
            NSInteger min = (elapseSec / 60) % 60;
            NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)hour, (long)min];
            NSString *dateStr = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, timeStr];
            
            NSDate *date1 = [Utils stringToDate:dateStr withDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *date2 = [Utils stringToDate:_endTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
            
            NSComparisonResult result = [date2 compare:date1];
            if (result == NSOrderedAscending || result == NSOrderedSame) {
                NSLog(@"CPInitShortTermContractVC time right");
                
            }
            else {
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"arrive Time error tip", @"CPLocalizable")];
            }
        }
        
        
        if (_startTimeString) {
            NSDate *startDate = [Utils stringToDate:_startTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *endDate = [Utils stringToDate:_endTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
            
            NSComparisonResult result = [startDate compare:endDate];
            if (result == NSOrderedAscending || result == NSOrderedSame) {
                NSLog(@"CPInitShortTermContractVC time right");
                
            }
            else {
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Time error tip", @"CPLocalizable")];
            }
        }
    }
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


- (void)setScheduleMJModel:(CPScheduleMJModel *)scheduleMJModel{
    if (nil != scheduleMJModel) {
        _scheduleMJModel = scheduleMJModel;
        
        NSDate *date = [Utils getDateWithTimestamp:scheduleMJModel.arriveTime];
        _endTimeString = [Utils dateToString:date withDateFormat:@"YYYY-MM-dd HH:mm"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:5];
        [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (IBAction)contractConfirmAction:(id)sender {
    NSLog(@"CPInitShortTermContractVC contractConfirmAction _startTimeString:%@, _endTimeString:%@", _startTimeString, _endTimeString);
    
    [self requestSetupContract];
}

- (void)requestSetupContract{
    // 合约类型 contractType  0:短期 1:长期
    // 用户类型 userType 0:乘客  1：司机
    NSMutableDictionary *param = @{}.mutableCopy;
    
    // cron express
    NSDate *date = [Utils stringToDate:_startTimeString withDateFormat:@"YYYY-MM-dd HH:mm"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                              fromDate:date];
    NSInteger cronMonth = [dateComps month];
    NSInteger cronDay = [dateComps day];
    NSInteger cronHour = [dateComps hour];
    NSInteger cronMinute = [dateComps minute];
    
    NSString *cronExp = [NSString stringWithFormat:@"0 %ld %ld %ld %ld ? *", (long)cronMinute, (long)cronHour, (long)cronDay, (long)cronMonth];
    NSLog(@"CPInitShortTermContractVC init contract cronExp:%@", cronExp);
    
    if (!self.scheduleMJModel) {// 非 匹配行程发起的
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
        else if (!self.startTimeString) {
            tips = kLocalizedTableString(@"Please enter starttime", @"CPLocalizable");
        }
        else if (!self.endTimeString) {
            tips = kLocalizedTableString(@"Please enter endtime", @"CPLocalizable");
        }
        
        if (![tips isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:tips];
            return;
        }
        
        NSString *remark = @"";
        if (self.remark) {
            remark = self.remark;
        }
        
        
        param = @{
                  @"schedulingId":[NSNumber numberWithInteger:-1],
                  @"contractType":@0,
                  @"userType":[NSNumber numberWithInteger:self.passengerType],
                  @"subject":self.theme,
                  @"cronExp":cronExp,
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
                  @"beginTime":self.startTimeString,
                  @"contractCycle":@"",
                  @"endTime":self.endTimeString,
                  @"remark":remark,
                  @"targetIMUserId":self.targetIMUserId,
                   }.mutableCopy;
        
    }
    else {// 匹配行程发起的
        NSString *tips = @"";
        if (!self.startTimeString) {
            tips = kLocalizedTableString(@"Please enter starttime", @"CPLocalizable");
        }
        
        if (![tips isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:tips];
            return;
        }
        
        NSString *remark = @"";
        if (self.remark) {
            remark = self.remark;
        }
        
        NSInteger elapseSec = self.scheduleMJModel.arriveTime;
        NSInteger hour = elapseSec / 3600;
        NSInteger min = (elapseSec / 60) % 60;
        NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)hour, (long)min];
        NSString *dateStr = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, timeStr];
        
//        NSDate *date1 = [Utils stringToDate:dateStr withDateFormat:@"yyyy-MM-dd HH:mm"];
//        NSDate *date2 = [Utils stringToDate:_endTimeString withDateFormat:@"yyyy-MM-dd HH:mm"];
//
//        NSComparisonResult result = [date2 compare:date1];
//        if (result == NSOrderedAscending || result == NSOrderedSame) {
//            NSLog(@"CPInitShortTermContractVC time right");
//
//        }
//        else {
//            [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"arrive Time error tip", @"CPLocalizable")];
//        }
//
//
//        NSDate *date = [Utils getDateWithTimestamp:self.scheduleMJModel.arriveTime];
//        NSString *endTime = [Utils dateToString:date withDateFormat:@"yyyy-MM-dd HH:mm"];
        
        param = @{
                  @"schedulingId":[NSNumber numberWithInteger:_scheduleMJModel.dataid],
                  @"contractType":@0,
                  @"userType":[NSNumber numberWithInteger:self.passengerType],
                  @"subject":_scheduleMJModel.subject,
                  @"cronExp":cronExp,
                  @"fromAddressVo":[_scheduleMJModel.fromAddressVo mj_keyValues],
                  @"toAddressVo":[_scheduleMJModel.toAddressVo mj_keyValues],
                  @"beginTime":self.startTimeString,
                  @"contractCycle":@"",
                  @"endTime":_endTimeString,
                  @"remark":remark,
                  @"targetIMUserId":self.targetIMUserId,
                  }.mutableCopy;
    }
    
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/launchContract.json", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPInitShortTermContractVC init contract responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LaunchContractSuccess" object:nil];
                
                if (weakSelf.passValueblock) {
                    // contract id
                    [param setValue:[[responseObject valueForKey:@"data"] valueForKey:@"contractId"] forKey:@"contractId"];
                    weakSelf.passValueblock(param);
                }
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else if ([[responseObject valueForKey:@"code"] integerValue] == 405) {
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Schedule Matching Error", @"CPLocalizable")];
                NSLog(@"CPInitShortTermContractVC init contract requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPInitShortTermContractVC init contract requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPInitShortTermContractVC init contract requestRegister error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
