//
//  CPMyInProgressContractCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyInProgressContractCell1.h"
#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"
#import "MZTimerLabel.h"
#import "CPAddressModel.h"

#import "UILabel+YBAttributeTextTapAction.h"

@interface CPMyInProgressContractCell1 ()
@property (nonatomic, strong) NSMutableArray *weekArray;
@end

@implementation CPMyInProgressContractCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _cancelBtn.backgroundColor = RGBA(240, 72, 117, 1);
    _cancelBtn.layer.cornerRadius = _cancelBtn.frame.size.height/2;
    _cancelBtn.layer.masksToBounds = YES;
    
    _otherAvatar.layer.cornerRadius = _otherAvatar.frame.size.height/2;
    _otherAvatar.layer.masksToBounds = YES;
    
    _onCarBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _onCarBtn.layer.cornerRadius = _onCarBtn.frame.size.height/2;
    _onCarBtn.layer.masksToBounds = YES;
    
    _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
    [_arriveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _arriveBtn.layer.cornerRadius = _arriveBtn.frame.size.height/2;
    _arriveBtn.layer.masksToBounds = YES;
    
    
    _inProgressDescLbl.hidden = YES;
    _inProgressTimeLbl.hidden = YES;
    
    _currentLocationIcon.hidden = YES;
    _locationMarkLbl.hidden = YES;
    _currentLocationBtn.hidden = YES;
    
    _arriveBtn.hidden = YES;

    _detailMarkLbl.text = kLocalizedTableString(@"Detail", @"CPLocalizable");
    _startMarkLbl.text = kLocalizedTableString(@"Start Address", @"CPLocalizable");
    _endMarkLbl.text = kLocalizedTableString(@"End Address", @"CPLocalizable");
    _timeMarkLbl.text = kLocalizedTableString(@"Schedule Time", @"CPLocalizable");
    _inProgressDescLbl.text = kLocalizedTableString(@"Ongoing time", @"CPLocalizable");
    _locationMarkLbl.text = kLocalizedTableString(@"Check current location", @"CPLocalizable");
    
    
    [_cancelBtn setTitle:kLocalizedTableString(@"Cancel Contract", @"CPLocalizable") forState:UIControlStateNormal];
    [_onCarBtn setTitle:kLocalizedTableString(@"Confirm On Car", @"CPLocalizable") forState:UIControlStateNormal];
    [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
    
    self.weekArray = @[
    kLocalizedTableString(@"SundayLong", @"CPLocalizable"),             kLocalizedTableString(@"MondayLong", @"CPLocalizable"), kLocalizedTableString(@"TuesdayLong", @"CPLocalizable"), kLocalizedTableString(@"WednesdayLong", @"CPLocalizable"), kLocalizedTableString(@"ThursdayLong", @"CPLocalizable"),
    kLocalizedTableString(@"FridayLong", @"CPLocalizable"),
    kLocalizedTableString(@"SaturdayLong", @"CPLocalizable")].mutableCopy;
}


- (void)dealloc{
    NSLog(@"CPMyInProgressContractCell1 dealloc");
}


- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}


- (IBAction)detailAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1DetailAction:)]) {
        [self.delegate contractCell1DetailAction:_indexPath];
    }
}

- (IBAction)cancelAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1CancelAction:)]) {
        [self.delegate contractCell1CancelAction:_indexPath];
    }
}
- (IBAction)onCarAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1OnCarAction:)]) {
        [self.delegate contractCell1OnCarAction:_indexPath];
    }
}

- (IBAction)phoneCallAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1PhoneCallAction:)]) {
        [self.delegate contractCell1PhoneCallAction:_indexPath];
    }
}

- (IBAction)chatAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1ChatAction:)]) {
        [self.delegate contractCell1ChatAction:_indexPath];
    }
}

- (IBAction)currentLocationAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1LocationAction:)]) {
        [self.delegate contractCell1LocationAction:_indexPath];
    }
}

- (IBAction)arriveAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1ArriveAction:)]) {
        [self.delegate contractCell1ArriveAction:_indexPath];
    }
}



- (void)setContractModel:(CPContractMJModel *)contractModel{
    
    _contractModel = contractModel;
    
    NSComparisonResult result = [self compareNowAndBeginDate];
    
    NSString *otherAvatarStr = @"";
    
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    NSLog(@"account:%@, contractModel.cjUserVo.username:%@", account, contractModel.cjUserVo.username);
    if ([account isEqualToString:contractModel.cjUserVo.username]) {
        
        if (contractModel.userType == 0) {
            _driverIcon.image = [UIImage imageNamed:@"passenger"];
            _onCarBtn.hidden = YES;
        }
        else {
            _driverIcon.image = [UIImage imageNamed:@"driver"];
            _onCarBtn.hidden = NO;
        }
        
        if (contractModel.qyUserVo.mobile) {
            _phoneLbl.text = contractModel.qyUserVo.mobile;
        }
        else{
            _phoneLbl.hidden = YES;
        }
        
        if (contractModel.qyUserVo.nickname) {
            _nameLbl.text = contractModel.qyUserVo.nickname;
        }
        else {
            _nameLbl.text = @"";
        }
        
        otherAvatarStr = contractModel.qyUserVo.avatar;
        
        
    }
    else {
        
        if (contractModel.userType == 0) {
            _driverIcon.image = [UIImage imageNamed:@"driver"];
            _onCarBtn.hidden = NO;
        }
        else {
            _driverIcon.image = [UIImage imageNamed:@"passenger"];
            _onCarBtn.hidden = YES;
        }
        
        if (contractModel.cjUserVo.mobile) {
            _phoneLbl.text = contractModel.cjUserVo.mobile;
        }
        else{
            _phoneLbl.hidden = YES;
        }
        
        if (contractModel.cjUserVo.nickname) {
            _nameLbl.text = contractModel.cjUserVo.nickname;
        }
        else {
            _nameLbl.text = @"";
        }
        
        otherAvatarStr = contractModel.cjUserVo.avatar;
    }
    
    
    [_otherAvatar sd_setImageWithURL:[NSURL URLWithString:otherAvatarStr] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
    
    _titleLbl.text = contractModel.subject;
    
    _startLbl.text = contractModel.fromAddressVo.address;
    _endLbl.text = contractModel.toAddressVo.address;
    
    [_startLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _startLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1NaviAction:location:destination:)]) {
            CLLocationCoordinate2D coord = (CLLocationCoordinate2D){contractModel.fromAddressVo.latitude, contractModel.fromAddressVo.longitude};
            [self.delegate contractCell1NaviAction:self.indexPath location:coord destination:contractModel.fromAddressVo.address];
        }
    }];
    
    
    [_endLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _endLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(contractCell1NaviAction:location:destination:)]) {
            CLLocationCoordinate2D coord = (CLLocationCoordinate2D){contractModel.toAddressVo.latitude, contractModel.toAddressVo.longitude};
            [self.delegate contractCell1NaviAction:self.indexPath location:coord destination:contractModel.toAddressVo.address];
        }
    }];
    
    
    
    if (contractModel.contractType == 0) {// 短期合约
        NSDate *date1 = [Utils stringToDate:contractModel.beginTime withDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *beginTime = [Utils dateToString:date1 withDateFormat:@"MM/dd EEE HH:mm"];
        NSDate *date2 = [Utils stringToDate:contractModel.endTime withDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *endTime = [Utils dateToString:date2 withDateFormat:@"MM/dd EEE HH:mm"];
        
        NSString *time = [NSString stringWithFormat:@"%@~%@", beginTime, endTime];
        _timeLbl.text = time;
    }
    else if (contractModel.contractType == 1) {// 长期合约
        NSString *time = @"";
        if (_contractModel.weekNum && _contractModel.weekNum.length > 0) {
            NSString *str = @"";
            NSArray *arr2 = [_contractModel.weekNum componentsSeparatedByString:@","];
            for (int j = 0; j < arr2.count; j++) {
                NSInteger weeknumI = [[arr2 objectAtIndex:j] integerValue];
                
                NSString *weekStr = [_weekArray objectAtIndex:weeknumI-1];
                if (j == 0) {
                    str = weekStr;
                }
                else {
                    str = [NSString stringWithFormat:@"%@,%@", str, weekStr];
                }
            }
            
            NSLog(@"HorzonItemCell setContractModel str:%@", str);
            
            time = [NSString stringWithFormat:@"%@ %@~%@", str, _contractModel.beginTime, _contractModel.endTime];
            
        }
        else {
            time = [NSString stringWithFormat:@"%@~%@", _contractModel.beginTime, _contractModel.endTime];
        }
        
        _timeLbl.text = time;
    }
    

    if (contractModel.contractType == 0) {
        _contractTypeLbl.text = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
    }
    else if (contractModel.contractType == 1) {
        _contractTypeLbl.text = kLocalizedTableString(@"Longterm Contract", @"CPLocalizable");
    }
    
    // 合约状态 status 0:新建状态 1:接受合约，未进行 2:合约取消 3:合约结束(完成)
    //乘车状态  ridingStatus 1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达
    if (contractModel.ridingStatus == 0) {
        _inProgressDescLbl.hidden = YES;
        _inProgressTimeLbl.hidden = YES;
        
        _cancelBtn.hidden = NO;

        if (result == NSOrderedAscending || result == NSOrderedSame) {
            _cancelBtn.enabled = YES;
            _cancelBtn.backgroundColor = RGBA(240, 72, 117, 1);
        }
        else {
            _cancelBtn.enabled = NO;
            _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
        }
        
        _arriveBtn.hidden = YES;
        
    }
    else if (contractModel.ridingStatus == 1) {
        _inProgressDescLbl.hidden = NO;
        _inProgressDescLbl.text = kLocalizedTableString(@"Ongoing time", @"CPLocalizable");
        _inProgressDescLbl.textColor = RGBA(120, 202, 195, 1);
        
        
        NSTimeInterval elapseSec = ([Utils getCurrentTimestampMillisecond] - contractModel.onCarTimestamp)/1000;// 毫秒转秒
        [_inProgressTimeLbl setShouldCountBeyondHHLimit:YES];
        [_inProgressTimeLbl setStopWatchTime:elapseSec];
        [_inProgressTimeLbl start];
        _inProgressTimeLbl.hidden = NO;

        
        _cancelBtn.hidden = YES;
        _onCarBtn.hidden = YES;
        _arriveBtn.hidden = NO;
        
        _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
        _arriveBtn.enabled = YES;
        [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
        
        _locationMarkLbl.hidden = NO;
        _locationMarkLbl.text = kLocalizedTableString(@"Check current location", @"CPLocalizable");
        _locationMarkLbl.textColor = RGBA(120, 202, 195, 1);
        
        
        _currentLocationBtn.hidden = NO;
        _currentLocationIcon.hidden = NO;
    }
    else if (contractModel.ridingStatus == 2 || contractModel.ridingStatus == 3) {
//        [_inProgressTimeLbl removeFromSuperview];
        [_inProgressTimeLbl invalidTimerIfExist];
        
        _inProgressDescLbl.textColor = RGBA(240, 72, 117, 1);
        _inProgressDescLbl.hidden = NO;
        
        
        _cancelBtn.hidden = YES;
        _onCarBtn.hidden = YES;
        _arriveBtn.hidden = NO;
        _currentLocationBtn.hidden = YES;
        _currentLocationIcon.hidden = YES;
        
        if (contractModel.confirmArriveTimestamp) {
            _locationMarkLbl.hidden = NO;
            _locationMarkLbl.textColor = [UIColor blackColor];
            NSInteger elapseSec = (contractModel.confirmArriveTimestamp - contractModel.onCarTimestamp)/1000;// 毫秒转秒
            NSInteger hour = elapseSec / 3600;
            NSInteger min = (elapseSec / 60) % 60;
            NSInteger scd = elapseSec % 60;
            NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)scd];
            _locationMarkLbl.text = [NSString stringWithFormat:@"%@ %@", kLocalizedTableString(@"Time length", @"CPLocalizable"), timeStr];
        }
        
        
        if (contractModel.oneSideHasConfirmArrive) {
            _arriveBtn.hidden = NO;
            _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
            _arriveBtn.enabled = NO;
            _inProgressDescLbl.textColor = RGBA(120, 202, 195, 1);
            _inProgressDescLbl.text = kLocalizedTableString(@"Already Arrive", @"CPLocalizable");
        }
        else if ([account isEqualToString:contractModel.cjUserVo.username]) {
            if (contractModel.ridingStatus == 2) {
                _arriveBtn.hidden = NO;
                _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
                _arriveBtn.enabled = NO;
                [_arriveBtn setTitle:kLocalizedTableString(@"Already Arrive", @"CPLocalizable") forState:UIControlStateNormal];
                
                _inProgressDescLbl.textColor = RGBA(240, 72, 117, 1);
                _inProgressDescLbl.text = kLocalizedTableString(@"Arrive Waiting Check", @"CPLocalizable");
            }
            else if (contractModel.ridingStatus == 3) {
                _arriveBtn.hidden = NO;
                _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
                _arriveBtn.enabled = YES;
                [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
                
                _inProgressDescLbl.textColor = RGBA(120, 202, 195, 1);
                _inProgressDescLbl.text = kLocalizedTableString(@"Other Already Arrive", @"CPLocalizable");
            }
            
        }
        else {
            if (contractModel.ridingStatus == 2) {
                _arriveBtn.hidden = NO;
                _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
                _arriveBtn.enabled = YES;
                [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
                
                _inProgressDescLbl.textColor = RGBA(120, 202, 195, 1);
                _inProgressDescLbl.text = kLocalizedTableString(@"Other Already Arrive", @"CPLocalizable");
                
            }
            else if (contractModel.ridingStatus == 3) {
                _arriveBtn.hidden = NO;
                _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
                _arriveBtn.enabled = NO;
                [_arriveBtn setTitle:kLocalizedTableString(@"Already Arrive", @"CPLocalizable") forState:UIControlStateNormal];
                
                _inProgressDescLbl.textColor = RGBA(240, 72, 117, 1);
                _inProgressDescLbl.text = kLocalizedTableString(@"Arrive Waiting Check", @"CPLocalizable");
            }
        }
        
    }
    else if (contractModel.ridingStatus == 4) {
//        [_inProgressTimeLbl removeFromSuperview];
        [_inProgressTimeLbl invalidTimerIfExist];
        
        _inProgressDescLbl.textColor = RGBA(120, 202, 195, 1);
        _inProgressDescLbl.text = kLocalizedTableString(@"Already Arrive", @"CPLocalizable");
        _inProgressDescLbl.hidden = NO;
        
        
        _cancelBtn.hidden = YES;
        _onCarBtn.hidden = YES;
        _currentLocationBtn.hidden = YES;
        _currentLocationIcon.hidden = YES;
        
        if (contractModel.confirmArriveTimestamp) {
            _locationMarkLbl.hidden = NO;
            _locationMarkLbl.textColor = [UIColor blackColor];
            NSInteger elapseSec = (contractModel.confirmArriveTimestamp - contractModel.onCarTimestamp)/1000;// 毫秒转秒
            NSInteger hour = elapseSec / 3600;
            NSInteger min = (elapseSec / 60) % 60;
            NSInteger scd = elapseSec % 60;
            NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)scd];
            _locationMarkLbl.text = [NSString stringWithFormat:@"%@ %@", kLocalizedTableString(@"Time length", @"CPLocalizable"), timeStr];
        }
        
        _arriveBtn.hidden = NO;
        _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
        _arriveBtn.enabled = NO;
        [_arriveBtn setTitle:kLocalizedTableString(@"Already Arrive", @"CPLocalizable") forState:UIControlStateNormal];
        
        
        // long term contract
        if (contractModel.contractType == 1) {
            if (contractModel.status != 3) { // not finish
                
                _cancelBtn.hidden = NO;
                _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
                _cancelBtn.enabled = NO;
                
                
                _inProgressDescLbl.hidden = YES;
                _locationMarkLbl.hidden = YES;
                _locationMarkLbl.text = kLocalizedTableString(@"Check current location", @"CPLocalizable");
                _locationMarkLbl.textColor = RGBA(120, 202, 195, 1);
                
                //
                _currentLocationIcon.hidden = NO;
                _currentLocationBtn.hidden = NO;
                
                if ([account isEqualToString:contractModel.cjUserVo.username]) {
                    
                    if (contractModel.userType == 1) {
                        NSComparisonResult result = [self compareNowAndBeginDate];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            _onCarBtn.hidden = NO;
                        }
                    }
                    
                }
                else {
                    
                    if (contractModel.userType == 0) {
                        NSComparisonResult result = [self compareNowAndBeginDate];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            _onCarBtn.hidden = NO;
                        }
                    }
                }
                
            }
        }
    }

    
    if (contractModel.status == 1) {
        if (contractModel.ridingStatus == 2 || contractModel.ridingStatus == 3 || contractModel.ridingStatus == 4) {
            if (contractModel.contractType != 1) {
                _currentLocationIcon.hidden = YES;
                _currentLocationBtn.hidden = YES;
            }
            else {
                _locationMarkLbl.hidden = NO;
            }
            
        }
        else {
            _currentLocationIcon.hidden = NO;
            _currentLocationBtn.hidden = NO;
            _locationMarkLbl.hidden = NO;
            _locationMarkLbl.text = kLocalizedTableString(@"Check current location", @"CPLocalizable");
        }
        
    }
    else if (contractModel.status == 2) {
        _inProgressTimeLbl.hidden = YES;
        _inProgressDescLbl.hidden = YES;
        
        _locationMarkLbl.hidden = YES;
        
        _cancelBtn.hidden = NO;
        _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
        _cancelBtn.enabled = NO;
        [_cancelBtn setTitle:kLocalizedTableString(@"Has Canceled", @"CPLocalizable") forState:UIControlStateNormal];
        
        _onCarBtn.hidden = YES;
        
        _currentLocationIcon.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - compareNowAndBeginDate
// !!!: compareNowAndBeginDate
- (NSComparisonResult)compareNowAndBeginDate{
    NSComparisonResult result;
    
    if (self.contractModel.contractType == 0) {
        NSDate *date = [NSDate date];
        
        NSDate *beginDate = [Utils stringToDate:self.contractModel.beginTime withDateFormat:@"yyyy-MM-dd HH:mm"];
        
        return result = [date compare:beginDate];
        
        
    }
    else {
        NSComparisonResult result = -3;
        //
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDate *today = [NSDate date];
        NSDateComponents *dateComps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                                   fromDate:today];
        NSInteger todayWeekDay = [dateComps2 weekday];
        
        
        NSArray *weekNumArr = [self.contractModel.weekNum componentsSeparatedByString:@","];
        for (int i = 0; i < weekNumArr.count; i++) {
            NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];
            
            if (todayWeekDay == notifyWeekday) {
                
                NSString *theDayStr = [Utils dateToString:today withDateFormat:@"yyyy-MM-dd"];
                NSDate *theDate = [Utils stringToDate:[NSString stringWithFormat:@"%@ %@", theDayStr, self.contractModel.beginTime] withDateFormat:@"yyyy-MM-dd HH:mm"];
                
                result = [today compare:theDate];
                
                break;
            }
        }
        
        return result;
    }
}

@end
