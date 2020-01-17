//
//  CPUserRegister1VCCell2.m
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserRegister1VCCell2.h"
#import "BWGetVerifyCodeButton.h"
@interface CPUserRegister1VCCell2 () <UITextFieldDelegate>
@end

@implementation CPUserRegister1VCCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _TFBgView.layer.shadowColor = [UIColor whiteColor].CGColor;
    _TFBgView.layer.shadowOffset = CGSizeMake(0, 3);
    _TFBgView.layer.shadowOpacity = 0.4;
    _TFBgView.layer.shadowRadius = 10;
    _TFBgView.layer.cornerRadius = 10;
    _TFBgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.8];
    
    
    _textTF.backgroundColor = [UIColor clearColor];
    _textTF.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 0)];
    _textTF.rightViewMode = UITextFieldViewModeAlways;
    _textTF.font = [UIFont systemFontOfSize:17.f];
    _textTF.tintColor = RGBA(51, 51, 51, 1);
    _textTF.textColor = RGBA(51, 51, 51, 1);
    
    _textTF.delegate = self;
    
    [_textTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    _getVerifyCodeBtn.layer.cornerRadius = 8;
    _getVerifyCodeBtn.layer.masksToBounds = YES;
    _getVerifyCodeBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _getVerifyCodeBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [_getVerifyCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getVerifyCodeBtn setTitle:kLocalizedTableString(@"Get Verification code", @"CPLocalizable") forState:UIControlStateNormal];
    
    
    _confirmBtn.layer.shadowColor = [UIColor whiteColor].CGColor;
    _confirmBtn.layer.shadowOffset = CGSizeMake(0, 2);
    _confirmBtn.layer.shadowOpacity = 0.4;
    _confirmBtn.layer.shadowRadius = 10;
    _confirmBtn.layer.cornerRadius = 10;
    _confirmBtn.backgroundColor = RGBA(120, 202, 195, 0.9);
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)textFieldChanged:(UITextField*)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userRegister1VCCell2TFText:)]) {
        [self.delegate userRegister1VCCell2TFText:textField.text];
    }
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (self.textTF.text.length >= 8) {
//        return NO;
//    }
//    return YES;
//}

- (IBAction)getVerifyCodeAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userRegister1VCCell2GetVerifyAction)]) {
        [self.delegate userRegister1VCCell2GetVerifyAction];
    }
}

- (void)setStartCount:(BOOL)startCount{
    if (_startCount != startCount) {
        _startCount = startCount;
        if (_startCount) {
            [_getVerifyCodeBtn countDownWithSeconds:60];
        }
    }
}

- (IBAction)confirmAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userRegister1VCCell2ConfirmAction)]) {
        [self.delegate userRegister1VCCell2ConfirmAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
