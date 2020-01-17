//
//  CPSchedulePeriodCell1.m
//  Carpooling
//
//  Created by bw on 2019/9/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSchedulePeriodCell1.h"

@implementation CPSchedulePeriodCell1

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
    
    _customSelected = NO;
    _icon.image = [UIImage imageNamed:@"comment_state2"];
}

- (void)setCustomSelected:(BOOL)customSelected{
    _customSelected = customSelected;
    if (_customSelected) {
        self.icon.image = [UIImage imageNamed:@"comment_state1"];
    }
    else{
        self.icon.image = [UIImage imageNamed:@"comment_state2"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
