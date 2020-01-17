//
//  CPCommentContractDetailCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPCommentContractDetailCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *mineTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *mineCommentLbl;
@property (weak, nonatomic) IBOutlet UIImageView *mineIcon;
@property (weak, nonatomic) IBOutlet UIImageView *otherIcon;
@property (weak, nonatomic) IBOutlet UILabel *otherTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *otherCommentLbl;

@end

NS_ASSUME_NONNULL_END
