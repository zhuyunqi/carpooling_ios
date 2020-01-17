//
//  WFCCRealtimeLocationNotificationMessageContent.h
//  WFChatClient
//
//  Created by bw on 2019/10/29.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCNotificationMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RealtimeLocationStatus) {
    RealtimeLocation_Start = 0,
    RealtimeLocation_End,
};

@interface WFCCRealtimeLocationNotificationMessageContent : WFCCNotificationMessageContent
@property (nonatomic, strong) NSString *tip;
@property (nonatomic, strong) NSString *othersIMUserId;
@property (nonatomic) RealtimeLocationStatus shareLocationStatus;
@end

NS_ASSUME_NONNULL_END
