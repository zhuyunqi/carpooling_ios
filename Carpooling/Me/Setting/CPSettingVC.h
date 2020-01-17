//
//  CPSettingVC.h
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^STVCPassValueBlock)(BOOL logout);

@interface CPSettingVC : CPBaseViewController
@property (nonatomic, copy) STVCPassValueBlock passValueblock;//声明block
@end

NS_ASSUME_NONNULL_END
