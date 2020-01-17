//
//  CPContractReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/6.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPContractReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPContractReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPContractReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
