//
//  CPHomeSetScheduleCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeSetScheduleCell1.h"

@implementation CPHomeSetScheduleCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _titleLbl.textColor = RGBA(150, 150, 150, 1);
    
    _subtitleLbl.textColor = RGBA(180, 180, 180, 1);
    _subtitleLbl.font = [UIFont systemFontOfSize:14.f];
    _subtitleLbl.text = @"";
    
    
    [_confirmBtn setTitle:kLocalizedTableString(@"Go Setting", @"CPLocalizable") forState:UIControlStateNormal];
    
    _confirmBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _confirmBtn.layer.cornerRadius = _confirmBtn.frame.size.height/2;
    _confirmBtn.layer.masksToBounds = YES;
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)confirmAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeSetScheduleCell1BtnActionByIndexPath:)]) {
        [self.delegate homeSetScheduleCell1BtnActionByIndexPath:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
