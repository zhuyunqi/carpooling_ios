//
//  CPBindingPhoneCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBindingPhoneCell1.h"
#import "BWGetVerifyCodeButton.h"

@implementation CPBindingPhoneCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLbl.text = kLocalizedTableString(@"Country/Region", @"CPLocalizable");
    
    _countingLbl.hidden = YES;
    
    _getCodeBtn.layer.cornerRadius = 8;
    _getCodeBtn.layer.masksToBounds = YES;
    _getCodeBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getCodeBtn setTitle:kLocalizedTableString(@"Get Verification code", @"CPLocalizable") forState:UIControlStateNormal];
    
    
    _confirmBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _confirmBtn.layer.cornerRadius = _confirmBtn.frame.size.height/2;
    _confirmBtn.layer.masksToBounds = YES;
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_phoneTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    _phoneTF.font = [UIFont systemFontOfSize:15.f];
    _phoneTF.tag = 10000;
    [_veriCodeTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    _veriCodeTF.font = [UIFont systemFontOfSize:15.f];
    _veriCodeTF.tag = 10001;
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        self.backgroundColor = dyColor;
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(243, 244, 246, 1);
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        _line1.backgroundColor = dyColor2;
        _line2.backgroundColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor whiteColor];
        _line1.backgroundColor = RGBA(243, 244, 246, 1);
        _line2.backgroundColor = RGBA(243, 244, 246, 1);
    }
}

- (void)textFieldChanged:(UITextField*)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bindingPhoneCell1TFTextField:)]) {
        [self.delegate bindingPhoneCell1TFTextField:textField];
    }
}
- (IBAction)goNationCodeVCAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bindingPhoneCell1GoNationCodeVCAction)]) {
        [self.delegate bindingPhoneCell1GoNationCodeVCAction];
    }
}


- (IBAction)getVerifyCodeAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bindingPhoneCell1GetVerifyAction)]) {
        [self.delegate bindingPhoneCell1GetVerifyAction];
    }
}

- (IBAction)confirmAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bindingPhoneCell1ConfirmAction)]) {
        [self.delegate bindingPhoneCell1ConfirmAction];
    }
}

- (void)setStartCount:(BOOL)startCount{
    if (_startCount != startCount) {
        _startCount = startCount;
        if (_startCount) {
            [_getCodeBtn countDownWithSeconds:60];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
