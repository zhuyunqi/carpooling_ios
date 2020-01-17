//
//  CPBindingPhoneVC.h
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^BindingPhonePassValueBlock)(NSString *phone);
@interface CPBindingPhoneVC : CPBaseViewController
@property (nonatomic, copy) BindingPhonePassValueBlock passValueblock;//声明block
@end

NS_ASSUME_NONNULL_END
