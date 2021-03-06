//
//  CPScheduleReqResultModel.m
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPScheduleReqResultModel.h"
#import "CPScheduleReqResultSubModel.h"

@implementation CPScheduleReqResultModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"desc":@"description",
             @"dataid":@"id",
             
             // 左边代表 NHYHCGetHospitalsResult的属性NSArray *hospitals
             // 右边代表 服务器返回的数据中的字段名
             // 服务器返回的hospital_info是一个数组
             @"data":@"data",
             };
}
@end
