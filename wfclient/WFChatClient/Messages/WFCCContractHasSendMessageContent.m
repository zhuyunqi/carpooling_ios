//
//  WFCCContractHasSendMessageContent.m
//  WFChatClient
//
//  Created by bw on 2019/12/4.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCContractHasSendMessageContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"

@implementation WFCCContractHasSendMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:self.tip forKey:@"tip"];
    
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
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_CONTRACTHASSEND_TIP;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}


- (NSString *)digest:(WFCCMessage *)message {
    return self.tip;
}
@end
