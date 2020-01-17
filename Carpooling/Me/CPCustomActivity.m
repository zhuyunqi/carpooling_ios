//
//  CPCustomActivity.m
//  Carpooling
//
//  Created by Yang on 2019/6/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPCustomActivity.h"

@interface CPCustomActivity ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *type;

@end

@implementation CPCustomActivity
- (instancetype)initWithTitle:(NSString *)title URL:(NSURL *)url ActivityType:(NSString *)activityType{
    self = [super init];
    if (self) {
        self.title = title;
        self.url = url;
        self.type = activityType;
    }
    return self;
}
/**
 决定自定义CustomActivity在UIActivityViewController中显示的位置。
 最上层：AirDrop
 中层：Share，即UIActivityCategoryShare
 中层：Action，即UIActivityCategoryAction
 */
+ (UIActivityCategory)activityCategory{
    return UIActivityCategoryAction;
}

- (NSString *)activityType{
    return _type;
}

- (NSString *)activityTitle {
    return _title;
}

- (NSURL *)activityUrl{
    return _url;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
/**
 准备分享所进行的方法，通常在这个方法里面，把item中的东西保存下来,items就是要传输的数据。
 */
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
}
/**
 1、这里就可以关联外面的app进行分享操作了
 2、也可以进行一些数据的保存等操作
 3、操作的最后必须使用下面方法告诉系统分享结束了
 */
- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
