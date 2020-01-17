//
//  CPSettingCell2.h
//  Carpooling
//
//  Created by Yang on 2019/6/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPSettingCell2Delegate <NSObject>
@required
-(void)settingCell2ConfirmAction;
@end

@interface CPSettingCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic, weak) id<CPSettingCell2Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
