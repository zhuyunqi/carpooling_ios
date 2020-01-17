//
//  CPContractDetailVC.h
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPContractMJModel, CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN
typedef void (^ContractDetailPassValueBlock)(BOOL cancel);

@interface CPContractDetailVC : CPBaseViewController
@property (nonatomic, copy) ContractDetailPassValueBlock passValueblock;//声明block

@property (nonatomic, assign) NSInteger contractId; //从行程跳转到合约详情
@end

NS_ASSUME_NONNULL_END
