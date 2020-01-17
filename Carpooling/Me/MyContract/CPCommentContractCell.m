//
//  CPCommentContractCell.m
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPCommentContractCell.h"
@interface CPCommentContractCell()<UITextViewDelegate>

@end

@implementation CPCommentContractCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _descTV.delegate = self;
    _descTV.backgroundColor = RGBA(245, 245, 245, 1);
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView == self.descTV) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(commentContractCellTVDidEditing:)]) {
            [self.delegate commentContractCellTVDidEditing:textView.text];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
