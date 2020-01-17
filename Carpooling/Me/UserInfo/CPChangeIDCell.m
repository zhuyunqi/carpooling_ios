//
//  CPChangeIDCell.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPChangeIDCell.h"

@implementation CPChangeIDCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleTF.layer.cornerRadius = 10;
    _titleTF.layer.masksToBounds = YES;
    
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
                return RGBA(245, 245, 245, 1);
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        _titleTF.backgroundColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor whiteColor];
    }
    
    _titleTF.placeholder = kLocalizedTableString(@"Enter Nickname", @"CPLocalizable");
    
    _titleTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    _titleTF.leftViewMode = UITextFieldViewModeAlways;
    _titleTF.returnKeyType = UIReturnKeyDone;
    [_titleTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldChanged:(UITextField*)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeIDCellTFDidEndEditing:)]) {
        [self.delegate changeIDCellTFDidEndEditing:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeIDCellTFShouldReturn:)]) {
            [self.delegate changeIDCellTFShouldReturn:textField.text];
        }
        return YES;
    }
    return NO;
}

@end
