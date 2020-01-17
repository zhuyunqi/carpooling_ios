//
//  CPSelectContractThemeCell2.m
//  Carpooling
//
//  Created by Yang on 2019/6/2.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSelectContractThemeCell2.h"
@interface CPSelectContractThemeCell2()<UITextViewDelegate>

@end

@implementation CPSelectContractThemeCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleTV.backgroundColor = RGBA(245, 245, 245, 1);
    _titleTV.layer.cornerRadius = 10;
    _titleTV.layer.masksToBounds = YES;
    _titleTV.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8);
    
    _titleTV.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView == self.titleTV) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectContractThemeCell2TVDidEndEditing:)]) {
            [self.delegate selectContractThemeCell2TVDidEndEditing:textView.text];
        }
    }
}

@end
