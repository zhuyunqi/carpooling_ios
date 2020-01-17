//
//  CPMatchingScheduleReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPMatchingScheduleReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPMatchingScheduleReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPMatchingScheduleReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
