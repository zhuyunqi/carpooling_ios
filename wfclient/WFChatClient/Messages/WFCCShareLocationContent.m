//
//  WFCCShareLocationContent.m
//  WFChatClient
//
//  Created by bw on 2019/7/31.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCShareLocationContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"

@implementation WFCCShareLocationContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [dataDict setValue:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    payload.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict
                                                                                     options:kNilOptions
                                                                                       error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[payload.content dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
        self.longitude = [[dictionary valueForKey:@"longitude"] doubleValue];
    }
    
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_REALTIMELOCATION;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_TRANSPARENT;
}


+ (instancetype)contentWithLatitude:(double)latitude
                          longitude:(double)longitude {
    WFCCShareLocationContent *content = [[WFCCShareLocationContent alloc] init];
    content.latitude = latitude;
    content.longitude = longitude;
    return content;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

//- (NSString *)digest:(WFCCMessage *)message {
//    return @"";
//}
@end
