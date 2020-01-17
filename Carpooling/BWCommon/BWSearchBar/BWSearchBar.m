//
//  BWSearchBar.m
//  SSC
//
//  Created by bw on 2019/3/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "BWSearchBar.h"

@implementation BWSearchBar

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (@available(iOS 13.0, *)) {
        
        
    } else {
        UITextField *textField = [self valueForKey:@"_searchField"];
        
        textField.layer.cornerRadius = 10;
        textField.layer.masksToBounds = YES;
        
        CGRect rect1 = textField.bounds;
        rect1.size.height = 38;
        rect1.size.width -= 20;
        textField.bounds = rect1;
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
