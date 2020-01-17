//
//  CPSelectContractThemeVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/1.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^CTPassValueBlock)(NSString *aSting);

@interface CPSelectContractThemeVC : CPBaseViewController

@property (nonatomic, copy) CTPassValueBlock passValueblock;//声明block
@property (nonatomic, assign) NSInteger titleType;
@property (nonatomic, strong) NSString *aString;
@end

NS_ASSUME_NONNULL_END
