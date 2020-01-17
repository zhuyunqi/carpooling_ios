//
//  CPMyActivityVC.h
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MyActivityShowType){
    MyActivityShowTypeMe = 0,       // 个人中心
    MyActivityShowTypeHome = 1,        // 首页
    MyActivityShowTypeHotActivity = 2,        // 热门活动
    MyActivityShowTypeAllActivity = 3,        // 平台全部活动
};

@interface CPMyActivityVC : CPBaseViewController
@property (nonatomic, assign) MyActivityShowType showType;
@end

NS_ASSUME_NONNULL_END
