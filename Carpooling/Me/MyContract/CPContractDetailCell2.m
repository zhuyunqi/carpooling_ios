//
//  CPContractDetailCell2.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailCell2.h"

@implementation CPContractDetailCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)phoneAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractDetailCell2PhoneAction)]) {
        [self.delegate contractDetailCell2PhoneAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
