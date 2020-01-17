//
//  CPScheduleCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPScheduleCell1.h"
#import "CPScheduleMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

#import "UILabel+YBAttributeTextTapAction.h"


@implementation CPScheduleCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _ampmLbl.textColor = RGBA(120, 202, 195, 1);
    
    _otherAvatar.layer.cornerRadius = _otherAvatar.frame.size.height/2;
    _otherAvatar.layer.masksToBounds = YES;
    
    _detailMarkLbl.text = kLocalizedTableString(@"Detail", @"CPLocalizable");
    _timeMarkLbl.text = kLocalizedTableString(@"Arrive Time", @"CPLocalizable");
    _startMarkLbl.text = kLocalizedTableString(@"From", @"CPLocalizable");
    _endMarkLbl.text = kLocalizedTableString(@"To", @"CPLocalizable");
}

- (void)setScheduleMJModel:(CPScheduleMJModel *)scheduleMJModel{
    _scheduleMJModel = scheduleMJModel;

    
    NSString *otherAvatarStr = @"";
    
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, contractModel.cjContractUserVo.username:%@", account, scheduleMJModel.cjContractUserVo.username);
    if ([account isEqualToString:scheduleMJModel.cjContractUserVo.username]) {
        
        otherAvatarStr = scheduleMJModel.userVo.avatar;
    }
    else {
        otherAvatarStr = scheduleMJModel.cjContractUserVo.avatar;
    }
    
    [_otherAvatar sd_setImageWithURL:[NSURL URLWithString:otherAvatarStr] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];

    
    _titleLbl.text = scheduleMJModel.subject;

    _startLbl.text = scheduleMJModel.fromAddressVo.address;
    _endLbl.text = scheduleMJModel.toAddressVo.address;
    
    [_startLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _startLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scheduleCell1NaviAction:location:destination:)]) {
            CLLocationCoordinate2D coord = (CLLocationCoordinate2D){scheduleMJModel.fromAddressVo.latitude, scheduleMJModel.fromAddressVo.longitude};
            [self.delegate scheduleCell1NaviAction:self.indexPath location:coord destination:scheduleMJModel.fromAddressVo.address];
        }
    }];
    
    
    [_endLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _endLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scheduleCell1NaviAction:location:destination:)]) {
            CLLocationCoordinate2D coord = (CLLocationCoordinate2D){scheduleMJModel.toAddressVo.latitude, scheduleMJModel.toAddressVo.longitude};
            [self.delegate scheduleCell1NaviAction:self.indexPath location:coord destination:scheduleMJModel.toAddressVo.address];
        }
    }];
    
    
    
    if (scheduleMJModel.cjContractUserVo.mobile) {
        _phoneLbl.text = scheduleMJModel.cjContractUserVo.mobile;
    }
    else{
        _phoneLbl.hidden = YES;
    }
    
    if (scheduleMJModel.cjContractUserVo.nickname) {
        _nameLbl.text = scheduleMJModel.cjContractUserVo.nickname;
    }
    else {
        _nameLbl.text = @"";
    }
    
    if (scheduleMJModel.userType == 0) {
        _driverIcon.image = [UIImage imageNamed:@"passenger"];
    }
    else if (scheduleMJModel.userType == 1) {
        _driverIcon.image = [UIImage imageNamed:@"driver"];
    }


    
    NSDate *date = [Utils getDateWithTimestamp:scheduleMJModel.arriveTime];
    NSString *dateStr = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
    _timeLbl.text = dateStr;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"HH:mm:a"];
    NSString *ampm = [[[formatter stringFromDate:date] componentsSeparatedByString:@":"] objectAtIndex:2];
     _ampmLbl.text = ampm;
    
    if (scheduleMJModel.status == 0) {
        _detailBtn.hidden = YES;
        _msgIcon.hidden = YES;
        _driverIcon.hidden = YES;
        _detailMarkLbl.hidden = YES;
    }
    else if (scheduleMJModel.status == 1) {
        _detailBtn.hidden = YES;
        _msgIcon.hidden = YES;
        _driverIcon.hidden = YES;
        _detailMarkLbl.hidden = YES;
        
        _phoneIcon.hidden = YES;
        _phoneBtn.hidden = YES;
        _phoneLbl.hidden = YES;
        
        _chatBtn.hidden = YES;
        _msgIcon.hidden = YES;
        _otherAvatar.hidden = YES;
    }
    else {
        _detailBtn.hidden = NO;
        _msgIcon.hidden = NO;
        _driverIcon.hidden = NO;
        _detailMarkLbl.hidden = NO;
        
        _phoneIcon.hidden = NO;
        _phoneBtn.hidden = NO;
        _phoneLbl.hidden = NO;
        
        _chatBtn.hidden = NO;
        _msgIcon.hidden = NO;
        _otherAvatar.hidden = NO;
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}

- (IBAction)detailAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scheduleCell1DetailBtnAction:)]) {
        [self.delegate scheduleCell1DetailBtnAction:_indexPath];
    }
}
- (IBAction)chatAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scheduleCell1ChatBtnAction:)]) {
        [self.delegate scheduleCell1ChatBtnAction:_indexPath];
    }
}
- (IBAction)phoneAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scheduleCell1PhoneBtnAction:)]) {
        [self.delegate scheduleCell1PhoneBtnAction:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
