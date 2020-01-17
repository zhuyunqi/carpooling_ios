//
//  CPMyFriendCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@protocol CPMyFriendCell1Delegate <NSObject>
@required
- (void)myFriendCell1SetNotenameAction:(NSIndexPath*)indexPath;
@end

@interface CPMyFriendCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *detailLbl;
@property (weak, nonatomic) IBOutlet UILabel *subDetailLbl;
@property (weak, nonatomic) IBOutlet UIButton *noteNameBtn;

@property (nonatomic, strong) CPUserInfoModel *enrollMember;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSIndexPath *selectIndexPath; // 设置好友备注名

@property (nonatomic, weak) id<CPMyFriendCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
