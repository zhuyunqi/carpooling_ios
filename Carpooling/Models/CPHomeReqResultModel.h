//
//  CPHomeReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPHomeReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPHomeReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPHomeReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
