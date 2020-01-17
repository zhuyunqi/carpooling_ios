//
//  CPHomeCell2.m
//  Carpooling
//
//  Created by bw on 2019/5/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeCell2.h"
#import "CPActivityMJModel.h"
#import "CPAddressModel.h"

@implementation CPHomeCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        _bgView.backgroundColor = dyColor;
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(243, 244, 246, 1);
            }
            else {
                return [UIColor tertiaryLabelColor];
            }
        }];
        _bgView.layer.borderColor = dyColor2.CGColor;
        
        UIColor *dyColor3 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor darkGrayColor];
            }
            else {
                return [UIColor secondaryLabelColor];
            }
        }];
        _timeLbl.textColor = dyColor3;
        _addressLbl.textColor = dyColor3;
        
    } else {
        // Fallback on earlier versions
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.borderColor = RGBA(243, 244, 246, 1).CGColor;
        _timeLbl.textColor = [UIColor darkGrayColor];
    }
    
    
    // image width/height 590/240 2.45
    _bgView.layer.borderWidth = 1;
    _bgView.layer.cornerRadius = 10;
    _bgView.layer.masksToBounds = YES;
    
    _activityImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}

- (void)setActivityModel:(CPActivityMJModel *)activityModel{
//    if (_activityModel != activityModel) {
    _activityModel = activityModel;
    
    _editBtn.hidden = YES;
    _editIcon.hidden = YES;
    
    // me 0;  Home activity list 1;  HotActivity 2;  allactivity 3;
    if (self.showType == 0) {
        if (activityModel.isEdit) {
            _editBtn.hidden = NO;
            _editIcon.hidden = NO;
        }
    }
    else if (self.showType == 1) {
        if (activityModel.isEdit) {
            _editBtn.hidden = NO;
            _editIcon.hidden = NO;
        }
    }
    else if (self.showType == 2) {
        if (activityModel.isEdit) {
            _editBtn.hidden = NO;
            _editIcon.hidden = NO;
        }
    }
    else if (self.showType == 3) {
        if (activityModel.isEdit) {
            _editBtn.hidden = NO;
            _editIcon.hidden = NO;
        }
    }
    
    _likeLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)activityModel.collect];
    
    _titleLbl.text = activityModel.name;
    NSDate *date = [Utils getDateWithTimestamp:activityModel.date];
    NSString *dateStr = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
    
    _timeLbl.text = dateStr;
    
    if (activityModel.isEnrollCurUser) {
        _titleIcon.hidden = NO;
    }
    else {
        _titleIcon.hidden = YES;
    }
    
    if (self.showType == 0) {
        self.bgViewTopConstraint.constant = 15;
    }
    else {
        self.bgViewTopConstraint.constant = 15;
    }
    
    if (activityModel.imgUrl.length > 0) {
        _activityImageView.hidden = NO;
        _activityImgConstraint.constant = (kSCREENWIDTH-30)/2.45;
        // image width/height 590/240 2.45
        [_activityImageView sd_setImageWithURL:[NSURL URLWithString:activityModel.imgUrl] placeholderImage:[UIImage imageNamed:@"图片加载占位"]];
    }
    else {
        _activityImgConstraint.constant = 0;
        _activityImageView.hidden = YES;
    }
    
    _addressLbl.text = activityModel.addressVo.address;
//    }
}
- (IBAction)likeAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeCell2LikeAction:)]) {
        [self.delegate homeCell2LikeAction:self.indexPath];
    }
}
- (IBAction)naviBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeCell2NaviAction:location:destination:)]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.activityModel.addressVo.latitude, self.activityModel.addressVo.longitude);
        [self.delegate homeCell2NaviAction:self.indexPath location:coordinate destination:self.activityModel.addressVo.address];
    }
}
- (IBAction)editBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeCell2EditAction:)]) {
        [self.delegate homeCell2EditAction:self.indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
