//
//  CPChangePwdCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPChangePwdCell1Delegate <NSObject>
@required
- (void)changePwdCell1TFTextField:(UITextField*)textField;
@end

@interface CPChangePwdCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<CPChangePwdCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
