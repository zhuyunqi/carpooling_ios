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

@interface WFCCContractAttitudeTipPushNotificationMessageContent : WFCCNotificationMessageContent
@property (nonatomic, strong) NSString *tip;
@property (nonatomic, assign) NSInteger contractId;
@property (nonatomic, assign) NSInteger contractType;
@property (nonatomic, copy) NSString *beginTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, strong) NSString *weekNum;
@property (nonatomic) ContractAttitude contractAttitude;
@end

NS_ASSUME_NONNULL_END
