//
//  CPNationCodeModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPNationCodeModel : NSObject<NSCoding>
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *domainCode;
@end

NS_ASSUME_NONNULL_END
