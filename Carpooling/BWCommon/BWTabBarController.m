//
//  BWTabBarController.m
//  Carpooling
//
//  Created by Yang on 2019/6/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import "BWTabBarController.h"

@interface BWTabBarController ()

@end

@implementation BWTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor blackColor];
            }
            else {
                return RGBA(120, 220, 195, 1);
            }
        }];

        self.tabBar.tintColor = dyColor;

    } else {
        // Fallback on earlier versions
        self.tabBar.tintColor = [UIColor blackColor];
    }
    
//    self.tabBar.unselectedItemTintColor = [UIColor lightGrayColor];
    
    
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = [self.tabBar.items objectAtIndex:i];
        if (i == 0) {
            item.title = kLocalizedTableString(@"Index", @"CPLocalizable");
        }
        else if (i == 1) {
            item.title = kLocalizedTableString(@"Message", @"CPLocalizable");
        }
        else if (i == 2) {
            item.title = kLocalizedTableString(@"Schedule", @"CPLocalizable");
        }
        else if (i == 3) {
            item.title = kLocalizedTableString(@"Me", @"CPLocalizable");
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
