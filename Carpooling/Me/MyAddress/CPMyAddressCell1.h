//
//  CPMyAddressCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPAddressModel, CPMyAddressCell1;
NS_ASSUME_NONNULL_BEGIN

@protocol CPMyAddressCell1Delegate <NSObject>
@required
- (void)addressCell1CollectActionAtIndexPath:(NSIndexPath*)indexPath;
- (void)addressCell1LongPress:(CPMyAddressCell1 *)cell atIndexPath:(NSIndexPath*)indexPath;
@end


@interface CPMyAddressCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *markIcon;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic, strong) CPAddressModel *addressModel;
// 0, 我的收藏;  1,我的地址;  2,历史地址
@property (nonatomic, assign) NSInteger showType;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CPMyAddressCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
