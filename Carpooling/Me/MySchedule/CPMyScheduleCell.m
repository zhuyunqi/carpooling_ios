//
//  CPMyScheduleCell.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyScheduleCell.h"
#import "CPScheduleMJModel.h"
#import "CPAddressModel.h"

#import "UILabel+YBAttributeTextTapAction.h"

@implementation CPMyScheduleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor3 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor darkGrayColor];
            }
            else {
                return [UIColor secondaryLabelColor];
            }
        }];
        _timeLbl.textColor = dyColor3;
        _startLbl.textColor = dyColor3;
        _endLbl.textColor = dyColor3;
        
    } else {
        // Fallback on earlier versions
        _timeLbl.textColor = [UIColor darkGrayColor];
        _startLbl.textColor = [UIColor darkGrayColor];
        _endLbl.textColor = [UIColor darkGrayColor];
    }
    
    
    _matchingBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _matchingBtn.layer.cornerRadius = _matchingBtn.frame.size.height/2;
    _matchingBtn.layer.masksToBounds = YES;
    [_matchingBtn setTitle:kLocalizedTableString(@"Go Matching", @"CPLocalizable") forState:UIControlStateNormal];
    
    [_deleteBtn setTitle:kLocalizedTableString(@"Delete", @"CPLocalizable") forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:RGBA(120, 202, 195, 1) forState:UIControlStateNormal];
    
    _startMarkLbl.text = kLocalizedTableString(@"From", @"CPLocalizable");
    _endMarkLbl.text = kLocalizedTableString(@"To", @"CPLocalizable");
    _timeMarkLbl.text = kLocalizedTableString(@"Arrive Time", @"CPLocalizable");
}

- (void)setScheduleMJModel:(CPScheduleMJModel *)scheduleMJModel{
    if (_scheduleMJModel != scheduleMJModel) {
        _scheduleMJModel = scheduleMJModel;
        
        _titleLbl.text = scheduleMJModel.subject;
        
        _startLbl.text = scheduleMJModel.fromAddressVo.address;
        _endLbl.text = scheduleMJModel.toAddressVo.address;
        
        [_startLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _startLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(myScheduleCellNaviAction:location:destination:)]) {
                CLLocationCoordinate2D coord = (CLLocationCoordinate2D){scheduleMJModel.fromAddressVo.latitude, scheduleMJModel.fromAddressVo.longitude};
                [self.delegate myScheduleCellNaviAction:self.indexPath location:coord destination:scheduleMJModel.fromAddressVo.address];
            }
        }];
        
        
        [_endLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _endLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(myScheduleCellNaviAction:location:destination:)]) {
                CLLocationCoordinate2D coord = (CLLocationCoordinate2D){scheduleMJModel.toAddressVo.latitude, scheduleMJModel.toAddressVo.longitude};
                [self.delegate myScheduleCellNaviAction:self.indexPath location:coord destination:scheduleMJModel.toAddressVo.address];
            }
        }];
        
        
        NSDate *date = [Utils getDateWithTimestamp:scheduleMJModel.arriveTime];
        NSString *dateStr = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
        if (scheduleMJModel.schedulingCycle && scheduleMJModel.schedulingCycle.length > 0) {
            _timeLbl.text = [NSString stringWithFormat:@"%@ %@(%@)", dateStr, kLocalizedTableString(@"repeat", @"CPLocalizable"), scheduleMJModel.schedulingCycle];
        }
        else {
            _timeLbl.text = dateStr;
        }
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}

- (IBAction)editAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(myScheduleCellEditBtnAction:)]) {
        [self.delegate myScheduleCellEditBtnAction:_indexPath];
    }
}
- (IBAction)matchingAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(myScheduleCellMatchingBtnAction:)]) {
        [self.delegate myScheduleCellMatchingBtnAction:_indexPath];
    }
}
- (IBAction)deleteAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(myScheduleCellDeleteBtnAction:)]) {
        [self.delegate myScheduleCellDeleteBtnAction:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
