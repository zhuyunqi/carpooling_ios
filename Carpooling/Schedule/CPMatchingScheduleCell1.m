//
//  CPMatchingScheduleCell1.m
//  Carpooling
//
//  Created by Yang on 2019/6/9.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMatchingScheduleCell1.h"
#import "CPScheduleMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

#import <WFChatClient/WFCCIMService.h>


@implementation CPMatchingScheduleCell1

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
    
    _startLbl.textColor = RGBA(100, 100, 100, 1);
    _endLbl.textColor = RGBA(100, 100, 100, 1);
    _timeMarkLbl.text = kLocalizedTableString(@"Schedule Endtime", @"CPLocalizable");
    _startMarkLbl.text = kLocalizedTableString(@"From", @"CPLocalizable");
    _endMarkLbl.text = kLocalizedTableString(@"To", @"CPLocalizable");
    [_confirmBtn setTitle:kLocalizedTableString(@"Say Hello", @"CPLocalizable") forState:UIControlStateNormal];
    _confirmBtn.backgroundColor = RGBA(253, 228, 71, 1);
    [_confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _confirmBtn.layer.cornerRadius = 10;
    _confirmBtn.layer.masksToBounds = YES;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}

- (void)setMatchingScheduleModel:(CPMatchingScheduleModel *)matchingScheduleModel{
    if (_matchingScheduleModel != matchingScheduleModel) {
        _matchingScheduleModel = matchingScheduleModel;
        
        [_avatar sd_setImageWithURL:[NSURL URLWithString:matchingScheduleModel.userVo.avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        
        if (matchingScheduleModel.userVo.nickname) {
            _titleLbl.text = [NSString stringWithFormat:@"%@ %@", matchingScheduleModel.userVo.nickname, matchingScheduleModel.schedulingCarpoolVo.subject];
        }
        else if (matchingScheduleModel.userVo.username) {
            if ([[WFCCIMService sharedWFCIMService] isMyFriend:matchingScheduleModel.userVo.imUserId]) {
                _titleLbl.text = [NSString stringWithFormat:@"%@ %@", matchingScheduleModel.userVo.username, matchingScheduleModel.schedulingCarpoolVo.subject];
            }
            else {
                _titleLbl.text = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:@"%@...", [matchingScheduleModel.userVo.username substringToIndex:3]], matchingScheduleModel.schedulingCarpoolVo.subject];
            }
        }
        
        _startLbl.text = matchingScheduleModel.schedulingCarpoolVo.fromAddressVo.address;
        _endLbl.text = matchingScheduleModel.schedulingCarpoolVo.toAddressVo.address;
        
        NSDate *date = [Utils getDateWithTimestamp:matchingScheduleModel.schedulingCarpoolVo.arriveTime];
        NSString *dateStr = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
        if (matchingScheduleModel.schedulingCarpoolVo.schedulingCycle && matchingScheduleModel.schedulingCarpoolVo.schedulingCycle.length > 0) {
            _timeLbl.text = [NSString stringWithFormat:@"%@ %@(%@)", dateStr, kLocalizedTableString(@"repeat", @"CPLocalizable"), matchingScheduleModel.schedulingCarpoolVo.schedulingCycle];
        }
        else {
            _timeLbl.text = dateStr;
        }
    }
}

- (IBAction)confirmAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(matchingScheduleCell1BtnAction:)]) {
        [self.delegate matchingScheduleCell1BtnAction:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
