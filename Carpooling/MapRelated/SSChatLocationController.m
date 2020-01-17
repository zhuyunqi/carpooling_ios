//
//  SSChatLocationController.m
//  SSChatView
//
//  Created by soldoros on 2018/10/15.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatLocationController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BWSearchBar.h"
#import "CPAddressModel.h"
#import "MKMapView+BWZoomLevel.h"

#import "WFCULocationPoint.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>


#define kMapZOOM_LEVEL 9
#define kMapSearchMeters 5000   // meters


@interface SSChatLocationController ()<CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UILabel *noDataLbl;

//地图
@property (nonatomic, strong) MKMapView *mMapView;

//定位
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKLocalSearchRequest *localSearchRequest;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, strong) NSMutableArray *placesArray;

@property (nonatomic, assign) BOOL refreshLocation;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BWSearchBar *searchBar;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, strong) NSMutableArray *annotationArray;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

//返回数据
@property (nonatomic, strong) WFCULocationPoint *locationPoint;
@property (nonatomic, strong) NSDictionary *locationDict;
@property (nonatomic, strong) NSError *error;
@end


@implementation SSChatLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    
    if(self.showType == SSChatLocationVCShowTypeMe){
        self.navigationItem.title = kLocalizedTableString(@"Create Address", @"CPLocalizable");
    }
    else {
        self.navigationItem.title = kLocalizedTableString(@"Location", @"CPLocalizable");
    }
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.bounds = CGRectMake(0, 0, 50, 35);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    //初始化地图
    _mMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0 , kSCREENWIDTH, kSCREENHEIGHT/2+10)];
    _mMapView.delegate = self;
    _mMapView.mapType = MKMapTypeStandard;
    _mMapView.showsUserLocation = YES;
    _mMapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.view addSubview:_mMapView];
    
    //设置地图范围
    CLLocationCoordinate2D center = self.mMapView.region.center;
    [self.mMapView setCenterCoordinate:center zoomLevel:kMapZOOM_LEVEL animated:NO];
    
    //
    [self checkIfAuthLocation];

    
    
    _searchBar = [[BWSearchBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mMapView.frame)-60, kSCREENWIDTH, 44)];
    self.searchBar.layer.cornerRadius = 10;
    self.searchBar.layer.masksToBounds = YES;
    self.searchBar.placeholder = kLocalizedTableString(@"Search", @"CPLocalizable");// 搜索框的占位符
//    self.searchBar.searchBarStyle = UISearchBarStyleMinimal; // 搜索框样式
    //    self.searchBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    self.searchBar.backgroundImage = [UIImage new];
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor blackColor];
            }
            else {
                return [UIColor labelColor];
            }
        }];
        self.searchBar.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        [self.searchBar setValue:kLocalizedTableString(@"Cancel", @"CPLocalizable") forKey:@"_cancelButtonText"];
        
        self.searchBar.tintColor = [UIColor blackColor];
    }
    [self.searchBar setTranslucent:YES];// 设置是否透明
    self.searchBar.showsCancelButton = NO;
    
//    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(30, 0)];// 设置搜索框中文本框的文本偏移量
    self.searchBar.delegate = self;// 设置代理
    [self.searchBar sizeToFit];
    [self.view addSubview:self.searchBar];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), kSCREENWIDTH, kSCREENHEIGHT-10-CGRectGetMaxY(self.searchBar.frame)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.searchBar];
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.tableView.frame)/2-40, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    noDataLbl.text = kLocalizedTableString(@"Location Fail Or NO Result", @"CPLocalizable");
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    
    
    //定位按钮
    self.locationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.locationBtn.frame = CGRectMake(kSCREENWIDTH - 40, CGRectGetMinY(self.searchBar.frame)-35, 30, 30);
    [self.locationBtn setImage:[UIImage imageNamed:@"map_location_backToLocal"] forState:UIControlStateNormal];
    [self.locationBtn setTintColor:[UIColor darkGrayColor]];
    [self.locationBtn addTarget:self action:@selector(locationBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationBtn];
    
    
    self.searchKeyword = @"";
    self.placesArray = @[].mutableCopy;
    self.annotationArray = @[].mutableCopy;
    
    
    // 用户从个人中心选择的语言
//    _currentLanguage = [BWLocalizableHelper shareInstance].currentLanguage;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //
    [self unArchiveModel];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

//键盘通知的方法
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    //键盘高度
    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect searchBarRect = self.searchBar.frame;
    
    if (kSCREENHEIGHT-keyBoardFrame.size.height-64 < searchBarRect.origin.y) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.searchBar.frame = CGRectMake(0, kSCREENHEIGHT-keyBoardFrame.size.height-64, searchBarRect.size.width, searchBarRect.size.height);
            weakSelf.locationBtn.frame = CGRectMake(weakSelf.locationBtn.frame.origin.x, CGRectGetMinY(self.searchBar.frame)-35, weakSelf.locationBtn.frame.size.width, weakSelf.locationBtn.frame.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //键盘高度
//    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.searchBar.frame = CGRectMake(0, CGRectGetMaxY(self.mMapView.frame)-60, weakSelf.searchBar.size.width, weakSelf.searchBar.size.height);
        weakSelf.locationBtn.frame = CGRectMake(weakSelf.locationBtn.frame.origin.x, CGRectGetMinY(self.searchBar.frame)-35, weakSelf.locationBtn.frame.size.width, weakSelf.locationBtn.frame.size.height);
    }];
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
    
    NSLog(@"checkIfAuthLocation [CLLocationManager authorizationStatus]:%d", [CLLocationManager authorizationStatus]);
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10.0;
    
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"locationManager didChangeAuthorizationStatus status:%d", status);
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = 10.0;
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

    [_locationManager stopUpdatingLocation];
    self.coord = currLocation.coordinate;
    NSLog(@"currLocation.coordinate.latitude:%f, currLocation.coordinate.longitude:%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude);

    //
    [self getPlacemarkBylocation:currLocation];
}


//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//    self.coord = userLocation.coordinate;
//    NSLog(@"userLocation.coordinate.latitude:%f, userLocation.coordinate.longitude:%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
//
//    //
//    [self getPlacemarkBylocation:userLocation.location];
//}


- (void)getPlacemarkBylocation:(CLLocation *)currLocation{
#warning apple mapkit
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray* _Nullable placemarks, NSError * _Nullable error) {

        if(error){
            self.noDataLbl.hidden = NO;

        } else if(placemarks && placemarks.count > 0){
            self.noDataLbl.hidden = YES;
//            CLPlacemark *placemark0 = [placemarks firstObject];
//            NSLog(@"详细信息:%@", placemark0.addressDictionary);
            if (self.refreshLocation) {
                [self.placesArray removeAllObjects];
                self.refreshLocation = NO;
            }
            
            
            NSLog(@"getPlacemarkBylocation placemarks:%@", placemarks);

            //获取用户当前位置信息
            MKPlacemark *placemark = [placemarks lastObject];
            CPAddressModel *model = [[CPAddressModel alloc] init];
            model.addressName = placemark.name == nil ? @"" : placemark.name;
            model.thoroughfare = placemark.thoroughfare == nil ? @"" : placemark.thoroughfare;
            model.subThoroughfare = placemark.subThoroughfare == nil ? @"" : placemark.subThoroughfare;
            model.locality = placemark.locality == nil ? @"" : placemark.locality;
            model.subLocality = placemark.subLocality == nil ? @"" : placemark.subLocality;
            model.administrativeArea = placemark.administrativeArea == nil ? @"" : placemark.administrativeArea;
            model.subAdministrativeArea = placemark.subAdministrativeArea == nil ? @"" : placemark.subAdministrativeArea;
            model.latitude = placemark.location.coordinate.latitude;
            model.longitude = placemark.location.coordinate.longitude;
            
            NSLog(@"placemark.addressDictionary[FormattedAddressLines]:%@", [placemark.addressDictionary valueForKey:@"FormattedAddressLines"]);
            
            NSArray *array = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
            if (array.count > 0) {
                NSString *address2 = [array firstObject];
                model.address = address2;
            }
            else {
                model.address = @"";
            }

//            NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:7 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
//
//            NSDecimalNumber *numLat = [[NSDecimalNumber alloc] initWithDouble:model.latitude];
//            NSLog(@"SSChatLocationController numLat %@", [numLat decimalNumberByRoundingAccordingToBehavior:behavior]);
//            NSDecimalNumber *numLng = [[NSDecimalNumber alloc] initWithDouble:model.longitude];
//            NSLog(@"SSChatLocationController numLng %@", [numLng decimalNumberByRoundingAccordingToBehavior:behavior]);

            self.error = error;
            self.locationDict = @{@"latitude":@(currLocation.coordinate.latitude),
                                  @"longitude":@(currLocation.coordinate.longitude),
                                  @"administrativeArea":model.administrativeArea,
                                  @"subAdministrativeArea":model.subAdministrativeArea,
                                  @"locality":model.locality,
                                  @"subLocality":model.subLocality,
                                  @"thoroughfare":model.thoroughfare,
                                  @"subThoroughfare":model.subThoroughfare,
                                  @"address": model.address,
                                  @"addressName": model.addressName
                                  };
            [self.mMapView setCenterCoordinate:currLocation.coordinate animated:YES];
            
            [self.placesArray insertObject:model atIndex:0];

            [self.tableView reloadData];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
    
    
#warning google map
    //google map 反向地理编码
//    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:currLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
//        if (error) {
//            self.noDataLbl.hidden = NO;
//        }
//        else {
//            if (response.results) {
//                GMSAddress *address = response.results[0];
//                NSLog(@"%@",address.thoroughfare);
//                //获取用户当前位置信息
//                CPAddressModel *model = [[CPAddressModel alloc] init];
//                model.addressName = @"";
//                model.thoroughfare = address.thoroughfare == nil ? @"" : address.thoroughfare;
//                model.subThoroughfare = @"";
//                model.locality = address.locality == nil ? @"" : address.locality;
//                model.subLocality = address.subLocality == nil ? @"" : address.subLocality;
//                model.administrativeArea = address.administrativeArea == nil ? @"" : address.administrativeArea;
//                model.subAdministrativeArea = @"";
//                model.latitude = address.coordinate.latitude;
//                model.longitude = address.coordinate.longitude;
//
//
//                NSString *addressStr = [CPAddressModel handleAddressFormatWithModel:model];
//                NSLog(@"SSChatLocationController addressStr:%@", addressStr);
//
//                //            NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:7 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
//                //
//                //            NSDecimalNumber *numLat = [[NSDecimalNumber alloc] initWithDouble:model.latitude];
//                //            NSLog(@"SSChatLocationController numLat %@", [numLat decimalNumberByRoundingAccordingToBehavior:behavior]);
//                //            NSDecimalNumber *numLng = [[NSDecimalNumber alloc] initWithDouble:model.longitude];
//                //            NSLog(@"SSChatLocationController numLng %@", [numLng decimalNumberByRoundingAccordingToBehavior:behavior]);
//
//                self.error = error;
//                self.locationDict = @{@"latitude":@(currLocation.coordinate.latitude),
//                                      @"longitude":@(currLocation.coordinate.longitude),
//                                      @"administrativeArea":model.administrativeArea,
//                                      @"subAdministrativeArea":model.subAdministrativeArea,
//                                      @"locality":model.locality,
//                                      @"subLocality":model.subLocality,
//                                      @"thoroughfare":model.thoroughfare,
//                                      @"subThoroughfare":model.subThoroughfare,
//                                      @"address": address,
//                                      @"addressName": model.addressName
//                                      };
//                [self.mMapView setCenterCoordinate:currLocation.coordinate animated:YES];
//
//                [self.placesArray addObject:model];
//
//                [self.tableView reloadData];
//
//                self.navigationItem.rightBarButtonItem.enabled = YES;
//            }
//        }
//
//    }];
}

-(void)getPlaceWithCoordinate:(CLLocationCoordinate2D)coordinate searchText:(NSString*)keyword
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kMapSearchMeters, kMapSearchMeters);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = region;
    request.naturalLanguageQuery = keyword;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            self.noDataLbl.hidden = YES;
            [self.placesArray removeAllObjects];
            [self.mMapView removeAnnotations:self.annotationArray];
            [self.annotationArray removeAllObjects];
            
            for (MKMapItem *mapItem in response.mapItems) {
                MKPlacemark * placemark = mapItem.placemark;
                CPAddressModel *model = [[CPAddressModel alloc] init];
                model.addressName = placemark.name;
                model.thoroughfare = placemark.thoroughfare;
                model.subThoroughfare = placemark.subThoroughfare;
                
                model.locality = placemark.locality;
                model.subLocality = placemark.subLocality;
                model.administrativeArea = placemark.administrativeArea;
                model.subAdministrativeArea = placemark.subAdministrativeArea;
                model.latitude = placemark.location.coordinate.latitude;
                model.longitude = placemark.location.coordinate.longitude;
                
                NSLog(@"getPlaceWithCoordinate placemark.location.coordinate.latitude:%f, placemark.location.coordinate.longitude:%f", placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
                
                NSLog(@"placemark.addressDictionary[FormattedAddressLines]:%@", [placemark.addressDictionary valueForKey:@"FormattedAddressLines"]);
                
                NSArray *array = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
                if (array.count > 0) {
                    NSString *address2 = [array firstObject];
                    model.address = address2;
                }
                else {
                    model.address = @"";
                }
                
                [self.placesArray addObject:model];
                
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = mapItem.name;
                annotation.coordinate = mapItem.placemark.coordinate;
                [self.annotationArray addObject:annotation];
                [self.mMapView addAnnotation:annotation];
            }
            
            [self.tableView reloadData];
            
            
        }else{
            NSLog(@"getPlaceWithCoordinate around Error:%@",error.localizedDescription);
            self.noDataLbl.hidden = NO;
            return;
        }
    }];
}




- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"locationManager didFailWithError:%@", [error localizedDescription]);
    [SVProgressHUD showErrorWithStatus:@"定位失败"];
}

- (void)locationBtnAction:(UIButton*)btn{
    if (_locationManager) {
        _refreshLocation = YES;
        [_locationManager startUpdatingLocation];
    }
}



#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    _searchKeyword = searchBar.text;
    if (![_searchKeyword isEqualToString:@""]) {
        [self getPlaceWithCoordinate:self.coord searchText:self.searchKeyword];
    }
}



//确定
-(void)rightBtnClick{
    if(self.showType == SSChatLocationVCShowTypeMe){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
    }
    else {
        if (!self.selectedIndexPath) {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }
    
    [self selectPlaceByIndexPath:self.selectedIndexPath];
}


#pragma mark - UITableView UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placesArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor whiteColor];
                }
                else {
                    return [UIColor secondarySystemBackgroundColor];
                }
            }];
            
            cell.backgroundColor = dyColor;
            
        } else {
            // Fallback on earlier versions
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    
    CPAddressModel *model = [self.placesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.addressName;
    cell.detailTextLabel.text = model.thoroughfare;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndexPath = indexPath;
    
    [self selectPlaceByIndexPath:self.selectedIndexPath];
}

- (void)selectPlaceByIndexPath:(NSIndexPath*)indexPath{
    CPAddressModel *model = [self.placesArray objectAtIndex:indexPath.row];
    model.addressName = model.addressName == nil ? @"" : model.addressName;
    model.thoroughfare = model.thoroughfare == nil ? @"" : model.thoroughfare;
    model.subThoroughfare = model.subThoroughfare == nil ? @"" : model.subThoroughfare;
    model.locality = model.locality == nil ? @"" : model.locality;
    model.subLocality = model.subLocality == nil ? @"" : model.subLocality;
    model.administrativeArea = model.administrativeArea == nil ? @"" : model.administrativeArea;
    model.subAdministrativeArea = model.subAdministrativeArea == nil ? @"" : model.subAdministrativeArea;
    
    //
    [self archiveModelToFile:model];
    
    
    self.locationDict = @{@"latitude":@(model.latitude),
                          @"longitude":@(model.longitude),
                          @"administrativeArea":model.administrativeArea,
                          @"subAdministrativeArea":model.subAdministrativeArea,
                          @"locality":model.locality,
                          @"subLocality":model.subLocality,
                          @"thoroughfare":model.thoroughfare,
                          @"subThoroughfare":model.subThoroughfare,
                          @"address": model.address,
                          @"addressName": model.addressName
                          };
    
    NSLog(@"self.locationDict:%@, sself.coords.latitude:%f, self.coords.longitude:%f, model.thoroughfare:%@, model.subThoroughfare:%@, model.locality:%@, model.subLocality:%@, model.administrativeArea:%@, model.subAdministrativeArea:%@", self.locationDict, self.coord.latitude, self.coord.longitude, model.thoroughfare, model.subThoroughfare, model.locality, model.subLocality, model.administrativeArea, model.subAdministrativeArea);
    
    
    if (self.showType == SSChatLocationVCShowTypeChat) {
        NSLog(@"SSChatLocationController MKMapSnapshotter");
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
        
        WFCULocationPoint *ponit = [[WFCULocationPoint alloc] initWithCoordinate:coordinate andTitle:model.addressName];
        
        // 让地图挪动到对应的位置(经纬度交叉处)
        [self.mMapView setCenterCoordinate:coordinate animated:NO];
        
        
        // 创建截图附加选项 - option
        MKMapSnapshotOptions *option = [[MKMapSnapshotOptions alloc] init];
        option.mapRect = self.mMapView.visibleMapRect; // 设置地图区域
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100);
        option.region = region;  // 设置截图区域(在地图上的区域,作用在地图)
        
        option.mapType = MKMapTypeStandard;
        option.showsPointsOfInterest = YES;
        option.showsBuildings = YES;
        
        option.size = CGSizeMake(200, 150);
        option.scale = [[UIScreen mainScreen] scale];
        
        
        // 3. 创建截图对象
        MKMapSnapshotter *snapShoter = [[MKMapSnapshotter alloc] initWithOptions:option];
        [snapShoter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error == nil) {
                // 获取到截图图像
                UIImage *image = snapshot.image;
                
                // 如果想在地图上加入一个大头针，可以直接绘制上去，就像下面一样
                MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] init];
                UIImage *pinImage = pin.image;
                UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
                [image drawAtPoint:CGPointMake(0, 0)];
                
                [pinImage drawAtPoint:[snapshot pointForCoordinate:coordinate]];
                
                UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                ponit.thumbnail = finalImage;
                self.locationPoint = ponit;
                
                
                self.locationBlock(self.locationDict, self.locationPoint);
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                NSLog(@"截图错误：%@",error.localizedDescription);
            }
        }];
        
        
    }
    else if(self.showType == SSChatLocationVCShowTypeMe){
        NSLog(@"SSChatLocationController no need MKMapSnapshotter 111");
        if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
            [self requestCreateAddress];
        }
    }
    else {
        NSLog(@"SSChatLocationController no need MKMapSnapshotter");
        self.locationBlock(self.locationDict, self.locationPoint);
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)archiveModelToFile:(CPAddressModel *)aModel {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"searchaddress.data"];
    NSLog(@"archiveModelToFile filePath: %@", filePath);
    //解档
    NSMutableArray<CPAddressModel *> *addresArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    if (addresArr) {
        tmpArr = addresArr;
    }
    
    if (addresArr.count == 0) {
        [tmpArr addObject:aModel];
    }
    else {
        for (CPAddressModel *model in addresArr) {
            NSLog(@"model.address:%@, aModel.address:%@", model.address, aModel.address);
            if (![aModel.address isEqualToString:model.address]) {
                if (tmpArr.count < 10) {
                    [tmpArr addObject:aModel];
                }
                else if (tmpArr.count == 10) {
                    [tmpArr addObject:aModel];
                    [tmpArr removeLastObject];
                }
                
                break;
            }
        }
    }
    
    //归档
    [NSKeyedArchiver archiveRootObject:tmpArr toFile:filePath];
}

- (void)unArchiveModel {
    //取出归档的文件再解档
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"searchaddress.data"];
    
    //解档
    NSMutableArray<CPAddressModel *> *addresArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    if (addresArr) {
        self.placesArray = addresArr;
    }
}


// !!!: create address
- (void)requestCreateAddress{
    NSLog(@"requestCreateAddress");
    
    NSMutableDictionary *param = @{
                                   @"address":[_locationDict valueForKey:@"address"],
                                   @"addressName":[_locationDict valueForKey:@"addressName"],
                                   @"latitude":[_locationDict valueForKey:@"latitude"],
                                   @"longitude":[_locationDict valueForKey:@"longitude"],
                                   @"thoroughfare":[_locationDict valueForKey:@"thoroughfare"],
                                   @"subThoroughfare":[_locationDict valueForKey:@"subThoroughfare"],
                                   @"locality":[_locationDict valueForKey:@"locality"],
                                   @"subLocality":[_locationDict valueForKey:@"subLocality"],
                                   @"administrativeArea":[_locationDict valueForKey:@"administrativeArea"],
                                   @"subAdministrativeArea":[_locationDict valueForKey:@"subAdministrativeArea"],
                                   }.mutableCopy;
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/address/v1/save", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"SSChatLocationController requestCreateAddress responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedRefreshAddressTableView" object:nil];

                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"SSChatLocationController requestCreateAddress 失败");
            }
        }
        else {
            NSLog(@"SSChatLocationController requestCreateAddress 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"SSChatLocationController requestCreateAddress error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}
@end
