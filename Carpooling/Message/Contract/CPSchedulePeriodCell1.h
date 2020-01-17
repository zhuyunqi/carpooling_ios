//
//  CPSchedulePeriodCell1.h
//  Carpooling
//
//  Created by bw on 2019/9/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPSchedulePeriodCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (nonatomic, assign) BOOL customSelected;
@end

NS_ASSUME_NONNULL_END
