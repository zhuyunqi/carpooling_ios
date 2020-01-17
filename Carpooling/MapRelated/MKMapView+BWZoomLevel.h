//
//  MKMapView+BWZoomLevel.h
//  Carpooling
//
//  Created by Yang on 2019/6/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMapView (BWZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
