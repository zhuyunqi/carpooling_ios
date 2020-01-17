//
//  CPAddressReqResultSubModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPAddressModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPAddressReqResultSubModel : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numsPerPage;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSArray *data;

@end

NS_ASSUME_NONNULL_END
