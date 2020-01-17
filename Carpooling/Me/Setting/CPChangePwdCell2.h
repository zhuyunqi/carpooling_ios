//
//  CPChangePwdCell2.h
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPChangePwdCell2Delegate <NSObject>
@optional
-(void)changePwdCell2BtnAction;
@end

@interface CPChangePwdCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic, weak) id<CPChangePwdCell2Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
