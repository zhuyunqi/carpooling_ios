//
//  CPUserLoginVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ULVCPassValueBlock)(BOOL login);
@interface CPUserLoginVC : CPBaseViewController
@property (nonatomic, copy) ULVCPassValueBlock passValueblock;//声明block
@end

NS_ASSUME_NONNULL_END
