//
//  CPHomeFirstOpenCell.m
//  Carpooling
//
//  Created by Yang on 2019/6/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeFirstOpenCell.h"

@implementation CPHomeFirstOpenCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLbl.textColor = RGBA(252, 80, 0, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
