//
//  CPActivityMembersCell.m
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPActivityMembersCell.h"
#import "CPUserInfoModel.h"

@implementation CPActivityMembersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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

- (void)setEnrollMember:(CPUserInfoModel *)enrollMember{
    if (_enrollMember != enrollMember) {
        _enrollMember = enrollMember;
        
        [_avatar sd_setImageWithURL:[NSURL URLWithString:enrollMember.avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        
        if (enrollMember.nickname) {
            _titleLbl.text = enrollMember.nickname;
        }
        else {
            _titleLbl.text = enrollMember.username;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
