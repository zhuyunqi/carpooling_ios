//
//  CPSettingCell2.m
//  Carpooling
//
//  Created by Yang on 2019/6/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSettingCell2.h"

@implementation CPSettingCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _confirmBtn.backgroundColor = RGBA(240, 72, 117, 1);
    _confirmBtn.layer.cornerRadius = _confirmBtn.frame.size.height/2;
    _confirmBtn.layer.masksToBounds = YES;
}
- (IBAction)confirmAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingCell2ConfirmAction)]) {
        [self.delegate settingCell2ConfirmAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
