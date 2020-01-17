//
//  CPNoticeMessage2VC.h
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CPNoticeShowType){
    CPNoticeShowTypeBranding = 1,       // 推广消息
    CPNoticeShowTypeSystem = 2,     // 系统消息
};

@interface CPNoticeMessage2VC : CPBaseViewController
@property (nonatomic, assign) CPNoticeShowType showType;
@end

NS_ASSUME_NONNULL_END
