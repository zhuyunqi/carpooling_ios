//
//  CPInitShortTermContractCell3.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPInitShortTermContractCell3.h"

@implementation CPInitShortTermContractCell3

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        self.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
