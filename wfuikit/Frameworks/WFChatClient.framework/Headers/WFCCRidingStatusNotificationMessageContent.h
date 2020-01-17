//
//  WFCCRidingStatusNotificationMessageContent.h
//  WFChatClient
//
//  Created by bw on 2019/7/31.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCNotificationMessageContent.h"

typedef NS_ENUM(NSInteger, CarriageStatus) {
    CarriageStatus_Default = 0,
    CarriageStatus_OnCar,
    CarriageStatus_Arrived,
};

NS_ASSUME_NONNULL_BEGIN

@interface WFCCRidingStatusNotificationMessageContent : WFCCNotificationMessageContent
@property (nonatomic, strong) NSString *tip;
@property (nonatomic) CarriageStatus carriageStatus;
@end

NS_ASSUME_NONNULL_END
