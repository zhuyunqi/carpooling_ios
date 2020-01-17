//
//  CPAddressReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPAddressReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPAddressReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPAddressReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
