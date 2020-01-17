//
//  GoodsCollectionCell.m
//  BanTang
//
//  Created by liaoyp on 15/4/13.
//  Copyright (c) 2015年 JiuZhouYunDong. All rights reserved.
//

#import "HorzonItemCell.h"
#import "CPContractMJModel.h"
#import "CPScheduleMJModel.h"
#import "CPAddressModel.h"
#import "UILabel+YBAttributeTextTapAction.h"

#import "CPUserInfoModel.h"
@interface HorzonItemCell ()
@property (nonatomic, strong) NSMutableArray *weekArray;
@end

@implementation HorzonItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    _bgView.layer.borderWidth = 1;
    _bgView.layer.cornerRadius = 10;
    _bgView.layer.masksToBounds = YES;
    
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
        _fromLbl.textColor = dyColor3;
        _toLbl.textColor = dyColor3;
        
    } else {
        // Fallback on earlier versions
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.borderColor = RGBA(243, 244, 246, 1).CGColor;
        _timeLbl.textColor = [UIColor darkGrayColor];
        _fromLbl.textColor = [UIColor darkGrayColor];
        _toLbl.textColor = [UIColor darkGrayColor];
    }
    
    
    
    _matchingBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _matchingBtn.layer.cornerRadius = _matchingBtn.frame.size.height/2;
    _matchingBtn.layer.masksToBounds = YES;
    [_matchingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_matchingBtn setTitle:kLocalizedTableString(@"Matching", @"CPLocalizable") forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.weekArray = @[
    kLocalizedTableString(@"SundayLong", @"CPLocalizable"),             kLocalizedTableString(@"MondayLong", @"CPLocalizable"), kLocalizedTableString(@"TuesdayLong", @"CPLocalizable"), kLocalizedTableString(@"WednesdayLong", @"CPLocalizable"), kLocalizedTableString(@"ThursdayLong", @"CPLocalizable"),
    kLocalizedTableString(@"FridayLong", @"CPLocalizable"),
    kLocalizedTableString(@"SaturdayLong", @"CPLocalizable")].mutableCopy;
}


- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification{
    if (_contractModel) {
        // compareNowAndBeginDate
        if (_contractModel.status == 1) {
            if (_contractModel.ridingStatus == 0) {
                //
                NSComparisonResult result = [self compareNowAndBeginDate];
                if (result == NSOrderedDescending || result == NSOrderedSame) {
                    
                    [self setupOngoingStatusByModel:_contractModel];
                }
                
            }
            else if (_contractModel.ridingStatus == 1) {
                [self setupOngoingStatusByModel:_contractModel];
                
            }
            else if (_contractModel.ridingStatus == 2) {
                
                if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserID]) {
                    long long userId = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserID] longLongValue];
                    
                    if (userId != _contractModel.userId) {
                        [self setupOngoingStatusByModel:_contractModel];
                    }
                    else{
                        [self finishOngoingStatusByModel:_contractModel];
                    }
                }
                
            }
            else if (_contractModel.ridingStatus == 3) {
                if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserID]) {
                    long long userId = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserID] longLongValue];
                    
                    if (userId != _contractModel.qyUserId) {
                        [self setupOngoingStatusByModel:_contractModel];
                    }
                    else{
                        [self finishOngoingStatusByModel:_contractModel];
                    }
                }
                
            }
            else {
                [self finishOngoingStatusByModel:_contractModel];
            }
            
        }
        else {
            [self finishOngoingStatusByModel:_contractModel];
        }
        
        
        
        
        //  compareNowAndEndDate
        if (_contractModel.status == 1) {

            if (_contractModel.ridingStatus == 0 || _contractModel.ridingStatus == 1) {
                NSComparisonResult result2 = [self compareNowAndEndDate];
                if (result2 == NSOrderedDescending || result2 == NSOrderedSame) {
                    NSLog(@"result2:%ld", (long)result2);
                    
                    NSString *tips = @"";
                    if (_contractModel.ridingStatus == 0) {
                        tips = kLocalizedTableString(@"not yet Confirm oncar tips", @"CPLocalizable");
                    }
                    else if (_contractModel.ridingStatus == 1) {
                        tips = kLocalizedTableString(@"not yet Confirm arrive tips", @"CPLocalizable");
                    }
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Tips", @"CPLocalizable") message:tips preferredStyle:UIAlertControllerStyleAlert];
                    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor darkGrayColor];
            }
            else {
                return [UIColor colorWithRed:133./256. green:205./256. blue:243./256. alpha:1.0];
            }
        }];
        
        alertController.view.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        alertController.view.tintColor = [UIColor darkGrayColor];
    }
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }];
                    
                    [alertController addAction:okAction];
                    
                    [[Utils getSupreViewController:self] presentViewController:alertController animated:YES completion:^{
                        
                    }];
                }
            }
        }
    }
}


- (void)setContractModel:(CPContractMJModel *)contractModel{

    _contractModel = contractModel;
    
    _titleLbl.text = [NSString stringWithFormat:@"%@", _contractModel.subject];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(245, 245, 245, 1);
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        _bgView.layer.borderColor = dyColor.CGColor;

        
    } else {
        // Fallback on earlier versions
        _bgView.layer.borderColor = RGBA(245, 245, 245, 1).CGColor;
    }
    
    
    if (contractModel.contractType == 1) {
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
    else{
        
        NSDate *date1 = [Utils stringToDate:_contractModel.beginTime withDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *beginTime = [Utils dateToString:date1 withDateFormat:@"MM/dd EEE HH:mm"];
        NSDate *date2 = [Utils stringToDate:_contractModel.endTime withDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *endTime = [Utils dateToString:date2 withDateFormat:@"MM/dd EEE HH:mm"];
        NSString *time = [NSString stringWithFormat:@"%@~%@", beginTime, endTime];
        _timeLbl.text = time;
    }
    
    // compareNowAndBeginDate
    if (_contractModel.status == 1) {
        if (_contractModel.ridingStatus == 0) {
            //
            NSComparisonResult result = [self compareNowAndBeginDate];
            if (result == NSOrderedDescending || result == NSOrderedSame) {
                
                [self setupOngoingStatusByModel:contractModel];
            }
            
        }
        else if (_contractModel.ridingStatus == 1) {
            [self setupOngoingStatusByModel:contractModel];
            
        }
        else if (_contractModel.ridingStatus == 2) {
            
            if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserID]) {
                long long userId = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserID] longLongValue];
                
                if (userId != contractModel.userId) {
                    [self setupOngoingStatusByModel:contractModel];
                }
                else{
                    [self finishOngoingStatusByModel:contractModel];
                }
            }
        
        }
        else if (_contractModel.ridingStatus == 3) {
            if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserID]) {
                long long userId = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserID] longLongValue];
                
                if (userId != contractModel.qyUserId) {
                    [self setupOngoingStatusByModel:contractModel];
                }
                else{
                    [self finishOngoingStatusByModel:contractModel];
                }
            }
            
        }
        else {
            [self finishOngoingStatusByModel:contractModel];
        }
        
        
    }
    else {
        [self finishOngoingStatusByModel:contractModel];
    }

    
    // compareNowAndEndDate
    if (_contractModel.status == 1) {
        
        if (_contractModel.ridingStatus == 0 || _contractModel.ridingStatus == 1) {
            NSComparisonResult result2 = [self compareNowAndEndDate];
            if (result2 == NSOrderedDescending || result2 == NSOrderedSame) {
                NSLog(@"result2:%ld", (long)result2);
                
                NSString *tips = @"";
                if (_contractModel.ridingStatus == 0) {
                    tips = kLocalizedTableString(@"not yet Confirm oncar tips", @"CPLocalizable");
                }
                else if (_contractModel.ridingStatus == 1) {
                    tips = kLocalizedTableString(@"not yet Confirm arrive tips", @"CPLocalizable");
                }
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Tips", @"CPLocalizable") message:tips preferredStyle:UIAlertControllerStyleAlert];
                if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor darkGrayColor];
            }
            else {
                return [UIColor colorWithRed:133./256. green:205./256. blue:243./256. alpha:1.0];
            }
        }];
        
        alertController.view.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        alertController.view.tintColor = [UIColor darkGrayColor];
    }
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                
                [alertController addAction:okAction];
                
                [[Utils getSupreViewController:self] presentViewController:alertController animated:YES completion:^{
                    
                }];
            }
        }
    }
    
    
    _fromLbl.text = contractModel.fromAddressVo.address;
    _toLbl.text = contractModel.toAddressVo.address;
    
    
    [_fromLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _fromLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(horizonItemCellNaviAction:location:destination:)]) {
            CLLocationCoordinate2D coord = (CLLocationCoordinate2D){contractModel.fromAddressVo.latitude, contractModel.fromAddressVo.longitude};
            [self.delegate horizonItemCellNaviAction:self.indexPath location:coord destination:contractModel.fromAddressVo.address];
        }
    }];
    
    
    [_toLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _toLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(horizonItemCellNaviAction:location:destination:)]) {
            CLLocationCoordinate2D coord = (CLLocationCoordinate2D){contractModel.toAddressVo.latitude, contractModel.toAddressVo.longitude};
            [self.delegate horizonItemCellNaviAction:self.indexPath location:coord destination:contractModel.toAddressVo.address];
        }
    }];
}

- (void)setScheduleModel:(CPScheduleMJModel *)scheduleModel{
    if (_scheduleModel != scheduleModel) {
        _scheduleModel = scheduleModel;
        
        NSDate *date = [Utils getDateWithTimestamp:scheduleModel.arriveTime];
        NSString *time = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
        if (scheduleModel.schedulingCycle && scheduleModel.schedulingCycle.length > 0) {
            _timeLbl.text = [NSString stringWithFormat:@"%@ %@(%@)", time, kLocalizedTableString(@"repeat", @"CPLocalizable"), scheduleModel.schedulingCycle];
        }
        else {
            _timeLbl.text = time;
        }
        
        
        _titleLbl.text = scheduleModel.subject;
        
        _fromLbl.text = scheduleModel.fromAddressVo.address;
        _toLbl.text = scheduleModel.toAddressVo.address;
        
        
        [_fromLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _fromLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(horizonItemCellNaviAction:location:destination:)]) {
                CLLocationCoordinate2D coord = (CLLocationCoordinate2D){scheduleModel.fromAddressVo.latitude, scheduleModel.fromAddressVo.longitude};
                [self.delegate horizonItemCellNaviAction:self.indexPath location:coord destination:scheduleModel.fromAddressVo.address];
            }
        }];
        
        
        [_toLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _toLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(horizonItemCellNaviAction:location:destination:)]) {
                CLLocationCoordinate2D coord = (CLLocationCoordinate2D){scheduleModel.toAddressVo.latitude, scheduleModel.toAddressVo.longitude};
                [self.delegate horizonItemCellNaviAction:self.indexPath location:coord destination:scheduleModel.toAddressVo.address];
            }
        }];
    }
}
- (IBAction)matchingAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(horizonItemCellMatchingByIndexPath:)]) {
        [self.delegate horizonItemCellMatchingByIndexPath:_indexPath];
    }
}

#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}

// !!!: setupOngoingStatusByModel
- (void)setupOngoingStatusByModel:(CPContractMJModel*)model{
    _titleLbl.text = [NSString stringWithFormat:@"%@ (%@)", model.subject, kLocalizedTableString(@"Ongoing tab", @"CPLocalizable")];
    _bgView.layer.borderColor = RGBA(235, 83, 119, 1).CGColor;
    
    [_bgView.layer removeAnimationForKey:[NSString stringWithFormat:@"redborderblink%lu", (unsigned long)model.dataid]];
    
    [_bgView.layer addAnimation:[self opacityForever_Animation:1.0] forKey:[NSString stringWithFormat:@"redborderblink%lu", (unsigned long)model.dataid]];
}

// !!!: finishOngoingStatusByModel
- (void)finishOngoingStatusByModel:(CPContractMJModel*)model{
    [_bgView.layer removeAnimationForKey:[NSString stringWithFormat:@"redborderblink%ld", (unsigned long)model.dataid]];
    _titleLbl.text = model.subject;
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(245, 245, 245, 1);
            }
            else {
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        _bgView.layer.borderColor = dyColor.CGColor;

        
    } else {
        // Fallback on earlier versions
        _bgView.layer.borderColor = RGBA(245, 245, 245, 1).CGColor;
    }
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


#pragma mark - compareNowAndEndDate
// !!!: compareNowAndEndDate
- (NSComparisonResult)compareNowAndEndDate{
    NSDate *today = [NSDate date];
    
    if (self.contractModel.contractType == 0) {
        NSComparisonResult result;
        // end time after 24 hour
        NSDate *endDate = [Utils stringToDate:self.contractModel.endTime withDateFormat:@"yyyy-MM-dd HH:mm"];
        
        endDate = [endDate dateByAddingTimeInterval:24*60*60];
        
        return result = [today compare:endDate];
        
    }
    else {
        NSComparisonResult result = -3;

        NSCalendar *calendar = [NSCalendar currentCalendar];

        NSDate *today = [NSDate date];
        NSDateComponents *dateComps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute
                                                   fromDate:today];
        NSInteger todayWeekDay = [dateComps2 weekday];
    
        
        NSArray *weekNumArr = [self.contractModel.weekNum componentsSeparatedByString:@","];
        for (int i = 0; i < weekNumArr.count; i++) {
            NSInteger notifyWeekday = [[weekNumArr objectAtIndex:i] integerValue];

            NSInteger theNotifyWeekday = notifyWeekday +1;
            if (theNotifyWeekday == 8) {
                theNotifyWeekday = 1;
            }
            
            if (todayWeekDay == theNotifyWeekday) {
                
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
