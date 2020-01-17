//
//  CPHomeReqResultSubModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPHomeReqResultSubModel : NSObject
@property (nonatomic, strong) NSString *describe;
@property (nonatomic, assign) NSMutableArray *banner;
@property (nonatomic, assign) NSMutableArray *contracts;
@property (nonatomic, assign) NSMutableArray *schedules;
@property (nonatomic, assign) NSMutableArray *activitys;
@property (nonatomic, assign) NSMutableArray *allActivity;
@property (nonatomic, assign) NSMutableArray *hotActivitys;
@end

NS_ASSUME_NONNULL_END
