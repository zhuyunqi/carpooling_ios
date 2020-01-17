//
//  WFCCTipPushNotificationMessageContent.h
//  WFChatClient
//
//  Created by bw on 2019/8/8.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCNotificationMessageContent.h"
typedef NS_ENUM(NSInteger, ContractAttitude) {
    ContractAttitude_Default = 0,
    ContractAttitude_Agree,
    ContractAttitude_Reject,
};
NS_ASSUME_NONNULL_BEGIN

@interface WFCCTipPushNotificationMessageContent : WFCCMessageContent
@property (nonatomic, strong) NSString *tip;
@property (nonatomic) ContractAttitude contractAttitude;
@end

NS_ASSUME_NONNULL_END
