//
//  CPActivityMemberReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPActivityMemberReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPActivityMemberReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPActivityMemberReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
