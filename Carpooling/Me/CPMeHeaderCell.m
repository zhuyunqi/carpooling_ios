//
//  CPMeHeaderCell.m
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMeHeaderCell.h"
#import "CPMeTopArcView.h"

@implementation CPMeHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = RGBA(120, 202, 195, 1);
    
    _bgImageView.hidden = YES;
    
    CPMeTopArcView *arcView = [[CPMeTopArcView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-30, kSCREENWIDTH, 30)];
    [self.contentView addSubview:arcView];
    
    
    _avatar.layer.cornerRadius = _avatar.frame.size.width/2;
    _nameLbl.textColor = [UIColor whiteColor];
    _accountLbl.textColor = [UIColor whiteColor];
    _editIcon.image = [UIImage imageNamed:@"edit"];
    
    [_signInBtn setTitle:kLocalizedTableString(@"Go Login", @"CPLocalizable") forState:UIControlStateNormal];
    [_signInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(230, 230, 230, 1);
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        self.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = RGBA(230, 230, 230, 1);
    }
}


- (IBAction)signInAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(meHeaderCellSignInAction)]) {
        [self.delegate meHeaderCellSignInAction];
    }
}
- (IBAction)editAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(meHeaderCellEditAction)]) {
        [self.delegate meHeaderCellEditAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
