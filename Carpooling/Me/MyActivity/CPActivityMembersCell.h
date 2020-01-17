//
//  CPActivityMembersCell.h
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface CPActivityMembersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (nonatomic, strong) CPUserInfoModel *enrollMember;
@end

NS_ASSUME_NONNULL_END
