//
//  CPNationCodeModel.m
//  Carpooling
//
//  Created by Yang on 2019/6/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPNationCodeModel.h"

@implementation CPNationCodeModel
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.country forKey:NSStringFromSelector(@selector(country))];
    [aCoder encodeObject:self.code forKey:NSStringFromSelector(@selector(code))];
    [aCoder encodeObject:self.domainCode forKey:NSStringFromSelector(@selector(domainCode))];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder //NS_DESIGNATED_INITIALIZER
{
    self = [super init];
    if (self){
        _country = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(country))]; // American
        _code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(code))]; // +1
        _domainCode = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(domainCode))]; // US
    }
    return self;
}

@end
