//
//  WFCUStrangerMessageController.h
//  Carpooling
//
//  Created by bw on 2019/7/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WFCCConversation;
@class CPUserInfoModel, CPScheduleMJModel, CPContractMJModel;
NS_ASSUME_NONNULL_BEGIN

@interface WFCUStrangerMessageController : UIViewController

@property (nonatomic, strong)WFCCConversation *conversation;

@property (nonatomic, strong)NSString *highlightText;
@property (nonatomic, assign)long highlightMessageId;

//仅限于在Channel内使用。Channel的owner对订阅Channel单个用户发起一对一私聊
@property (nonatomic, strong)NSString *privateChatUser;



//对方的头像 昵称 模型
//@property (nonatomic, strong) CPUserInfoModel *otherUserModel;

// 从匹配行程进入聊天
@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@property (nonatomic, assign) BOOL showMatchingTopHeaderView;
// 从我的合约进入聊天
@property (nonatomic, strong) CPContractMJModel *contractMJModel;
@end

NS_ASSUME_NONNULL_END
