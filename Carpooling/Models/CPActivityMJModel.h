//
//  CPActivityMJModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPAddressModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPActivityMJModel : NSObject
@property (nonatomic, assign) NSUInteger dataid;
@property (nonatomic, strong) CPAddressModel *addressVo;
@property (nonatomic, copy) NSString *imgUrl; // 活动 图片
@property (nonatomic, copy) NSString *name; // 活动 主题
@property (nonatomic, assign) NSTimeInterval date; // timestamp
@property (nonatomic, copy) NSString *describe; // 活动 描述

@property (nonatomic, assign) NSUInteger collect; // 点赞数

@property (nonatomic, strong) NSArray *enrollList; // 前三个报名者
@property (nonatomic, assign) NSUInteger userCount; //报名人数
@property (nonatomic, assign) BOOL isEnrollCurUser; // 当前用户是否报名某个活动

@property (nonatomic, assign) BOOL isEdit; // 当前用户是否可以编辑某个活动


@property (nonatomic, assign) CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
