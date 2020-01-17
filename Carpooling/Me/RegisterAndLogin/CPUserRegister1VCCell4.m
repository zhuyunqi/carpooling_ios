//
//  CPUserRegister1VCCell4.m
//  Carpooling
//
//  Created by bw on 2019/8/6.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserRegister1VCCell4.h"

@implementation CPUserRegister1VCCell4

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.emailTipLbl.text = kLocalizedTableString(@"Email code tip", @"CPLocalizable");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
