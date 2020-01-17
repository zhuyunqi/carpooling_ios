//
//  WFCCContractMessageContent.h
//  WFChatClient
//
//  Created by bw on 2019/7/6.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCCContractMessageContent : WFCCMessageContent

/**
 构造消息
 
 @param contractType 合约类型
 @return 合约消息
 */
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
                                summary:(NSString *)summary;

/**
 */
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, assign) NSInteger contractType;
@property (nonatomic, copy) NSString *beginTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, strong) NSString *weekNum;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, assign) NSInteger contractId;

@property (nonatomic, assign) NSInteger status; // 0, not deal;  1, agree;  2, reject;

@end

NS_ASSUME_NONNULL_END
