//
//  CPUserReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/12.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPUserReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPUserReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPUserReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
