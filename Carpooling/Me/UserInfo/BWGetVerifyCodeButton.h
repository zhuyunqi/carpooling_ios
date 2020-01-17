//
//  BWGetVerifyCodeButton.h
//  NHYHealthChainDoctor
//
//  Created by __ on 2018/12/28.
//  Copyright © 2018 __. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BWGetVerifyCodeButton : UIButton

/*
 * 定时器
 */
@property(strong, nonatomic) NSTimer *timer;


/*
 * 定时多少秒
 */
@property(assign,nonatomic) NSInteger seconds;

/*
 * 定时多少秒
 */
- (void)countDownWithSeconds:(NSInteger)seconds;

@end

NS_ASSUME_NONNULL_END
