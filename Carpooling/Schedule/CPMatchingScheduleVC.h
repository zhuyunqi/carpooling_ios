//
//  CPMatchingScheduleVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPMatchingScheduleVC : CPBaseViewController
@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@property (nonatomic, strong) NSMutableDictionary *requestParams;
@end

NS_ASSUME_NONNULL_END
