//
//  CPAddressModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPAddressModel : NSObject <NSCoding>
@property (nonatomic, assign) NSUInteger dataid;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BOOL isCollect;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *addressName;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *thoroughfare;
@property (nonatomic, copy) NSString *subThoroughfare;
@property (nonatomic, copy) NSString *locality;
@property (nonatomic, copy) NSString *subLocality;
@property (nonatomic, copy) NSString *administrativeArea;
@property (nonatomic, copy) NSString *subAdministrativeArea;


@property (nonatomic, assign) CGFloat cellHeight;

//+ (NSString *)handleAddressFormatWithModel:(CPAddressModel*)model;
@end

NS_ASSUME_NONNULL_END
