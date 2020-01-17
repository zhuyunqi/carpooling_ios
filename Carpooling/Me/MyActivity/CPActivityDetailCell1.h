//
//  CPActivityDetailCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPActivityMJModel;
NS_ASSUME_NONNULL_BEGIN

@protocol CPActivityDetailCell1Delegate <NSObject>
@required
- (void)activityDetailCell1CheckMember:(id)sender;
-(void)activityDetailCell1NaviAction; // location navigation
@end

@interface CPActivityDetailCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *countLbl;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UITextView *textTV;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityImgConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;

@property (nonatomic, weak) id<CPActivityDetailCell1Delegate> delegate;

@property (nonatomic, strong) CPActivityMJModel *activityModel;

@end

NS_ASSUME_NONNULL_END
