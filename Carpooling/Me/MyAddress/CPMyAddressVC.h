//
//  CPMyAddressVC.h
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
//typedef NS_ENUM(NSUInteger, MyAddressShowType){
//    MyAddressShowTypeCollect = 0,       // 我的收藏
//    MyAddressShowTypeMine = 1,     // 我的地址
//    MyAddressShowTypeHistory = 2,     // 历史地址
//};

@interface CPMyAddressVC : CPBaseViewController
//@property (nonatomic, assign) MyAddressShowType showType;
@property (nonatomic, assign) BOOL fromMeVC;

@property (nonatomic, assign) BOOL needRefresh; // 删除了地址之后，需要重新刷新。
@end

NS_ASSUME_NONNULL_END
