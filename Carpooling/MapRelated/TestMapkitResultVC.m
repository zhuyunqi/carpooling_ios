//
//  TestMapkitResultVC.m
//  Carpooling
//
//  Created by bw on 2019/8/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import "TestMapkitResultVC.h"
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


@interface TestMapkitResultVC ()<CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

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

@property (nonatomic, strong) BWSearchBar *searchBar;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, strong) NSMutableArray *annotationArray;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

//返回数据
@property (nonatomic, strong) WFCULocationPoint *locationPoint;
@property (nonatomic, strong) NSDictionary *locationDict;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) UITextField *latTF;
@property (nonatomic, strong) UITextField *lngTF;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UILabel *resultLbl;
@end


@implementation TestMapkitResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizedTableString(@"Location", @"CPLocalizable");
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
    [self.searchBar setTintColor:[UIColor blackColor]];
    [self.searchBar setTranslucent:YES];// 设置是否透明
    self.searchBar.showsCancelButton = NO;
    
    //    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(30, 0)];// 设置搜索框中文本框的文本偏移量
    self.searchBar.delegate = self;// 设置代理
    [self.searchBar sizeToFit];
//    [self.view addSubview:self.searchBar];
    
    
    //定位按钮
    self.locationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.locationBtn.frame = CGRectMake(kSCREENWIDTH - 40, CGRectGetMinY(self.searchBar.frame)-35, 30, 30);
    [self.locationBtn setImage:[UIImage imageNamed:@"map_location_backToLocal"] forState:UIControlStateNormal];
    [self.locationBtn setTintColor:[UIColor darkGrayColor]];
    [self.locationBtn addTarget:self action:@selector(locationBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.locationBtn];
    
    
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
    
    
    
    self.latTF = [[UITextField alloc] initWithFrame:CGRectMake(10, kNAVIBARANDSTATUSBARHEIGHT+5, 120, 44)];
    self.latTF.font = [UIFont systemFontOfSize:15];
    self.latTF.placeholder = @"enter latitude";
    self.latTF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.latTF];
    
    self.lngTF = [[UITextField alloc] initWithFrame:CGRectMake(140, kNAVIBARANDSTATUSBARHEIGHT+5, 120, 44)];
    self.lngTF.font = [UIFont systemFontOfSize:15];
    self.lngTF.placeholder = @"enter longitude";
    self.lngTF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.lngTF];
    
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.confirmBtn.frame = CGRectMake(270, kNAVIBARANDSTATUSBARHEIGHT+5, 90, 44);
    self.confirmBtn.backgroundColor = [UIColor whiteColor];
    self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.confirmBtn setTitle:@"get address" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmBtn];
    
    self.resultLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.searchBar.frame)+20, kSCREENWIDTH-10, kSCREENHEIGHT/2-10)];
    self.resultLbl.numberOfLines = 0;
    self.resultLbl.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:self.resultLbl];
    
    [self.view bringSubviewToFront:self.latTF];
    [self.view bringSubviewToFront:self.lngTF];
    [self.view bringSubviewToFront:self.confirmBtn];
    [self.view bringSubviewToFront:self.resultLbl];
}

- (void)confirmBtnClick:(UIButton*)btn{
    [self.view endEditing:YES];
    if (_locationManager) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latTF.text doubleValue] longitude:[self.lngTF.text doubleValue]];
        
        [self getPlacemarkBylocation:location];
        
    }
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
            
            if (self.refreshLocation) {
                [self.placesArray removeAllObjects];
                self.refreshLocation = NO;
            }

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
            NSString *address = @"";
            
            NSArray *array = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
            if (array.count > 0) {
                NSString *address2 = [array firstObject];
                model.address = address2;
            }
            else {
                model.address = address;
            }
            
            self.resultLbl.text = [NSString stringWithFormat:@" coordinate.latitude: %f,\n coordinate.longitude: %f,\n placemark.name: %@,\n placemark.thoroughfare: %@,\n placemark.subThoroughfare: %@,\n placemark.locality: %@,\n placemark.subLocality: %@,\n placemark.administrativeArea: %@,\n placemark.subAdministrativeArea: %@", currLocation.coordinate.latitude, currLocation.coordinate.longitude, placemark.name, placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.subLocality, placemark.administrativeArea, placemark.subAdministrativeArea];
            [self.resultLbl sizeToFit];
            
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
            
            [self.placesArray addObject:model];
            
//            [self.tableView reloadData];
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
    
    
#warning google map
    //google map 反向地理编码
    //    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:currLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
    //        if (error) {
    //            self.noDataLbl.hidden = NO;
    //        }
    //        else {】
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
                
                NSLog(@"placemark.addressDictionary[FormattedAddressLines]:%@", [placemark.addressDictionary valueForKey:@"FormattedAddressLines"]);
                NSString *address = @"";
                
                NSArray *array = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
                if (array.count > 0) {
                    NSString *address2 = [array firstObject];
                    model.address = address2;
                }
                else {
                    model.address = address;
                }
                
                [self.placesArray addObject:model];
                
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = mapItem.name;
                annotation.coordinate = mapItem.placemark.coordinate;
                [self.annotationArray addObject:annotation];
                [self.mMapView addAnnotation:annotation];
            }
            
//            [self.tableView reloadData];
            
            
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
    if (!self.selectedIndexPath) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
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
