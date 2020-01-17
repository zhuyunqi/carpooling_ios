//
//  CPActivityMemberModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPUserInfoModel.h"
@class CPUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPActivityMemberModel : NSObject
@property (nonatomic) BOOL isFriend;
@property (nonatomic, strong) CPUserInfoModel *userVo;
@end

NS_ASSUME_NONNULL_END
