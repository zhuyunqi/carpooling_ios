//
//  MessageCellBase.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUMessageCellBase.h"
#import "WFCUUtilities.h"

@implementation WFCUMessageCellBase
+ (CGSize)sizeForCell:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
  return CGSizeMake(width, 80);
}
+ (CGFloat)hightForTimeLabel:(WFCUMessageModel *)msgModel {
  if (msgModel.showTimeLabel) {
    return 35;
  }
  return 10;
}
- (void)onTaped:(id)sender {
    [self.delegate didTapMessageCell:self withModel:self.model];
}

- (void)onLongPressed:(id)sender {
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer *)sender;
        if(recognizer.state == UIGestureRecognizerStateBegan) {
            [self.delegate didLongPressMessageCell:self withModel:self.model];
        }
    }
}

- (void)setModel:(WFCUMessageModel *)model {
  _model = model;
  if (model.showTimeLabel) {
    if (self.timeLabel == nil) {
      self.timeLabel = [[UILabel alloc] init];
      _timeLabel.font = [UIFont systemFontOfSize:12.f];
      
      [self.contentView addSubview:self.timeLabel];
    }
    _timeLabel.hidden = NO;
    _timeLabel.text = [WFCUUtilities formatTimeDetailLabel:model.message.serverTime];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGSize size = [WFCUUtilities getTextDrawingSize:_timeLabel.text font:_timeLabel.font constrainedSize:CGSizeMake(screenWidth, 8000)];
    CGRect rect = CGRectMake((screenWidth - size.width)/2, 10, size.width, size.height);
    _timeLabel.frame = rect;
  } else {
    _timeLabel.hidden = YES;
  }
}


@end
