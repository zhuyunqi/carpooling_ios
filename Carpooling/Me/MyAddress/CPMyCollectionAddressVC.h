//
//  CPMyCollectionAddressVC.h
//  Carpooling
//
//  Created by bw on 2019/8/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPMyCollectionAddressVC : CPBaseViewController
@property (nonatomic, assign) BOOL fromMeVC;

@property (nonatomic, assign) BOOL needRefresh; // 删除了地址之后，需要重新刷新。
@end

NS_ASSUME_NONNULL_END
