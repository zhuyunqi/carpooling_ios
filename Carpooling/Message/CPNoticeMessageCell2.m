//
//  CPNoticeMessageCell2.m
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPNoticeMessageCell2.h"
#import "CPNoticeModel.h"

@implementation CPNoticeMessageCell2

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
    
    _icon.layer.cornerRadius = _icon.frame.size.height/2;
    _icon.layer.masksToBounds = YES;
    
    _icon.backgroundColor = RGBA(198, 0, 0, 1);
}

- (void)setNoticeModel:(CPNoticeModel *)noticeModel{
    if (_noticeModel != noticeModel) {
        _noticeModel = noticeModel;
        
        _titleLbl.text = @"";
        _descLbl.text = noticeModel.content;
        
        NSTimeInterval timestamp = noticeModel.createTime/1000;// 毫秒转秒
        NSDate *date = [Utils getDateWithTimestamp:timestamp];
        NSString *dateStr = [Utils dateToString:date withDateFormat:@"yyyy/MM/dd HH:mm"];
        _timeLbl.text = dateStr;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
