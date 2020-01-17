//
//  WFCCTextMessageContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/8/16.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCLocationMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"
#import "WFCCUtilities.h"

@implementation WFCCLocationMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    payload.searchableContent = self.title;
    payload.binaryContent = UIImageJPEGRepresentation(self.thumbnail, 0.67);
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@(self.coordinate.latitude) forKey:@"latitude"];
    [dataDict setObject:@(self.coordinate.longitude) forKey:@"longitude"];
    [dataDict setValue:self.address forKey:@"address"];
    [dataDict setValue:self.address forKey:@"addressName"];
    [dataDict setValue:self.thoroughfare forKey:@"thoroughfare"];
    [dataDict setValue:self.subThoroughfare forKey:@"subThoroughfare"];
    [dataDict setValue:self.locality forKey:@"locality"];
    [dataDict setValue:self.subLocality forKey:@"subLocality"];
    [dataDict setValue:self.administrativeArea forKey:@"administrativeArea"];
    [dataDict setValue:self.subAdministrativeArea forKey:@"subAdministrativeArea"];
    
    [dataDict setValue:[NSNumber numberWithInteger:self.status] forKey:@"status"];
    
    payload.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict
                                                                                     options:kNilOptions
                                                                                       error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    self.title = payload.searchableContent;
    self.thumbnail = [UIImage imageWithData:payload.binaryContent];
    
    self.thumbnail = [WFCCUtilities imageCompressForSize:self.thumbnail targetSize:CGSizeMake(200, 150)];
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[payload.content dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        double latitude = [dictionary[@"latitude"] doubleValue];
        double longitude = [dictionary[@"longitude"] doubleValue];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        self.status = [[dictionary valueForKey:@"status"] integerValue];
        
        self.address = dictionary[@"address"];
        self.addressName = dictionary[@"addressName"];
        self.thoroughfare = dictionary[@"thoroughfare"];
        self.subThoroughfare = dictionary[@"subThoroughfare"];
        self.locality = dictionary[@"locality"];
        self.subLocality = dictionary[@"subLocality"];
        self.administrativeArea = dictionary[@"administrativeArea"];
        self.subAdministrativeArea = dictionary[@"subAdministrativeArea"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_LOCATION;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}


+ (instancetype)contentWith:(CLLocationCoordinate2D) coordinate
                      title:(NSString *)title
                  thumbnail:(UIImage *)thumbnail
                    address:(NSString *)address
                addressName:(NSString *)addressName
               thoroughfare:(NSString *)thoroughfare
            subThoroughfare:(NSString *)subThoroughfare
                   locality:(NSString *)locality
                subLocality:(NSString *)subLocality
         administrativeArea:(NSString *)administrativeArea
      subAdministrativeArea:(NSString *)subAdministrativeArea
                     status:(NSInteger)status {
    
    WFCCLocationMessageContent *content = [[WFCCLocationMessageContent alloc] init];
    content.coordinate = coordinate;
    content.title = title;

    content.thumbnail = [WFCCUtilities imageCompressForSize:thumbnail targetSize:CGSizeMake(200, 150)];
    
    content.address = address;
    content.addressName = addressName;
    content.thoroughfare = thoroughfare;
    content.subThoroughfare = subThoroughfare;
    content.locality = locality;
    content.subLocality = subLocality;
    content.administrativeArea = administrativeArea;
    content.subAdministrativeArea = subAdministrativeArea;
    content.status = status;

    return content;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
  return @"[位置]";
}
@end
