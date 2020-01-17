//
//  WFCCShareLocationContent.h
//  WFChatClient
//
//  Created by bw on 2019/7/31.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCCShareLocationContent : WFCCMessageContent
/**
 构造消息
 
 */
+ (instancetype)contentWithLatitude:(double)latitude
                          longitude:(double)longitude;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@end

NS_ASSUME_NONNULL_END
