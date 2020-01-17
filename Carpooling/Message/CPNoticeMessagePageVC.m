//
//  CPNoticeMessagePageVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPNoticeMessagePageVC.h"
#import "JXCategoryView.h"
#import "CPNoticeMessage1VC.h"
#import "CPNoticeMessage2VC.h"

@interface CPNoticeMessagePageVC ()<JXCategoryViewDelegate>
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger selectedIndex;
// 持有UIViewController，防止viewController dealloc
@property (nonatomic, strong) NSMutableDictionary <NSNumber*, UIViewController*>*viewControllersDict;
@end


@implementation CPNoticeMessagePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = kLocalizedTableString(@"Message", @"CPLocalizable");
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initPageContainer];
    [self initIndicatorView];
}


- (void)initPageContainer{
    CGFloat height = kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-40;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNAVIBARANDSTATUSBARHEIGHT+40, kSCREENWIDTH, height)];
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(240, 240, 240, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        
        _scrollView.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        _scrollView.backgroundColor = RGBA(240, 240, 240, 1);
    }
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(kSCREENWIDTH*3, height-kBOTTOMSAFEHEIGHT);
    [self.view addSubview:_scrollView];
    
    self.viewControllersDict = [NSMutableDictionary dictionary];
    [self showVCWithIndex:0];
}

- (void)initIndicatorView{
    _categoryView = [[JXCategoryTitleView alloc] init];
    _categoryView.frame = CGRectMake(0, kNAVIBARANDSTATUSBARHEIGHT, kSCREENWIDTH, 40);
    _categoryView.delegate = self;
    _categoryView.titles = @[kLocalizedTableString(@"Schedule Notice", @"CPLocalizable"), kLocalizedTableString(@"Branding Notice", @"CPLocalizable"), kLocalizedTableString(@"System Notice", @"CPLocalizable")];
    _categoryView.titleColor = RGBA(157, 157, 157, 1);
    _categoryView.titleFont = [UIFont systemFontOfSize:15];
    _categoryView.titleSelectedColor = RGBA(120, 202, 195, 1);
    _categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:15];
    
    JXCategoryIndicatorLineView *indicatorLine = [[JXCategoryIndicatorLineView alloc] init];
    indicatorLine.indicatorLineViewCornerRadius = 0;
    indicatorLine.indicatorLineViewHeight = 3;
    indicatorLine.indicatorLineViewColor = RGBA(120, 202, 195, 1);
    _categoryView.indicators = @[indicatorLine];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, kSCREENWIDTH, 1)];
    bottomLine.backgroundColor = RGBA(240, 240, 240, 1);
    [_categoryView addSubview:bottomLine];
    
    _categoryView.contentScrollView = _scrollView;
    [self.view addSubview:_categoryView];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        _categoryView.backgroundColor = dyColor;
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(240, 240, 240, 1);
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        bottomLine.backgroundColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        _categoryView.backgroundColor = [UIColor whiteColor];
        bottomLine.backgroundColor = RGBA(240, 240, 240, 1);
    }
}



#pragma mark - 依次加载页面
- (void)showVCWithIndex:(NSInteger)index {
    UIViewController *vc = self.viewControllersDict[@(index)];
    if (vc == nil) {
        CGFloat height = self.scrollView.bounds.size.height;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        
        if (index == 0) {
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"CPNoticeMessage1VC"];
        }
        else if (index == 1) {
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"CPNoticeMessage2VC"];
            ((CPNoticeMessage2VC*)vc).showType = index;
        }
        else if (index == 2) {
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"CPNoticeMessage2VC"];
            ((CPNoticeMessage2VC*)vc).showType = index;
        }
        
        vc.view.frame = CGRectMake(index*kSCREENWIDTH, 0, kSCREENWIDTH, height);
        [self.scrollView addSubview:vc.view];
        self.viewControllersDict[@(index)] = vc;
    }
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    [self showVCWithIndex:index];
    
    _selectedIndex = index;
}

- (void)categoryView:(JXCategoryBaseView *)categoryView scrollingFromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex ratio:(CGFloat)ratio {
    if (ratio > 0.5) {
        //从rightIndex往leftIndex滚动
    }else {
        //从leftIndex往rightIndex滚动
    }
}
@end
