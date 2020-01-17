//
//  ConversationSearchTableViewController
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFChatClient/WFCChatClient.h>

@interface WFCUConversationSearchTableViewController : CPBaseViewController
@property(nonatomic, strong)WFCCConversation *conversation;
@property(nonatomic, strong)NSString *keyword;
@end
