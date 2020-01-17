//
//  BWSheetViewController.m
//  SSC
//
//  Created by __ on 2019/3/14.
//  Copyright © 2019 __. All rights reserved.
//

#import "BWSheetViewController.h"
#import "BWSheetBottmView.h"

@interface BWSheetViewController ()

@property(nonatomic, readonly) UITapGestureRecognizer *tappedDismissGestureRecognizer;

@property (nullable, readwrite, strong) UIView *inputView;
@property (nullable, readwrite, strong) UIView *inputAccessoryView;

@end

@implementation BWSheetViewController

@synthesize tappedDismissGestureRecognizer = _tappedDismissGestureRecognizer;

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor clearColor];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canResignFirstResponder
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:self.tappedDismissGestureRecognizer];
}


-(void)setDisableDismissOnTouchOutside:(BOOL)disableDismissOnTouchOutside
{
    _disableDismissOnTouchOutside = disableDismissOnTouchOutside;
    self.tappedDismissGestureRecognizer.enabled = !disableDismissOnTouchOutside;
}

-(UITapGestureRecognizer *)tappedDismissGestureRecognizer
{
    if (_tappedDismissGestureRecognizer == nil)
    {
        _tappedDismissGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    }
    
    return _tappedDismissGestureRecognizer;
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //Code to handle the gesture
        [self dismissWithCompletion:nil];
    }
}

-(void)showBottomView:(BWSheetBottmView *)bottomView viewHeight:(CGFloat)height completion:(void (^)(void))completion
{
    _bottomView = bottomView;
    
    //  获取当前显示的UIViewController // 遮罩导航栏
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topController = [Utils findCurrentShowingViewControllerFrom:vc];

    NSLog(@"BWSheetViewController topController:%@", topController);
    [topController.view endEditing:YES];
    NSLog(@"after BWSheetViewController topController:%@", topController);
    
    if (height) {
        // custom inputView height
        UIView *customInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
        [customInputView addSubview:bottomView];
        
        // vfl Visual Format Language
        bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSNumber *nHeight = [NSNumber numberWithFloat:height];
        NSDictionary *viewDict = NSDictionaryOfVariableBindings(bottomView);
        NSDictionary *mertrics = NSDictionaryOfVariableBindings(nHeight);
        
        NSArray<NSLayoutConstraint*> *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:0 metrics:nil views:viewDict];
        
        NSArray<NSLayoutConstraint*> *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[bottomView(==nHeight)]" options:0 metrics:mertrics views:viewDict];
        
        [customInputView addConstraints:horizontalConstraints];
        [customInputView addConstraints:verticalConstraints];
        
        
        self.inputView = customInputView;
        
        
    }
    else{
        self.inputView = bottomView;
        NSLog(@"self.inputView.frame:%@", NSStringFromCGRect(self.inputView.frame));
    }
    
    self.inputAccessoryView = bottomView.actionToolbar;
    
    
    //Adding self.view to topMostController.view and adding self as childViewController to topMostController
    {
        // 遮罩导航栏
        //        self.view.frame = CGRectMake(0, 0, topController.view.bounds.size.width, topController.view.bounds.size.height);
        
        NSLog(@"BWSheetViewController topController:%@, topController.navigationController:%@, navigationBar height:%f", topController, topController.navigationController,  topController.navigationController.navigationBar.frame.size.height);
        
        CGFloat axisY = 0;
        
        // 如果是 UIViewController // 不遮罩导航栏
        if (![topController isKindOfClass:[UITabBarController class]] || ![topController isKindOfClass:[UINavigationController class]]){
            axisY = [[UIApplication sharedApplication] statusBarFrame].size.height + topController.navigationController.navigationBar.frame.size.height;
        }
        
        self.view.frame = CGRectMake(0, axisY, topController.view.bounds.size.width, topController.view.bounds.size.height-axisY);
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [topController addChildViewController: self];
        [topController.view addSubview: self.view];
        [self didMoveToParentViewController:topController];
    }
    
    [self becomeFirstResponder];
    
    //Sliding up the pickerView with animation
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

-(void)dismissWithCompletion:(void (^)(void))completion
{
    [self resignFirstResponder];
    
    //Sliding down the pickerView with animation.
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:^{
        
        self.view.backgroundColor = [UIColor clearColor];
        
    } completion:^(BOOL finished) {
        
        //Removing self.view from topMostController.view and removing self as childViewController from topMostController
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (completion) completion();
    }];
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
