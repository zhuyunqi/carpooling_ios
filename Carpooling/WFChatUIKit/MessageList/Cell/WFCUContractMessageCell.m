//
//  WFCUContractMessageCell.m
//  Carpooling
//
//  Created by bw on 2019/7/6.
//  Copyright © 2019 bw. All rights reserved.
//

#import "WFCUContractMessageCell.h"
#import "WFCUUtilities.h"

#define TEXT_LABEL_TOP_PADDING 3
#define TEXT_LABEL_BUTTOM_PADDING 5

#define SSChatAirTop            35           //气泡距离详情顶部
#define SSChatAirLRS            10           //气泡左右短距离
#define SSChatAirBottom         10           //气泡距离详情底部
#define SSChatAirLRB            22           //气泡左右长距离

@implementation WFCUContractMessageCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    
    CGFloat height = 0;
    
    WFCCContractMessageContent *content = (WFCCContractMessageContent *)msgModel.message.content;
    CGSize size1 = [WFCUUtilities getTextDrawingSize:content.from font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width-70, 8000)];
    
    CGSize size2 = [WFCUUtilities getTextDrawingSize:content.to font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width-70, 8000)];
    
    CGSize size3 = [WFCUUtilities getTextDrawingSize:content.time font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width-70, 8000)];
    
    CGSize size4 = CGSizeZero;
    if (content.remark.length > 0) {
        size4 = [WFCUUtilities getTextDrawingSize:content.remark font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width-70, 8000)];
    }
    else {
        size4 = CGSizeMake(width-70, 30);
    }
    
    height = size1.height + size2.height + size3.height + size4.height + 4*10 + 40;
    if (msgModel.message.direction == MessageDirection_Send) {
        return CGSizeMake(width, height);
    }
    else if (msgModel.message.direction == MessageDirection_Receive) {
        if (content.status != 0) {
            return CGSizeMake(width, height);
        }
        return CGSizeMake(width, height+50);
    }
    return CGSizeMake(width, height);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCContractMessageContent *content = (WFCCContractMessageContent *)model.message.content;
    
    if (model.message.direction == MessageDirection_Send) {
        self.bubbleView.image = [UIImage imageNamed:@"icon_qipao3"];
        UIEdgeInsets imageInsets = UIEdgeInsetsMake(SSChatAirTop, SSChatAirLRS, SSChatAirBottom, SSChatAirLRB);
        self.bubbleView.image = [self.bubbleView.image
                                 resizableImageWithCapInsets:imageInsets];
        
        self.ignoreButton.hidden = YES;
        self.agreeButton.hidden = YES;
        
    }
    else if (model.message.direction == MessageDirection_Receive) {
        if (content.status != 0) {
            self.ignoreButton.hidden = YES;
            self.agreeButton.hidden = YES;
        }
        else {
            [self.ignoreButton setTitle:kLocalizedTableString(@"Attitude Reject", @"CPLocalizable") forState:UIControlStateNormal];
            [self.agreeButton setTitle:kLocalizedTableString(@"Attitude Agree", @"CPLocalizable") forState:UIControlStateNormal];
            self.ignoreButton.hidden = NO;
            self.agreeButton.hidden = NO;
        }
    }
    
    
    self.titleLbl.width = self.contentArea.width - 30;
    if (content.contractType == 0) {
        _titleLbl.text = kLocalizedTableString(@"Shortterm Contract", @"CPLocalizable");
    }
    else if (content.contractType == 1) {
        _titleLbl.text = kLocalizedTableString(@"Longterm Contract", @"CPLocalizable");
    }
    [_titleLbl sizeToFit];
    _titleLbl.top = 7;
    _titleLbl.left = 10;
    

    self.line.width = self.contentArea.width+15;
    _line.bottom = 40;
    _line.left = -6;
    
    self.bgView.top = _line.bottom;
    _bgView.left = -7;
    _bgView.width = self.contentArea.width+14;
    _bgView.height = self.contentArea.height-37;
    
    
    self.fromTitleLbl.top = _line.bottom+10;
    _fromTitleLbl.width = 40;
    _fromTitleLbl.left = _titleLbl.left;
    _fromTitleLbl.height = 20;
    
    self.fromContentLbl.top = _line.bottom+10;
    _fromContentLbl.width = self.contentArea.width-70;
    _fromContentLbl.left = _fromTitleLbl.right;
    _fromContentLbl.text = content.from;
    [_fromContentLbl sizeToFit];
//    _fromContentLbl.height = layout.fromLblRect.size.height;
    
    
    
    self.toTitleLbl.top = _fromContentLbl.bottom+5;
    _toTitleLbl.width = 40;
    _toTitleLbl.left = _titleLbl.left;
    _toTitleLbl.height = 20;
    
    self.toContentLbl.top = _fromContentLbl.bottom+5;
    _toContentLbl.width = self.contentArea.width-70;
    _toContentLbl.left = _toTitleLbl.right;
    _toContentLbl.text = content.to;
    [_toContentLbl sizeToFit];
//    _toContentLbl.height = layout.toLblRect.size.height;
    
    
    
    
    self.timeTitleLbl.top = _toContentLbl.bottom+5;
    _timeTitleLbl.width = 40;
    _timeTitleLbl.left = _titleLbl.left;
    _timeTitleLbl.height = 20;
    
    self.timeContentLbl.top = _toContentLbl.bottom+5;
    _timeContentLbl.width = self.contentArea.width-70;
    _timeContentLbl.left = _timeTitleLbl.right;
    _timeContentLbl.text = content.time;
    [_timeContentLbl sizeToFit];
//    _timeContentLbl.height = layout.contractTimeLblRect.size.height;
    
    
    
    self.remarkTitleLbl.top = _timeContentLbl.bottom+5;
    _remarkTitleLbl.width = 40;
    _remarkTitleLbl.left = _titleLbl.left;
    _remarkTitleLbl.height = 20;
    
    self.remarkContentLbl.top = _timeContentLbl.bottom+7;
    _remarkContentLbl.width = self.contentArea.width-70;
    _remarkContentLbl.left = _remarkTitleLbl.right;
    _remarkContentLbl.text = content.remark;
    [_remarkContentLbl sizeToFit];
//    _remarkContentLbl.height = layout.remarkLblRect.size.height;
    
    
    if (content.remark.length > 0) {
        _ignoreButton.top = _remarkContentLbl.bottom +15;
        
    }
    else {
        _ignoreButton.top = _remarkTitleLbl.bottom +15;
    }
    
    _ignoreButton.left = _titleLbl.left;
    _agreeButton.top = _ignoreButton.top;
    _agreeButton.right = self.contentArea.width - 15;
}

- (UILabel *)titleLbl{
    if (!_titleLbl) {
        _titleLbl = [UILabel new];
        _titleLbl.bounds = CGRectMake(0, 0, 120, 25);
        _titleLbl.font = [UIFont systemFontOfSize:16];
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.contentArea addSubview:_titleLbl];
    }
    
    return _titleLbl;
}

- (UIView *)line{
    if (!_line) {
        _line = [UIView new];
        _line.bounds = CGRectMake(0, 0, 200, 0.8);
        _line.backgroundColor = [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1];
        [self.contentArea addSubview:_line];
    }
    
    return _line;
}

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.bounds = CGRectMake(0, 0, 200, 100);
        _bgView.backgroundColor = [UIColor colorWithRed:251/255.0f green: 251/255.0f blue:251/255.0f alpha:1];
        [self.contentArea insertSubview:_bgView atIndex:0];
    }
    
    return _bgView;
}

- (UILabel *)fromTitleLbl{
    if (!_fromTitleLbl) {
        _fromTitleLbl = [UILabel new];
        _fromTitleLbl.bounds = CGRectZero;
        _fromTitleLbl.font = [UIFont boldSystemFontOfSize:15.f];
        _fromTitleLbl.textColor = [UIColor blackColor];
        _fromTitleLbl.textAlignment = NSTextAlignmentLeft;
        _fromTitleLbl.text = kLocalizedTableString(@"From", @"CPLocalizable");
        [self.contentArea addSubview:_fromTitleLbl];
    }
    
    return _fromTitleLbl;
}

- (UILabel *)fromContentLbl{
    if (!_fromContentLbl) {
        _fromContentLbl = [UILabel new];
        _fromContentLbl.font = [UIFont systemFontOfSize:14.f];
        _fromContentLbl.textColor = [UIColor darkGrayColor];
        _fromContentLbl.textAlignment = NSTextAlignmentLeft;
        _fromContentLbl.numberOfLines = 0;
        [self.contentArea addSubview:_fromContentLbl];
    }
    
    return _fromContentLbl;
}

- (UILabel *)toTitleLbl{
    if (!_toTitleLbl) {
        _toTitleLbl = [UILabel new];
        _toTitleLbl.bounds = CGRectZero;
        _toTitleLbl.font = [UIFont boldSystemFontOfSize:15.f];
        _toTitleLbl.textColor = [UIColor blackColor];
        _toTitleLbl.textAlignment = NSTextAlignmentLeft;
        _toTitleLbl.text = kLocalizedTableString(@"To", @"CPLocalizable");
        [self.contentArea addSubview:_toTitleLbl];
    }
    
    return _toTitleLbl;
}

- (UILabel *)toContentLbl{
    if (!_toContentLbl) {
        _toContentLbl = [UILabel new];
        _toContentLbl.bounds = CGRectMake(0, 0, 120, 25);
        _toContentLbl.font = [UIFont systemFontOfSize:14.f];
        _toContentLbl.textColor = [UIColor darkGrayColor];
        _toContentLbl.textAlignment = NSTextAlignmentLeft;
        _toContentLbl.numberOfLines = 0;
        [self.contentArea addSubview:_toContentLbl];
    }
    
    return _toContentLbl;
}

- (UILabel *)timeTitleLbl{
    if (!_timeTitleLbl) {
        _timeTitleLbl = [UILabel new];
        _timeTitleLbl.bounds = CGRectZero;
        _timeTitleLbl.font = [UIFont boldSystemFontOfSize:15.f];
        _timeTitleLbl.textColor = [UIColor blackColor];
        _timeTitleLbl.textAlignment = NSTextAlignmentLeft;
        _timeTitleLbl.text = kLocalizedTableString(@"Time", @"CPLocalizable");
        [self.contentArea addSubview:_timeTitleLbl];
    }
    
    return _timeTitleLbl;
}

- (UILabel *)timeContentLbl{
    if (!_timeContentLbl) {
        _timeContentLbl = [UILabel new];
        _timeContentLbl.bounds = CGRectMake(0, 0, 120, 25);
        _timeContentLbl.font = [UIFont systemFontOfSize:14.f];
        _timeContentLbl.textColor = [UIColor darkGrayColor];
        _timeContentLbl.textAlignment = NSTextAlignmentLeft;
        _timeContentLbl.numberOfLines = 0;
        [self.contentArea addSubview:_timeContentLbl];
    }
    
    return _timeContentLbl;
}

- (UILabel *)remarkTitleLbl{
    if (!_remarkTitleLbl) {
        _remarkTitleLbl = [UILabel new];
        _remarkTitleLbl.bounds = CGRectZero;
        _remarkTitleLbl.font = [UIFont boldSystemFontOfSize:15.f];
        _remarkTitleLbl.textColor = [UIColor blackColor];
        _remarkTitleLbl.textAlignment = NSTextAlignmentLeft;
        _remarkTitleLbl.text = kLocalizedTableString(@"Msg Remark", @"CPLocalizable");
        [self.contentArea addSubview:_remarkTitleLbl];
    }
    
    return _remarkTitleLbl;
}

- (UILabel *)remarkContentLbl{
    if (!_remarkContentLbl) {
        _remarkContentLbl = [UILabel new];
        _remarkContentLbl.bounds = CGRectMake(0, 0, 120, 25);
        _remarkContentLbl.font = [UIFont systemFontOfSize:14.f];
        _remarkContentLbl.textColor = [UIColor darkGrayColor];
        _remarkContentLbl.textAlignment = NSTextAlignmentLeft;
        _remarkContentLbl.numberOfLines = 0;
        [self.contentArea addSubview:_remarkContentLbl];
    }
    
    return _remarkContentLbl;
}

- (UIButton *)ignoreButton{
    if (!_ignoreButton) {
        _ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _ignoreButton.frame = CGRectMake(5, 50, 70, 40);
        _ignoreButton.backgroundColor = [UIColor colorWithRed:240/255.f green:72/255.f blue:117/255.f alpha:1];
        _ignoreButton.layer.cornerRadius = 10;
        _ignoreButton.layer.masksToBounds = YES;
        _ignoreButton.tag = 10000;
        [_ignoreButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentArea addSubview:_ignoreButton];
    }
    return _ignoreButton;
}


- (UIButton *)agreeButton{
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.frame = CGRectMake(CGRectGetMaxX(_ignoreButton.frame)+30, 50, 70, 40);
        _agreeButton.backgroundColor = [UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1];
        _agreeButton.layer.cornerRadius = 10;
        _agreeButton.layer.masksToBounds = YES;
        _agreeButton.tag = 10001;
        [_agreeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentArea addSubview:_agreeButton];
    }
    return _agreeButton;
}

-(void)buttonPressed:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didDealContract:withModel:withAgree:)]){
        BOOL agree = NO;
        if (sender.tag == 10001) {
            agree = YES;
        }
        [self.delegate didDealContract:self withModel:self.model withAgree:agree];
    }
}
@end
