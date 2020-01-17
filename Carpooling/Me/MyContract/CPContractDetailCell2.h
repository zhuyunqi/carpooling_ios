//
//  CPContractDetailCell2.h
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPContractDetailCell2Delegate <NSObject>
@required
- (void)contractDetailCell2PhoneAction;
@end

@interface CPContractDetailCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneLbl;

@property (nonatomic, weak) id<CPContractDetailCell2Delegate> delegate;

@end

NS_ASSUME_NONNULL_END
