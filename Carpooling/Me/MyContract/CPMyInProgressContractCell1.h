//
//  CPMyInProgressContractCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPContractMJModel, MZTimerLabel;
NS_ASSUME_NONNULL_BEGIN

@protocol CPMyInProgressContractCell1Delegate <NSObject>
@optional
-(void)contractCell1DetailAction:(NSIndexPath*)indexPath;
-(void)contractCell1CancelAction:(NSIndexPath*)indexPath;
-(void)contractCell1OnCarAction:(NSIndexPath*)indexPath;
-(void)contractCell1ArriveAction:(NSIndexPath*)indexPath;
-(void)contractCell1PhoneCallAction:(NSIndexPath*)indexPath;
-(void)contractCell1ChatAction:(NSIndexPath*)indexPath;
-(void)contractCell1LocationAction:(NSIndexPath*)indexPath;
- (void)contractCell1NaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface CPMyInProgressContractCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *detailMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *startMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *startLbl;
@property (weak, nonatomic) IBOutlet UILabel *endMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *endLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *driverIcon;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *onCarBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UIImageView *otherAvatar;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UILabel *contractTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *inProgressDescLbl;
@property (weak, nonatomic) IBOutlet MZTimerLabel *inProgressTimeLbl;

@property (weak, nonatomic) IBOutlet UIImageView *currentLocationIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationMarkLbl;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationBtn;
@property (weak, nonatomic) IBOutlet UIButton *arriveBtn;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) CPContractMJModel *contractModel;
@property (nonatomic, weak) id<CPMyInProgressContractCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
