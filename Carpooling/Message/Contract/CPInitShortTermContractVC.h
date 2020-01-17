//
//  CPInitShortTermContractVC.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN
typedef void (^STPassValueBlock)(NSDictionary *dict);

@interface CPInitShortTermContractVC : CPBaseViewController
@property (nonatomic, copy) STPassValueBlock passValueblock;//声明block

// 从匹配行程进入的
@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;

@property (nonatomic, copy) NSString *targetIMUserId;

@end

NS_ASSUME_NONNULL_END
