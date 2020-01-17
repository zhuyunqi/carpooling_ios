//
//  CPContractMJModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/6.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPUserInfoModel, CPAddressModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPContractMJModel : NSObject
@property (nonatomic, assign) NSUInteger dataid;
@property (nonatomic, copy) NSString *beginTime;
@property (nonatomic, copy) NSString *contractCycle;
@property (nonatomic, strong) NSString *weekNum;
@property (nonatomic, strong) NSString *noticeTag;

@property (nonatomic, assign) NSInteger contractType;// 合约类型 contractType  0:短期 1:长期 2:正在进行 3:历史合约
@property (nonatomic, assign) NSInteger status;// 合约状态 status 0:新建状态 1:接受合约 11:开始进行(已到约定开始时间)  2:合约取消  3:合约结束(完成)
@property (nonatomic, assign) NSInteger ridingStatus;//乘车状态  1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达

@property (nonatomic, assign) NSInteger userType; //合约创建者 0:乘客  1：司机
@property (nonatomic, assign) NSInteger curUserType; //当前用户 0:乘客  1：司机
@property (nonatomic, assign) BOOL oneSideHasConfirmArrive; // local mark 本地标记  一方已确认到达
@property (nonatomic, assign) NSTimeInterval onCarTimestamp; // 确认上车的时间戳
@property (nonatomic, assign) NSTimeInterval confirmArriveTimestamp; // 确认到达的时间戳
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *remark; // 合约备注
@property (nonatomic, strong) NSArray *contractCyclesz; //

@property (nonatomic, copy) NSString *imUserId;
@property (nonatomic, copy) NSString *targetIMUserId;
@property (nonatomic, assign) long long userId; // 创建者id
@property (nonatomic, assign) long long qyUserId; // 签约者id

@property (nonatomic, strong) CPAddressModel *fromAddressVo;
@property (nonatomic, strong) CPAddressModel *toAddressVo;

@property (nonatomic, strong) CPUserInfoModel *cjUserVo; //创建合约者
@property (nonatomic, strong) CPUserInfoModel *qyUserVo; //接受合约者



@property (nonatomic, assign) NSInteger markValue; // 本人是否评价
@property (nonatomic, copy) NSString *evaluateRemark; // 本人 评价备注
@property (nonatomic, assign) NSInteger qyMarkValue; // 对方是否评价
@property (nonatomic, copy) NSString *qyEvaluateRemark; // 对方 评价备注


@property (nonatomic) BOOL isFriend;


@property (nonatomic, assign) CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
