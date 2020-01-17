//
//  CPChangePwdCell2.m
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPChangePwdCell2.h"

@implementation CPChangePwdCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _confirmBtn.layer.cornerRadius = _confirmBtn.frame.size.height/2;
    _confirmBtn.layer.masksToBounds = YES;
    [_confirmBtn setTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") forState:UIControlStateNormal];
}
- (IBAction)confirmAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changePwdCell2BtnAction)]) {
        [self.delegate changePwdCell2BtnAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
