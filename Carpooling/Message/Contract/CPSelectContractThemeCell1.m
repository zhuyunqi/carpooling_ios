//
//  CPSelectContractThemeCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/2.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSelectContractThemeCell1.h"

@implementation CPSelectContractThemeCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleTF.layer.cornerRadius = 10;
    _titleTF.layer.masksToBounds = YES;
    
    _titleTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    _titleTF.leftViewMode = UITextFieldViewModeAlways;
    _titleTF.returnKeyType = UIReturnKeyDone;
    
    [_titleTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(245, 245, 245, 1);
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        _titleTF.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        _titleTF.backgroundColor = RGBA(245, 245, 245, 1);
    }
}

- (void)textFieldChanged:(UITextField*)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectContractThemeCell1TFDidEndEditing:)]) {
        [self.delegate selectContractThemeCell1TFDidEndEditing:textField.text];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectContractThemeCell1TFShouldReturn:)]) {
            [self.delegate selectContractThemeCell1TFShouldReturn:textField.text];
        }
        return YES;
    }
    return NO;
}

@end
