//
//  CPNoticeModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPNoticeModel : NSObject
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *content;


@property (nonatomic, assign) CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
