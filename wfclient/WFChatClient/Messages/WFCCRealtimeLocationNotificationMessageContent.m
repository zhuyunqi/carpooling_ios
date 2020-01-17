//
//  WFCCRealtimeLocationNotificationMessageContent.m
//  WFChatClient
//
//  Created by bw on 2019/10/29.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCRealtimeLocationNotificationMessageContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"

@implementation WFCCRealtimeLocationNotificationMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    payload.pushContent = self.tip;
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:[NSNumber numberWithInteger:self.shareLocationStatus] forKey:@"shareLocationStatus"];
    [dataDict setValue:self.tip forKey:@"tip"];
    [dataDict setValue:self.othersIMUserId forKey:@"othersIMUserId"];
    
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
        self.tip = [dictionary valueForKey:@"tip"];
        self.othersIMUserId = [dictionary valueForKey:@"othersIMUserId"];
        self.shareLocationStatus = [[dictionary valueForKey:@"shareLocationStatus"] integerValue];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_REALTIMELOCATION_TIP;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)formatNotification:(WFCCMessage *)message {
    return self.tip;
}

- (NSString *)digest:(WFCCMessage *)message {
    return self.tip;
}
@end
