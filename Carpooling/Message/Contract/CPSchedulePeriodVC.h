//
//  CPSchedulePeriodVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/2.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^SPPassValueBlock)(NSString *aSting, NSString *aSting2);

@interface CPSchedulePeriodVC : CPBaseViewController
@property (nonatomic, copy) SPPassValueBlock passValueblock;//声明block
@property (nonatomic, strong) NSString *selectedWeekNum;
@end

NS_ASSUME_NONNULL_END
