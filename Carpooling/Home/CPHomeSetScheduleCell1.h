//
//  CPHomeSetScheduleCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CPHomeSetScheduleCell1Delegate <NSObject>
@required
-(void)homeSetScheduleCell1BtnActionByIndexPath:(NSIndexPath*)indexPath;
@end

@interface CPHomeSetScheduleCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLbl;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic, assign) NSInteger tipsType; // 1,contract empty;  2,schedule empty;  3,activity empty;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CPHomeSetScheduleCell1Delegate> delegate;

@end

NS_ASSUME_NONNULL_END
