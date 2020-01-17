//
//  CPNoticeMessageCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPNoticeMessageCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLbl;
@property (weak, nonatomic) IBOutlet UIView *icon;

@end

NS_ASSUME_NONNULL_END
