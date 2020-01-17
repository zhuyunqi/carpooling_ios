//
//  CPUserRegister1VCCell3.m
//  Carpooling
//
//  Created by Yang on 2019/6/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserRegister1VCCell3.h"

@implementation CPUserRegister1VCCell3

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLbl.text = kLocalizedTableString(@"Country/Region", @"CPLocalizable");
    _arrow.image = [UIImage imageNamed:@"arrowrightwhite"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
