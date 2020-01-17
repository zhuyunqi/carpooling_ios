//
//  CPNoticeReqResultModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/24.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPNoticeReqResultSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPNoticeReqResultModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) CPNoticeReqResultSubModel *data;
@end

NS_ASSUME_NONNULL_END
