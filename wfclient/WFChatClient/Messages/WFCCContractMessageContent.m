//
//  WFCCContractMessageContent.m
//  WFChatClient
//
//  Created by bw on 2019/7/6.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCContractMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"

@implementation WFCCContractMessageContent

- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    payload.pushContent = self.summary;
    payload.searchableContent = [NSString stringWithFormat:@"%ld", (long)self.contractType];
    //    payload.binaryContent = UIImageJPEGRepresentation(self.thumbnail, 0.67);
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:self.summary forKey:@"summary"];
    [dataDict setValue:self.from forKey:@"from"];
    [dataDict setValue:self.to forKey:@"to"];
    [dataDict setValue:self.beginTime forKey:@"beginTime"];
    [dataDict setValue:self.endTime forKey:@"endTime"];
    [dataDict setValue:self.endDate forKey:@"endDate"];
    [dataDict setValue:self.weekNum forKey:@"weekNum"];
    [dataDict setValue:self.time forKey:@"time"];
    [dataDict setValue:self.remark forKey:@"remark"];
    [dataDict setValue:[NSNumber numberWithInteger:self.contractId] forKey:@"contractId"];
    [dataDict setValue:[NSNumber numberWithInteger:self.status] forKey:@"status"];
    payload.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict
                                                                                     options:kNilOptions
                                                                                       error:nil] encoding:NSUTF8StringEncoding];
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    self.contractType = [payload.searchableContent integerValue];
    //    self.thumbnail = [UIImage imageWithData:payload.binaryContent];
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[payload.content dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.summary = [dictionary valueForKey:@"summary"];
        self.from = [dictionary valueForKey:@"from"];
        self.to = [dictionary valueForKey:@"to"];
        self.beginTime = [dictionary valueForKey:@"beginTime"];
        self.endTime = [dictionary valueForKey:@"endTime"];
        self.endDate = [dictionary valueForKey:@"endDate"];
        self.weekNum = [dictionary valueForKey:@"weekNum"];
        self.time = [dictionary valueForKey:@"time"];
        self.remark = [dictionary valueForKey:@"remark"];
        self.contractId = [[dictionary valueForKey:@"contractId"] integerValue];
        self.status = [[dictionary valueForKey:@"status"] integerValue];
    }
    
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_CONTRACT;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}

+ (instancetype)contentWithContractType:(NSInteger )contractType
                                   from:(NSString *)from
                                     to:(NSString *)to
                              beginTime:(NSString *)beginTime
                                endTime:(NSString *)endTime
                                endDate:(NSString *)endDate
                                weekNum:(NSString *)weekNum
                                   time:(NSString *)time
                                 remark:(NSString *)remark
                             contractId:(NSInteger)contractId
                                 status:(NSInteger)status
                                summary:(NSString *)summary {
    WFCCContractMessageContent *content = [[WFCCContractMessageContent alloc] init];
    content.summary = summary;
    content.contractType = contractType;
    content.from = from;
    content.to = to;
    content.beginTime = beginTime;
    content.endTime = endTime;
    content.endDate = endDate;
    content.weekNum = weekNum;
    content.time = time;
    content.remark = remark;
    content.contractId = contractId;
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
