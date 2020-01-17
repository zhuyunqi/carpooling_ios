//
//  CPContractDetailCell5CollectionViewCell.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailCell5CollectionViewCell.h"

@implementation CPContractDetailCell5CollectionViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 20; // height 为40
}

- (void)setCustomSelect:(BOOL)customSelect{
    _customSelect = customSelect;
    
    if (_customSelect) {
        self.layer.borderColor = RGBA(120, 202, 195, 1).CGColor;
        self.textLbl.textColor = RGBA(120, 202, 195, 1);
    }
    else {
        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor blackColor];
                }
                else {
                    return [UIColor labelColor];
                }
            }];
            
            self.textLbl.textColor = dyColor;
            
        } else {
            // Fallback on earlier versions
            self.textLbl.textColor = [UIColor blackColor];
        }
        
    }
}

@end
