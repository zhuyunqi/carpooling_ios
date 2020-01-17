//
//  CPSettingCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSettingCell1.h"

@implementation CPSettingCell1

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
