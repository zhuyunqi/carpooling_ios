//
//  CPMyAddressPageVC.m
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyAddressPageVC.h"
#import "CPMyAddressVC.h"
#import "CPMyCollectionAddressVC.h"
#import "CPMyHistoryAddressVC.h"
#import "JXCategoryView.h"
#import "SSChatLocationController.h"

@interface CPMyAddressPageVC ()<JXCategoryViewDelegate>
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger selectedIndex;
// 持有UIViewController，防止viewController dealloc
@property (nonatomic, strong) NSMutableDictionary <NSNumber*, UIViewController*>*viewControllersDict;

//@property (nonatomic, assign) BOOL needRefresh; // 删除了地址之后，需要重新刷新。
//@property (nonatomic, strong) NSMutableArray *array; // 需要刷新的总数。
@end


@implementation CPMyAddressPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = kLocalizedTableString(@"My Address", @"CPLocalizable");
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_plus"] style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    
    
    [self initPageContainer];
    [self initIndicatorView];
}


- (void)rightItemClick:(id)sender{
    if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        // 通过地图选择地址
        SSChatLocationController *chatLocationController = [[SSChatLocationController alloc] init];
        chatLocationController.showType = SSChatLocationVCShowTypeMe;
        [self.categoryView selectItemAtIndex:1];
        
        [self.navigationController pushViewController:chatLocationController animated:YES];    }
    else {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please login", @"CPLocalizable")];
    }
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
    _scrollView.scrollEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(kSCREENWIDTH*3, height-kBOTTOMSAFEHEIGHT);
    [self.view addSubview:_scrollView];
    
    self.viewControllersDict = [NSMutableDictionary dictionary];
    
    if (!self.fromMeVC) {
        [self showVCWithIndex:1];
    }
    else {
        [self showVCWithIndex:0];
    }
}


- (void)initIndicatorView{
    _categoryView = [[JXCategoryTitleView alloc] init];
    if (!self.fromMeVC) {
        _categoryView.defaultSelectedIndex = 1;
    }
    _categoryView.frame = CGRectMake(0, kNAVIBARANDSTATUSBARHEIGHT, kSCREENWIDTH, 40);
    _categoryView.delegate = self;
    _categoryView.titles = @[kLocalizedTableString(@"My favorite", @"CPLocalizable"), kLocalizedTableString(@"My Address", @"CPLocalizable"), kLocalizedTableString(@"History Address", @"CPLocalizable")];
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
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"CPMyCollectionAddressVC"];
        }
        else if (index == 1) {
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"CPMyAddressVC"];
        }
        else if (index == 2) {
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"CPMyHistoryAddressVC"];
        }
        
        vc.view.frame = CGRectMake(index*kSCREENWIDTH, 0, kSCREENWIDTH, height);
        [self.scrollView addSubview:vc.view];
        self.viewControllersDict[@(index)] = vc;
    }
    
    // always refresh
    if (index == 0) {
        ((CPMyCollectionAddressVC*)vc).needRefresh = YES;
        ((CPMyCollectionAddressVC*)vc).fromMeVC = self.fromMeVC;
    }
    else if (index == 1) {
        ((CPMyAddressVC*)vc).needRefresh = YES;
        ((CPMyAddressVC*)vc).fromMeVC = self.fromMeVC;
    }
    else if (index == 2) {
        ((CPMyHistoryAddressVC*)vc).needRefresh = YES;
        ((CPMyHistoryAddressVC*)vc).fromMeVC = self.fromMeVC;
    }
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    
    _selectedIndex = index;
    
    [self showVCWithIndex:index];
}

- (void)categoryView:(JXCategoryBaseView *)categoryView scrollingFromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex ratio:(CGFloat)ratio {
    if (ratio > 0.5) {
        //从rightIndex往leftIndex滚动
    }else {
        //从leftIndex往rightIndex滚动
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
