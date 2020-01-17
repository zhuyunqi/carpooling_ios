//
//  CPHomeNoDataCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/13.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeNoDataCell1.h"

@implementation CPHomeNoDataCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLbl.textColor = RGBA(150, 150, 150, 1);
}

- (void)setTipsType:(NSInteger)tipsType{
    if (_tipsType != tipsType) {
        _tipsType = tipsType;
        
        if (tipsType == 1) {
            _titleLbl.text = kLocalizedTableString(@"My Contract Empty", @"CPLocalizable");
        }
        else if (tipsType == 2) {
            _titleLbl.text = kLocalizedTableString(@"My Schedule Empty", @"CPLocalizable");
        }
        else if (tipsType == 3) {
            _titleLbl.text = kLocalizedTableString(@"My Activity Empty", @"CPLocalizable");
        }
    }
}
- (void)setTips:(NSString *)tips{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
