//
//  CPActivityReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPActivityReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPActivityReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPActivityReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
