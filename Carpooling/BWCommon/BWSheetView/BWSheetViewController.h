//
//  BWSheetViewController.h
//  SSC
//
//  Created by __ on 2019/3/14.
//  Copyright © 2019 __. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BWSheetBottmView;
NS_ASSUME_NONNULL_BEGIN

@interface BWSheetViewController : UIViewController

@property(nonnull, nonatomic, strong, readonly) BWSheetBottmView *bottomView;

/*!
 Disable dismiss action sheet when touching blank area at the top.
 */
@property(nonatomic, assign) BOOL disableDismissOnTouchOutside;

- (void)showBottomView:(BWSheetBottmView *)bottomView viewHeight:(CGFloat)height completion:(void (^)(void))completion;
- (void)dismissWithCompletion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
