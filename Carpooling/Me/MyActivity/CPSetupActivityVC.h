//
//  CPSetupActivityVC.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
@class CPActivityMJModel;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SetupActivityVCType){
    SetupActivityVCTypeSetup = 0,       // 新建活动
    SetupActivityVCTypeEdit = 1,        // 编辑活动
};

typedef void (^SetupActivityPassValueBlock)(BOOL success);
@interface CPSetupActivityVC : CPBaseViewController
@property (nonatomic, assign) SetupActivityVCType showType;
@property (nonatomic, copy) SetupActivityPassValueBlock passValueblock;//声明block
@property (nonatomic, strong) CPActivityMJModel *activityModel;
@end

NS_ASSUME_NONNULL_END
