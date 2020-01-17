//
//  CPActivityDetailCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPActivityDetailCell1.h"
#import "CPActivityMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

@implementation CPActivityDetailCell1

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
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        _textTV.backgroundColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor whiteColor];
        _textTV.backgroundColor = [UIColor whiteColor];
    }
    
    // image width/height 590/240 2.45
    _activityImageView.contentMode = UIViewContentModeScaleAspectFill;
    _countLbl.textColor = RGBA(150, 150, 150, 1);
    
    _icon.image = [UIImage imageNamed:@"activity_location"];
    
    _view1.layer.cornerRadius = _view1.frame.size.width/2;
    _view1.layer.masksToBounds = true;
    _img1.layer.cornerRadius = _img1.frame.size.width/2;
    _img1.layer.masksToBounds = true;
    
    _view2.layer.cornerRadius = _view2.frame.size.width/2;
    _view2.layer.masksToBounds = true;
    _img2.layer.cornerRadius = _img2.frame.size.width/2;
    _img2.layer.masksToBounds = true;
    
    _view3.layer.cornerRadius = _view3.frame.size.width/2;
    _view3.layer.masksToBounds = true;
    _img3.layer.cornerRadius = _img3.frame.size.width/2;
    _img3.layer.masksToBounds = true;
    
    _textTV.editable = false;
}

- (void)setActivityModel:(CPActivityMJModel *)activityModel{

    _activityModel = activityModel;
    
    // 三个报名者头像
    for (int i = 0; i < activityModel.enrollList.count; i++) {
        NSDictionary *dict = [activityModel.enrollList objectAtIndex:i];
        NSString *avatar = [dict valueForKey:@"avatar"];
        if (nil == avatar || [avatar isKindOfClass:[NSNull class]]) {
            avatar = @"";
        }
        if (i == 0) {
            [_img3 sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        }
        else if (i == 1) {
            [_img2 sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        }
        else if (i == 2) {
            [_img1 sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        }
    }
    
    _titleLbl.text = activityModel.name;
    NSDate *date = [Utils getDateWithTimestamp:activityModel.date];
    NSString *dateStr = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
    _timeLbl.text = dateStr;
    
    if (activityModel.imgUrl.length > 0) {
        _activityImageView.hidden = NO;
        _activityImgConstraint.constant = (kSCREENWIDTH-30)/2.45;
        // image width/height 590/240 2.45
        [_activityImageView sd_setImageWithURL:[NSURL URLWithString:activityModel.imgUrl] placeholderImage:[UIImage imageNamed:@""]];
    }
    else {
        _activityImgConstraint.constant = 0;
        _activityImageView.hidden = YES;
    }
    
    NSString *str1 = kLocalizedTableString(@"Applicants", @"CPLocalizable");
    NSString *str2 = [NSString stringWithFormat:@"%lu", (unsigned long)activityModel.userCount];
    NSString *str3 = kLocalizedTableString(@"Enroll person", @"CPLocalizable");
    NSString *str4 = [NSString stringWithFormat:@"%@%@%@", str1, str2, str3];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str4];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.f],
                             NSForegroundColorAttributeName:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]} range:NSMakeRange(str1.length, str2.length)];
    _countLbl.attributedText = attrStr;
    
    
    _addressLbl.text = activityModel.addressVo.address;
    _textTV.text = activityModel.describe;
}

- (IBAction)checkMemberAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(activityDetailCell1CheckMember:)]) {
        [self.delegate activityDetailCell1CheckMember:sender];
    }
}
- (IBAction)naviBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(activityDetailCell1NaviAction)]) {
        [self.delegate activityDetailCell1NaviAction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
