//
//  CPSearchResultController.h
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPMyFriendCell1, CPUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPSearchResultController : UITableViewController
@property (nonatomic, strong) NSArray *filteredModels;

- (void)configureCell:(CPMyFriendCell1 *)cell forModel:(CPUserInfoModel *)model;
@end

NS_ASSUME_NONNULL_END
