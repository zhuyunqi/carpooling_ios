//
//  SSChatMapController.m
//  SSChatView
//
//  Created by soldoros on 2018/11/19.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatMapController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MKMapView+BWZoomLevel.h"

#define kMapZOOM_LEVEL 9

@interface SSChatMapController ()<CLLocationManagerDelegate, MKMapViewDelegate>

//地图
@property(nonatomic,strong) MKMapView *mMapView;
//定位
@property(nonatomic,strong) CLLocationManager *locationManager;
@end


@implementation SSChatMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizedTableString(@"Location", @"CPLocalizable");
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //初始化地图
    _mMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0 , kSCREENWIDTH, kSCREENHEIGHT)];
    _mMapView.delegate = self;
    _mMapView.mapType = MKMapTypeStandard;
    _mMapView.showsUserLocation = YES;
    _mMapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.view addSubview:_mMapView];
    
    
    MKPointAnnotation * point = [[MKPointAnnotation alloc]init];
    point.title = _addressName;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    point.coordinate = coordinate;
    [self.mMapView addAnnotation:point];
    
    
    
    //设置地图范围
    CLLocationCoordinate2D center = self.mMapView.region.center;
    [self.mMapView setCenterCoordinate:center zoomLevel:kMapZOOM_LEVEL animated:NO];
}


//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//
//    MKPinAnnotationView *pinView = nil;
//
//    static NSString *defaultPinID = @"com.invasivecode.pin";
//    pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//    if ( pinView == nil ) {
//        pinView = [[MKPinAnnotationView alloc]  initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//    }
//    if (@available(iOS 9.0, *)) {
//        pinView.pinTintColor = [UIColor redColor];
//    } else {
//        // Fallback on earlier versions
//        pinView.pinColor = MKPinAnnotationColorRed;
//    }
//    pinView.canShowCallout = YES;
//    pinView.animatesDrop = YES;
////    [mapView.userLocation setTitle:@"欧陆经典"];
////    [mapView.userLocation setSubtitle:@"vsp"];
//    return pinView;
//
//}

@end
