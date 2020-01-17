//
//  CPUserReqResultSubModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/12.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPUserReqResultSubModel : NSObject
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) long long userId;
@property (nonatomic, strong) CPUserInfoModel *user;
@property (nonatomic, strong) NSDictionary *imResult; // im

@end

NS_ASSUME_NONNULL_END
