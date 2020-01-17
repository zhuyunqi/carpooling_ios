//
//  CPUserRegister2VC.h
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPUserRegister2VC : CPBaseViewController
@property (nonatomic, strong) NSString *account;
@property (nonatomic, assign) NSInteger handleType;
@property (nonatomic, assign) BOOL isEmailRegister;
@property (nonatomic, assign) BOOL isCellPhoneRegister;
@end

NS_ASSUME_NONNULL_END
