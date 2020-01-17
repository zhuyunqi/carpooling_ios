//
//  CPMatchingScheduleCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/9.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPMatchingScheduleModel.h"
@class CPMatchingScheduleModel;
NS_ASSUME_NONNULL_BEGIN

@protocol CPMatchingScheduleCell1Delegate <NSObject>
@optional
- (void)matchingScheduleCell1BtnAction:(NSIndexPath*)indexPath;
@end

@interface CPMatchingScheduleCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *startMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *startLbl;
@property (weak, nonatomic) IBOutlet UILabel *endMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *endLbl;
@property (nonatomic, strong) CPMatchingScheduleModel *matchingScheduleModel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CPMatchingScheduleCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
