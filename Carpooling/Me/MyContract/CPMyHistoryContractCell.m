//
//  CPMyHistoryContractCell.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyHistoryContractCell.h"
#import "CPContractMJModel.h"
#import "CPUserInfoModel.h"
#import "CPAddressModel.h"

#import "UILabel+YBAttributeTextTapAction.h"


@implementation CPMyHistoryContractCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.leadingConstraint.constant = 30;
    
    _commentBtn.backgroundColor = RGBA(120, 202, 195, 1);
    _commentBtn.layer.cornerRadius = _commentBtn.frame.size.height/2;
    _commentBtn.layer.masksToBounds = YES;
    [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commentBtn setTitle:kLocalizedTableString(@"Comment Now", @"CPLocalizable") forState:UIControlStateNormal];
    
    _otherAvatar.layer.cornerRadius = _otherAvatar.frame.size.height/2;
    _otherAvatar.layer.masksToBounds = YES;
    
    _detailMarkLbl.text = kLocalizedTableString(@"Detail", @"CPLocalizable");
    _startMarkLbl.text = kLocalizedTableString(@"Start Address", @"CPLocalizable");
    _endMarkLbl.text = kLocalizedTableString(@"End Address", @"CPLocalizable");
    _timeMarkLbl.text = kLocalizedTableString(@"Schedule Time", @"CPLocalizable");
    
    _statusLbl.font = [UIFont systemFontOfSize:8];
    _statusLbl.textColor = [UIColor whiteColor];
    _statusLbl.numberOfLines = 0;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}


- (void)setContractModel:(CPContractMJModel *)contractModel{
    if (_contractModel != contractModel) {
        _contractModel = contractModel;
        
        NSString *otherAvatarStr = @"";
        
        _titleLbl.text = contractModel.subject;
        
        _startLbl.text = contractModel.fromAddressVo.address;
        _endLbl.text = contractModel.toAddressVo.address;
        
        [_startLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _startLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(historyContractCellNaviAction:location:destination:)]) {
                CLLocationCoordinate2D coord = (CLLocationCoordinate2D){contractModel.fromAddressVo.latitude, contractModel.fromAddressVo.longitude};
                [self.delegate historyContractCellNaviAction:self.indexPath location:coord destination:contractModel.fromAddressVo.address];
            }
        }];
        
        
        [_endLbl yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(0, _endLbl.text.length))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(historyContractCellNaviAction:location:destination:)]) {
                CLLocationCoordinate2D coord = (CLLocationCoordinate2D){contractModel.toAddressVo.latitude, contractModel.toAddressVo.longitude};
                [self.delegate historyContractCellNaviAction:self.indexPath location:coord destination:contractModel.toAddressVo.address];
            }
        }];
        
        
        NSString *time = [NSString stringWithFormat:@"%@~%@", contractModel.beginTime, contractModel.endTime];
        _timeLbl.text = time;
        //        _phoneLbl.text = contractModel.
        if (contractModel.contractType == 0) {
            _contractTypeLbl.text = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
        }
        else if (contractModel.contractType == 1) {
            _contractTypeLbl.text = kLocalizedTableString(@"Longterm Contract", @"CPLocalizable");
        }
        
        NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
        NSLog(@"account:%@, contractModel.cjUserVo.username:%@", account, contractModel.cjUserVo.username);
        if ([account isEqualToString:contractModel.cjUserVo.username]) {
            if (contractModel.userType == 0) {
                _driverIcon.image = [UIImage imageNamed:@"passenger"];
            }
            else {
                _driverIcon.image = [UIImage imageNamed:@"driver"];
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
            
            if (contractModel.evaluateRemark) {
                _commentBtn.enabled = NO;
                _commentBtn.backgroundColor = RGBA(220, 220, 220, 1);
            }
            else {
                _commentBtn.enabled = YES;
                _commentBtn.backgroundColor = RGBA(120, 202, 195, 1);
            }
            
        }
        else {
            if (contractModel.userType == 0) {
                _driverIcon.image = [UIImage imageNamed:@"driver"];
            }
            else {
                _driverIcon.image = [UIImage imageNamed:@"passenger"];
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
            
            if (contractModel.qyEvaluateRemark) {
                _commentBtn.enabled = NO;
                _commentBtn.backgroundColor = RGBA(220, 220, 220, 1);
            }
            else {
                _commentBtn.enabled = YES;
                _commentBtn.backgroundColor = RGBA(120, 202, 195, 1);
            }
        }
        
        [_otherAvatar sd_setImageWithURL:[NSURL URLWithString:otherAvatarStr] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        
        // NSParagraphStyle
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 0.9;
        NSDictionary *attrDict1 = @{ NSParagraphStyleAttributeName: paraStyle,
                                      NSVerticalGlyphFormAttributeName: @(1),
                                      NSFontAttributeName: [UIFont systemFontOfSize: 9] };
        if (contractModel.status == 2) {// canceled
            _statusIcon.image = [UIImage imageNamed:@"result_of_contract_grey"];
            _statusLbl.attributedText = [[NSAttributedString alloc] initWithString: kLocalizedTableString(@"status canceled", @"CPLocalizable") attributes: attrDict1];
        }
        else if (contractModel.status == 3) {// completed
            _statusIcon.image = [UIImage imageNamed:@"result_of_contract_green"];
            _statusLbl.attributedText = [[NSAttributedString alloc] initWithString: kLocalizedTableString(@"status complete", @"CPLocalizable") attributes: attrDict1];
        }
//        NSInteger count = str.length;
//        for (int i = 1; i < count; i ++) {
//            [str insertString:@"\n" atIndex:i*2-1];
//        }
//        _statusLbl.text = str;
        
    }
}

- (IBAction)detailAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyContractCellDetailAction:)]) {
        [self.delegate historyContractCellDetailAction:_indexPath];
    }
}
- (IBAction)chatAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyContractCellChatAction:)]) {
        [self.delegate historyContractCellChatAction:_indexPath];
    }
}
- (IBAction)phoneAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyContractCellPhoneCallAction:)]) {
        [self.delegate historyContractCellPhoneCallAction:_indexPath];
    }
}

- (IBAction)commentAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyContractCellCommentAction:)]) {
        [self.delegate historyContractCellCommentAction:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
