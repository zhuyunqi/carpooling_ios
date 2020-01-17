//
//  CPCalendarSelectMonthHeader.m
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPCalendarSelectMonthHeader.h"

@implementation CPCalendarSelectMonthHeader

- (IBAction)leftAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectMonthLeftBtnAction:)]) {
        [self.delegate selectMonthLeftBtnAction:sender];
    }
}
- (IBAction)rightAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectMonthRightBtnAction:)]) {
        [self.delegate selectMonthRightBtnAction:sender];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
