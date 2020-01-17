//
//  CPMatchingScheduleModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CPUserInfoModel, CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPMatchingScheduleModel : NSObject
@property (nonatomic) BOOL isFriend;
@property (nonatomic, strong) CPUserInfoModel *userVo;
@property (nonatomic, strong) CPScheduleMJModel *schedulingCarpoolVo;


@property (nonatomic, assign) CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
