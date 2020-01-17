//
//  CPHomeVC.h
//  Carpooling
//
//  Created by bw on 2019/5/15.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CPHomeVCShowStyle ) {
    CPHomeVCShowStyleFirstOpen, // first open
    CPHomeVCShowStyleLogin, // log in
    CPHomeVCShowStyleLoginNoData, // log in but no data
    CPHomeVCShowStyleNotLogin // not log in, use 
};

@interface CPHomeVC : CPBaseViewController
@property (nonatomic, assign) CPHomeVCShowStyle showStyle;

@end

NS_ASSUME_NONNULL_END
