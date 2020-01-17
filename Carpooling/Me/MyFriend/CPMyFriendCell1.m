//
//  CPMyFriendCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyFriendCell1.h"
#import "CPUserInfoModel.h"
#import "CPUserInfoModel.h"

@implementation CPMyFriendCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor whiteColor];
    }
    
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelectIndexPath:(NSIndexPath *)selectIndexPath{
    if (_selectIndexPath != selectIndexPath) {
        _selectIndexPath = selectIndexPath;
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


- (IBAction)setNoteNameAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(myFriendCell1SetNotenameAction:)]) {
        [self.delegate myFriendCell1SetNotenameAction:_selectIndexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
