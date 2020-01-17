//
//  CPActivityDetailVC.h
//  Carpooling
//
//  Created by bw on 2019/5/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPActivityMJModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPActivityDetailVC : CPBaseViewController
@property (nonatomic, strong) CPActivityMJModel *activityModel;
@end

NS_ASSUME_NONNULL_END
