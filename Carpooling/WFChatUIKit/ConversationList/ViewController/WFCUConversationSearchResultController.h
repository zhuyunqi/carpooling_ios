//
//  WFCUConversationSearchResultController.h
//  Carpooling
//
//  Created by bw on 2019/8/10.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFChatClient/WFCChatClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFCUConversationSearchResultController : UITableViewController
@property (nonatomic, strong) NSArray<WFCCConversationSearchInfo *>  *searchConversationList;
@property (nonatomic, strong) NSArray<WFCCUserInfo *>  *searchFriendList;
@property (nonatomic, strong) NSArray<WFCCGroupSearchInfo *>  *searchGroupList;
@end

NS_ASSUME_NONNULL_END
