//
//  CPHomeHeaderCell.m
//  Carpooling
//
//  Created by bw on 2019/5/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeHeaderCell.h"

@implementation CPHomeHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lineLbl.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
