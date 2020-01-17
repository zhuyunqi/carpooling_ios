//
//  CPUserRegister1VCCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserRegister1VCCell1.h"
@interface CPUserRegister1VCCell1 () <UITextFieldDelegate>
@end

@implementation CPUserRegister1VCCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _TFBgView.layer.shadowColor = [UIColor whiteColor].CGColor;
    _TFBgView.layer.shadowOffset = CGSizeMake(0, 1);
    _TFBgView.layer.shadowOpacity = 0.4;
    _TFBgView.layer.shadowRadius = 10;
    _TFBgView.layer.cornerRadius = 10;
    _TFBgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.8];
    
    _nationCodeLbl.textColor = RGBA(51, 51, 51, 1);
    
    _textTF.backgroundColor = [UIColor clearColor];
    _textTF.font = [UIFont systemFontOfSize:17.f];
    _textTF.tintColor = RGBA(51, 51, 51, 1);
    _textTF.textColor = RGBA(51, 51, 51, 1);
    
    _textTF.delegate = self;
    
    [_textTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldChanged:(UITextField*)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userRegister1VCCell1TFText:)]) {
        [self.delegate userRegister1VCCell1TFText:textField.text];
    }
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (self.textTF.text.length >= 8) {
//        return NO;
//    }
//    return YES;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
