//
//  CPContractDetailCell6.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailCell6.h"
#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"

@implementation CPContractDetailCell6

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _onCarBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _onCarBtn.layer.cornerRadius = _onCarBtn.frame.size.height/2;
    _onCarBtn.layer.masksToBounds = YES;
    [_onCarBtn setTitle:kLocalizedTableString(@"Confirm On Car", @"CPLocalizable") forState:UIControlStateNormal];
    
    _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _arriveBtn.layer.cornerRadius = _arriveBtn.frame.size.height/2;
    _arriveBtn.layer.masksToBounds = YES;
    [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
    
    
    _cancelBtn.backgroundColor = RGBA(240, 72, 117, 1);
    _cancelBtn.layer.cornerRadius = _cancelBtn.frame.size.height/2;
    _cancelBtn.layer.masksToBounds = YES;
    
    [_cancelBtn setTitle:kLocalizedTableString(@"Cancel Contract", @"CPLocalizable") forState:UIControlStateNormal];
    
}
- (IBAction)cancelBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractDetailCell6CancelBtnAction)]) {
        [self.delegate contractDetailCell6CancelBtnAction];
    }
}
- (IBAction)onCarBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractDetailCell6OnCarBtnAction)]) {
        [self.delegate contractDetailCell6OnCarBtnAction];
    }
}
- (IBAction)arriveBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contractDetailCell6ArriveBtnAction)]) {
        [self.delegate contractDetailCell6ArriveBtnAction];
    }
}


- (void)setContractModel:(CPContractMJModel *)contractModel{
    _contractModel = contractModel;
    
    NSComparisonResult result = [self compareNowAndBeginDate];
    
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    if ([account isEqualToString:contractModel.cjUserVo.username]) {
        if (contractModel.userType == 0) {
            _onCarBtn.enabled = NO;
            _onCarBtn.backgroundColor = RGBA(220, 220, 220, 1);
        }
        else {
            _onCarBtn.enabled = YES;
            _onCarBtn.backgroundColor = RGBA(120, 202, 195, 1);
        }
        
    }
    else {
        if (contractModel.userType == 0) {
            _onCarBtn.enabled = YES;
            _onCarBtn.backgroundColor = RGBA(120, 202, 195, 1);
            
        }
        else {
            _onCarBtn.enabled = NO;
            _onCarBtn.backgroundColor = RGBA(220, 220, 220, 1);
        }
    }

    
    // 合约状态 status 0:新建状态 1:接受合约，未进行 2:合约取消 3:合约结束(完成) 4:合约进行中 5:合约进行中(仅做为长期合约下车)
    //乘车状态  ridingStatus 1:上车   2:创建者确认已到达  3:签约者确认已到达  4:下车，到达
    if (contractModel.ridingStatus == 0) {
        _arriveBtn.enabled = NO;
        _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
        
        if (result == NSOrderedAscending) {
            _cancelBtn.enabled = YES;
            _cancelBtn.backgroundColor = RGBA(240, 72, 117, 1);
        }
        else {
            _cancelBtn.enabled = NO;
            _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
        }
        
    }
    else if (contractModel.ridingStatus == 1) {
        _cancelBtn.enabled = NO;
        _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
        _onCarBtn.enabled = NO;
        _onCarBtn.backgroundColor = RGBA(220, 220, 220, 1);
        
        _arriveBtn.enabled = YES;
        _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);

    }
    else if (contractModel.ridingStatus == 2 || contractModel.ridingStatus == 3) {
        _cancelBtn.enabled = NO;
        _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
        
        _onCarBtn.enabled = NO;
        _onCarBtn.backgroundColor = RGBA(220, 220, 220, 1);
        
        _arriveBtn.enabled = YES;
        _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
        

        if ([account isEqualToString:contractModel.cjUserVo.username]) {
            if (contractModel.ridingStatus == 2) {
                _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
                _arriveBtn.enabled = NO;
                [_arriveBtn setTitle:kLocalizedTableString(@"Already Arrive", @"CPLocalizable") forState:UIControlStateNormal];
                
            }
            else if (contractModel.ridingStatus == 3) {
                _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
                _arriveBtn.enabled = YES;
                [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
            }
            
        }
        else {
            if (contractModel.ridingStatus == 2) {
                _arriveBtn.backgroundColor = RGBA(120, 202, 195, 1);
                _arriveBtn.enabled = YES;
                [_arriveBtn setTitle:kLocalizedTableString(@"Confirm Arrive", @"CPLocalizable") forState:UIControlStateNormal];
                
            }
            else if (contractModel.ridingStatus == 3) {
                _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
                _arriveBtn.enabled = NO;
                [_arriveBtn setTitle:kLocalizedTableString(@"Already Arrive", @"CPLocalizable") forState:UIControlStateNormal];
            }
        }
        
    }
    else if (contractModel.ridingStatus == 4) {
        _cancelBtn.enabled = NO;
        _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
        
        _onCarBtn.enabled = NO;
        _onCarBtn.backgroundColor = RGBA(220, 220, 220, 1);

        _arriveBtn.enabled = NO;
        _arriveBtn.backgroundColor = RGBA(220, 220, 220, 1);
        [_arriveBtn setTitle:kLocalizedTableString(@"Already Arrive", @"CPLocalizable") forState:UIControlStateNormal];
        
        
        // long term contract
        if (contractModel.contractType == 1) {
            if (contractModel.status != 3) { // not finish

                if ([account isEqualToString:contractModel.cjUserVo.username]) {
                    
                    if (contractModel.userType == 1) {
                        NSComparisonResult result = [self compareNowAndBeginDate];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            
                            _onCarBtn.hidden = NO;
                            _onCarBtn.enabled = YES;
                            _onCarBtn.backgroundColor = RGBA(120, 202, 195, 1);
                            
                        }
                    }
                    
                }
                else {
                    
                    if (contractModel.userType == 0) {
                        NSComparisonResult result = [self compareNowAndBeginDate];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            
                            _onCarBtn.hidden = NO;
                            _onCarBtn.enabled = YES;
                            _onCarBtn.backgroundColor = RGBA(120, 202, 195, 1);
                        }
                    }
                }
                
            }
        }
    }
    
    // 
    if (contractModel.status == 2) {
        _onCarBtn.hidden = NO;
        _onCarBtn.enabled = NO;
        _onCarBtn.backgroundColor = RGBA(220, 220, 220, 1);
        
        [_cancelBtn setTitle:kLocalizedTableString(@"Cancel Contract", @"CPLocalizable") forState:UIControlStateNormal];
        _cancelBtn.enabled = NO;
        _cancelBtn.backgroundColor = RGBA(220, 220, 220, 1);
    }
}


#pragma mark - compareNowAndBeginDate
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
