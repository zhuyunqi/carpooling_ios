//
//  CPCommentContractDetailCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPCommentContractDetailCell1.h"

@implementation CPCommentContractDetailCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLbl.text = kLocalizedTableString(@"Comment Info", @"CPLocalizable");
    _mineTitleLbl.text = kLocalizedTableString(@"Driver Comment", @"CPLocalizable");
    _otherTitleLbl.text = kLocalizedTableString(@"Passenger Comment", @"CPLocalizable");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
