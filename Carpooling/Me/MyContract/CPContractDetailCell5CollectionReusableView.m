//
//  CPContractDetailCell5CollectionReusableView.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailCell5CollectionReusableView.h"

@interface CPContractDetailCell5CollectionReusableView()
@property (weak,nonatomic) UIView *bgview;
@end

@implementation CPContractDetailCell5CollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgview = [[UIView alloc] init];
//        bgview.layer.borderColor = [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0].CGColor;
//        bgview.layer.borderWidth = 0.5;
//        bgview.backgroundColor = [UIColor whiteColor];
//        bgview.layer.cornerRadius = 2.0;
        [self addSubview:bgview];
        self.bgview = bgview;
        _bgview.translatesAutoresizingMaskIntoConstraints = NO;
        

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bgview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgview)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bgview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgview)]];
    }
    return self;
}

@end
