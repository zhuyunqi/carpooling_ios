//
//  NHYRefreshBackGifFooter.m
//  SSC
//
//  Created by __ on 2019/2/20.
//  Copyright © 2019 __. All rights reserved.
//

#import "NHYRefreshBackGifFooter.h"

@implementation NHYRefreshBackGifFooter

#pragma mark - 重写方法
#pragma mark 基本设置
- (void)prepare
{
    [super prepare];
    
    self.stateLabel.textColor = [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1];
    //    // 设置普通状态的动画图片
    //    NSMutableArray *idleImages = [NSMutableArray array];
    //    for (NSUInteger i = 1; i<=60; i++) {
    //        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
    //        [idleImages addObject:image];
    //    }
    //    [self setImages:idleImages forState:MJRefreshStateIdle];
    //
    //    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    //    NSMutableArray *refreshingImages = [NSMutableArray array];
    //    for (NSUInteger i = 1; i<=3; i++) {
    //        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
    //        [refreshingImages addObject:image];
    //    }
    //    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    //
    //    // 设置正在刷新状态的动画图片
    //    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}


- (void)placeSubviews
{
    [super placeSubviews];
    
    // 调整状态标签的位置
    CGRect frame = self.stateLabel.frame;
    frame.origin.y += kBOTTOMSAFEHEIGHT;
    self.stateLabel.frame = frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
