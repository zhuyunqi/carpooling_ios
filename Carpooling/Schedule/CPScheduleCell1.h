//
//  CPScheduleCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN
@protocol CPScheduleCell1Delegate <NSObject>
@optional
- (void)scheduleCell1DetailBtnAction:(NSIndexPath*)indexPath;
- (void)scheduleCell1ChatBtnAction:(NSIndexPath*)indexPath;
- (void)scheduleCell1PhoneBtnAction:(NSIndexPath*)indexPath;
- (void)scheduleCell1NaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface CPScheduleCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ampmLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *detailMarkLbl;
@property (weak, nonatomic) IBOutlet UIImageView *driverIcon;
@property (weak, nonatomic) IBOutlet UILabel *startMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *startLbl;
@property (weak, nonatomic) IBOutlet UILabel *endMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *endLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UIImageView *otherAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *msgIcon;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;

@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<CPScheduleCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
