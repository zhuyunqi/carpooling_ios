//
//  MessageListViewController.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/31.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPUserInfoModel, CPScheduleMJModel;

@class WFCCConversation;
@interface WFCUMessageListViewController : UIViewController
@property (nonatomic, strong)WFCCConversation *conversation;

@property (nonatomic, strong)NSString *highlightText;
@property (nonatomic, assign)long highlightMessageId;

//仅限于在Channel内使用。Channel的owner对订阅Channel单个用户发起一对一私聊
@property (nonatomic, strong)NSString *privateChatUser;



//对方的头像 昵称 模型
//@property (nonatomic, strong) CPUserInfoModel *otherUserModel;

// 从匹配行程进入聊天
@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@end
