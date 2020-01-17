//
//  CPNoticeMessageCell2.h
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPNoticeModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPNoticeMessageCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *descLbl;
@property (weak, nonatomic) IBOutlet UIView *icon;
@property (nonatomic, strong) CPNoticeModel *noticeModel;
@end

NS_ASSUME_NONNULL_END
