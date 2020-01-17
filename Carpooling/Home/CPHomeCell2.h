//
//  CPHomeCell2.h
//  Carpooling
//
//  Created by bw on 2019/5/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPActivityMJModel;
NS_ASSUME_NONNULL_BEGIN
@protocol CPHomeCell2Delegate <NSObject>
@optional
-(void)homeCell2LikeAction:(NSIndexPath*)indexPath;
-(void)homeCell2NaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination; // location navigation
-(void)homeCell2EditAction:(NSIndexPath*)indexPath;
@end

@interface CPHomeCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *likeLbl;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityImgConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UIImageView *localtionIcon;
@property (weak, nonatomic) IBOutlet UIImageView *editIcon;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (nonatomic, assign) NSInteger showType;

@property (nonatomic, strong) CPActivityMJModel *activityModel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CPHomeCell2Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
