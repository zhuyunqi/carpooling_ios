//
//  CPScheduleReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPScheduleReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPScheduleReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPScheduleReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
