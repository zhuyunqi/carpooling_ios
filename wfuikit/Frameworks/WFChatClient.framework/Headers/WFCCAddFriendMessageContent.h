//
//  WFCCAddFriendMessageContent.h
//  WFChatClient
//
//  Created by bw on 2019/7/5.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "WFCCNotificationMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCCAddFriendMessageContent : WFCCNotificationMessageContent
/**
 构造消息
 
 @param title 添加好友的title
 @return 添加好友消息
 */
+ (instancetype)contentWith:(NSString *)title
                       desc:(NSString *)desc
                     status:(NSInteger)status
                    summary:(NSString *)summary;

/**
 */
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *desc;

@property (nonatomic, assign) NSInteger status; // 0, not deal;  1, agree;  2, ignore;
@end

NS_ASSUME_NONNULL_END
