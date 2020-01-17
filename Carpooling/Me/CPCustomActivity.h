//
//  CPCustomActivity.h
//  Carpooling
//
//  Created by Yang on 2019/6/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPCustomActivity : UIActivity
- (instancetype)initWithTitle:(NSString *)title URL:(NSURL *)url ActivityType:(NSString *)activityType;
@end

NS_ASSUME_NONNULL_END
