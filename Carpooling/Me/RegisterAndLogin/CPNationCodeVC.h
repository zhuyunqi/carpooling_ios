//
//  CPNationCodeVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^NationCodeVCPassValueBlock)(NSDictionary *dict);


@interface CPNationCodeVC : CPBaseViewController
@property (nonatomic, copy) NationCodeVCPassValueBlock passValueblock;//声明block
@end

NS_ASSUME_NONNULL_END
