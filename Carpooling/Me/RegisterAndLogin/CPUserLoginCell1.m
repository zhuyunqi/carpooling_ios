//
//  CPUserLoginCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserLoginCell1.h"

@implementation CPUserLoginCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_registerBtn setTitle:kLocalizedTableString(@"Register Account", @"CPLocalizable") forState:UIControlStateNormal];
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    
    [_forgotPwdBtn setTitle:kLocalizedTableString(@"Forgot Password", @"CPLocalizable") forState:UIControlStateNormal];
    [_forgotPwdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _forgotPwdBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    
    _titleLbl.text = kLocalizedTableString(@"Other Registration", @"CPLocalizable");
    _titleLbl.textColor = [UIColor whiteColor];
    _descLbl.text = @"facebook";
    _descLbl.textColor = [UIColor whiteColor];

}
- (IBAction)rigisterBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userLoginCell1RegisterBtnAction)]) {
        [self.delegate userLoginCell1RegisterBtnAction];
    }
}
- (IBAction)forgotPwdBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userLoginCell1ForgotPwdBtnAction)]) {
        [self.delegate userLoginCell1ForgotPwdBtnAction];
    }
}
- (IBAction)thirdPartyLoginAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userLoginCell1ThirdPartyLoginBtnAction)]) {
        [self.delegate userLoginCell1ThirdPartyLoginBtnAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
