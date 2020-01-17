//
//  CPSetupActivityCell2.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSetupActivityCell2.h"
@interface CPSetupActivityCell2()<UITextViewDelegate>

@end

@implementation CPSetupActivityCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _descTV.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(245, 245, 245, 1);
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        _descTV.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        _descTV.backgroundColor = RGBA(245, 245, 245, 1);
    }
}

- (void)setRemark:(NSString *)remark{
    if (_remark != remark) {
        _remark = remark;
        
        _descTV.text = remark;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView == self.descTV) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(setupActivityCell2TVDidEditing:)]) {
            [self.delegate setupActivityCell2TVDidEditing:textView.text];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
