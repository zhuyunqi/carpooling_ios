//
//  CPContractDetailCell3.h
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPContractDetailCell3 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *endDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *driverIcon;
@property (weak, nonatomic) IBOutlet UILabel *driverLbl;
@property (weak, nonatomic) IBOutlet UILabel *contractTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *fromMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *fromLbl;
@property (weak, nonatomic) IBOutlet UILabel *toMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *toLbl;

@end

NS_ASSUME_NONNULL_END
