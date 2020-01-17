//
//  CPScheduleMJModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPUserInfoModel, CPAddressModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPScheduleMJModel : NSObject
@property (nonatomic, assign) NSUInteger dataid;
//status   0:新建    1：已匹配    2: 使用中     3:结束
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, strong) NSString *schedulingCycle;
@property (nonatomic, strong) NSString *weekNum;
@property (nonatomic, assign) NSTimeInterval arriveTime;

@property (nonatomic, strong) CPAddressModel *fromAddressVo;
@property (nonatomic, strong) CPAddressModel *toAddressVo;

@property (nonatomic, strong) CPUserInfoModel *userVo;
@property (nonatomic, strong) CPUserInfoModel *cjContractUserVo; // 从匹配行程里，发起合约的人
@property (nonatomic, assign) NSInteger contractId; //从行程跳转到合约详情


@property (nonatomic, assign) NSInteger userType; // 0:乘客  1：司机
@property (nonatomic) BOOL isFriend;


@property (nonatomic, assign) CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
