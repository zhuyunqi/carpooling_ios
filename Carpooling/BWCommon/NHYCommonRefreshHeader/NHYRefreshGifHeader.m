//
//  NHYRefreshGifHeader.m
//  SSC
//
//  Created by __ on 2018/11/24.
//  Copyright © 2018 __. All rights reserved.
//

#import "NHYRefreshGifHeader.h"

@implementation NHYRefreshGifHeader

#pragma mark - 重写方法
#pragma mark 基本设置
- (void)prepare
{
    [super prepare];

//    NSMutableArray *refreshingImages = [NSMutableArray array];
//    // ios12下，避免阻塞线程
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSUInteger i = 1; i <= 29; i++) {
//            NSString * imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"nhyloading-100%.2lu",(unsigned long)i] ofType:@"png"];
//            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
//            if (image) {
//                [refreshingImages addObject:image];
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 设置普通状态的动画图片
//            [self setImages:refreshingImages forState:MJRefreshStateIdle];
//            // 设置pull状态的动画图片
//            [self setImages:refreshingImages forState:MJRefreshStatePulling];
//            // 设置正在刷新状态的动画图片
//            [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
//        });
//    });
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    // 设置高度
    self.mj_h = 50;
    
    self.stateLabel.hidden = YES;
    self.lastUpdatedTimeLabel.hidden = YES;
    
    self.gifView.frame = CGRectMake(self.center.x-35/2, self.center.y+35, 35, 35);
    self.gifView.contentMode = UIViewContentModeScaleAspectFit;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
