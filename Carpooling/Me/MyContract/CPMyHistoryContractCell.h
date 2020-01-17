//
//  CPMyHistoryContractCell.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPContractMJModel;
NS_ASSUME_NONNULL_BEGIN
@protocol CPMyHistoryContractCellDelegate <NSObject>
@optional
-(void)historyContractCellDetailAction:(NSIndexPath*)indexPath;
-(void)historyContractCellCommentAction:(NSIndexPath*)indexPath;
-(void)historyContractCellPhoneCallAction:(NSIndexPath*)indexPath;
-(void)historyContractCellChatAction:(NSIndexPath*)indexPath;
- (void)historyContractCellNaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface CPMyHistoryContractCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;
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
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UIImageView *otherAvatar;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UILabel *contractTypeLbl;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) CPContractMJModel *contractModel;
@property (nonatomic, weak) id<CPMyHistoryContractCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
