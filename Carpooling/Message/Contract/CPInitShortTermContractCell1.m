//
//  CPInitShortTermContractCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPInitShortTermContractCell1.h"

@implementation CPInitShortTermContractCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _leftLbl.text = kLocalizedTableString(@"Impassenger", @"CPLocalizable");
    _rightLbl.text = kLocalizedTableString(@"Imdriver", @"CPLocalizable");
}

- (IBAction)leftAction:(id)sender {
    _leftBtn.selected = YES;
    _rightBtn.selected = NO;
    _leftImgV.image = [UIImage imageNamed:@"comment_state1"];
    _rightImgV.image = [UIImage imageNamed:@"comment_state2"];
    _passengerType = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCellSelectPassengerType:)]) {
        [self.delegate contractCellSelectPassengerType:_passengerType];
    }
}

- (IBAction)rightAction:(id)sender {
    _leftBtn.selected = NO;
    _rightBtn.selected = YES;
    _leftImgV.image = [UIImage imageNamed:@"comment_state2"];
    _rightImgV.image = [UIImage imageNamed:@"comment_state1"];
    _passengerType = 1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCellSelectPassengerType:)]) {
        [self.delegate contractCellSelectPassengerType:_passengerType];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
