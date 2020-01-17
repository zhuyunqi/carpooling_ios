//
//  CPUserInfoVC.h
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPUserInfoVC : CPBaseViewController
@property (nonatomic, strong) CPUserInfoModel *user;
@end

NS_ASSUME_NONNULL_END
