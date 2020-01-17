//
//  SSChatLocationController.h
//  SSChatView
//
//  Created by soldoros on 2018/10/15.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WFCULocationPoint;

typedef NS_ENUM(NSUInteger, SSChatLocationVCShowType) {
    SSChatLocationVCShowTypeNoChat = 0,  // not come from chat
    SSChatLocationVCShowTypeChat = 1, // come from chat
    SSChatLocationVCShowTypeMe = 2 // come from me model
};

typedef void (^SSChatLocationBlock)(NSDictionary *locationDict, WFCULocationPoint *point);

@interface SSChatLocationController : CPBaseViewController

@property (nonatomic, copy) SSChatLocationBlock locationBlock;
@property (nonatomic, assign) SSChatLocationVCShowType showType;

@end


