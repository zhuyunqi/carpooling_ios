//
//  CPSetupScheduleVC.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ScheduleVCShowType){
    ScheduleVCShowTypeSetup = 0,       // 新建行程
    ScheduleVCShowTypeEdit = 1,        // 编辑行程
};

typedef void (^SetupSchedulePassValueBlock)(BOOL success);

@interface CPSetupScheduleVC : CPBaseViewController
@property (nonatomic, copy) SetupSchedulePassValueBlock passValueblock;//声明block
@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@property (nonatomic, assign) ScheduleVCShowType showType;
@end

NS_ASSUME_NONNULL_END
