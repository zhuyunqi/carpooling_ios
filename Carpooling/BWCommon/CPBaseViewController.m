//
//  CPBaseViewController.m
//  Carpooling
//
//  Created by bw on 2019/5/15.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"
#import "VHLNavigation.h"

@interface CPBaseViewController ()

@end

@implementation CPBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
//    self.navigationController.tabBarController.tabBar.tintColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1];
    
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1];
    [self vhl_setNavBarBackgroundColor:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]];
    [self vhl_setNavBarTintColor:[UIColor whiteColor]];
    [self vhl_setNavBarTitleColor:[UIColor whiteColor]];
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
