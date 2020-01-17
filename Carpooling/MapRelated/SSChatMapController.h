//
//  SSChatMapController.h
//  SSChatView
//
//  Created by soldoros on 2018/11/19.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SSChatMapController : CPBaseViewController

// 纬度 经度 
@property(nonatomic,assign)CGFloat latitude;
@property(nonatomic,assign)CGFloat longitude;
@property(nonatomic, strong) NSString *addressName;

@end


