//
//  CPSetupActivityCell2.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPSetupActivityCell2Delegate <NSObject>
@required
- (void)setupActivityCell2TVDidEditing:(NSString*)text;
@end

@interface CPSetupActivityCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *descLbl;
@property (weak, nonatomic) IBOutlet UITextView *descTV;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, weak) id<CPSetupActivityCell2Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
