//
//  CPSetupActivityCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSetupActivityCell1.h"

@implementation CPSetupActivityCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // image width/height 590/240 2.45
    _activityImageView.contentMode = UIViewContentModeScaleAspectFill;
    _descLbl.textColor = [UIColor lightGrayColor];
    _descLbl.font = [UIFont systemFontOfSize:14.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
