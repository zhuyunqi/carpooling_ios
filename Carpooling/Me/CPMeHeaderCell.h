//
//  CPMeHeaderCell.h
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPMeHeaderCellDelegate <NSObject>
@optional
- (void)meHeaderCellEditAction;
- (void)meHeaderCellSignInAction;
@end

@interface CPMeHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *accountLbl;
@property (weak, nonatomic) IBOutlet UILabel *scoreLbl;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIImageView *editIcon;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (nonatomic, weak) id<CPMeHeaderCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
