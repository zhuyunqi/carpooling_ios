//
//  BWGetVerifyCodeButton.m
//  NHYHealthChainDoctor
//
//  Created by __ on 2018/12/28.
//  Copyright © 2018 __. All rights reserved.
//

#import "BWGetVerifyCodeButton.h"

@implementation BWGetVerifyCodeButton

#pragma mark - 初始化控件
- (void)awakeFromNib{
    [super awakeFromNib];
    // button Type must be UIButtonTypeCustom
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // button Type must be UIButtonTypeCustom
        [self setup];
    }
    return self;
}

- (void)dealloc{
    [self.timer invalidate];
    NSLog(@"BWGetVerifyCodeButton timer invalidate");
}

- (void)setup {
    // button Type must be UIButtonTypeCustom
    [self setTitle:kLocalizedTableString(@"Get Verification code", @"CPLocalizable") forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:15.f];
}
#pragma mark - 添加定时器
- (void)countDownWithSeconds:(NSInteger)seconds {
    self.seconds = seconds;
    self.enabled = NO;
    // 加1个定时器
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tikTok) userInfo: nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:UITrackingRunLoopMode];
}

#pragma mark - 定时器事件
- (void)tikTok {
    if (self.seconds != 0){
        self.seconds -= 1;
        self.enabled = NO;

        [self setTitle:[NSString stringWithFormat:@"%@ %lds", kLocalizedTableString(@"Retrieve Verification code", @"CPLocalizable"), self.seconds] forState:UIControlStateNormal];
//        [self setTitleColor:[UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        
        [self.timer invalidate];
        self.enabled = YES;
        [self setTitle:kLocalizedTableString(@"Get Verification code", @"CPLocalizable") forState:UIControlStateNormal];
//        [self setTitleColor:[UIColor colorWithRed:33/255.f green:202/255.f blue:108/255.f alpha:1] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
