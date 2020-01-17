//
//  WFCCAddFriendMessageContent.m
//  WFChatClient
//
//  Created by bw on 2019/7/5.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCAddFriendMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"

@implementation WFCCAddFriendMessageContent

- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    payload.searchableContent = self.title;
    payload.pushContent = self.summary;

    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:self.summary forKey:@"summary"];
    [dataDict setValue:self.desc forKey:@"desc"];
    [dataDict setValue:[NSNumber numberWithInteger:self.status] forKey:@"status"];
    payload.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict
                                                                                     options:kNilOptions
                                                                                       error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    self.title = payload.searchableContent;
//    self.thumbnail = [UIImage imageWithData:payload.binaryContent];
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[payload.content dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.summary = [dictionary valueForKey:@"summary"];
        self.desc = [dictionary valueForKey:@"desc"];
        self.status = [[dictionary valueForKey:@"status"] integerValue];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_ADDFRIEND;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}


+ (instancetype)contentWith:(NSString *)title
                       desc:(NSString *)desc
                     status:(NSInteger)status
                    summary:(NSString *)summary {
    WFCCAddFriendMessageContent *content = [[WFCCAddFriendMessageContent alloc] init];
    content.summary = summary;
    content.title = title;
    content.desc = desc;
    content.status = status;
    return content;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return self.summary;
}

@end
