//
//  CPMyScheduleCell.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPScheduleMJModel;
NS_ASSUME_NONNULL_BEGIN
@protocol CPMyScheduleCellDelegate <NSObject>
@optional
- (void)myScheduleCellEditBtnAction:(NSIndexPath*)indexPath;
- (void)myScheduleCellMatchingBtnAction:(NSIndexPath*)indexPath;
- (void)myScheduleCellDeleteBtnAction:(NSIndexPath*)indexPath;
- (void)myScheduleCellNaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface CPMyScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *startMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *startLbl;
@property (weak, nonatomic) IBOutlet UILabel *endMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *endLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *matchingBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic, strong) CPScheduleMJModel *scheduleMJModel;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<CPMyScheduleCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
