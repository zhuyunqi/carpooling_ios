//
//  CPInitLongTermContractVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/1.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN
typedef void (^PassValueBlock)(NSDictionary *dict);

@interface CPInitLongTermContractVC : CPBaseViewController
@property (nonatomic, copy) PassValueBlock passValueblock;//声明block

// 从匹配行程进入的
@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@property (nonatomic, copy) NSString *targetIMUserId;
@end

NS_ASSUME_NONNULL_END
