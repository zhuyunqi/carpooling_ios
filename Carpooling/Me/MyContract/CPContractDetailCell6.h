//
//  CPContractDetailCell6.h
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPContractMJModel;

NS_ASSUME_NONNULL_BEGIN
@protocol CPContractDetailCell6Delegate <NSObject>
@required
- (void)contractDetailCell6CancelBtnAction;
- (void)contractDetailCell6OnCarBtnAction;
- (void)contractDetailCell6ArriveBtnAction;
@end

@interface CPContractDetailCell6 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *onCarBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *arriveBtn;
@property (nonatomic, strong) CPContractMJModel *contractModel;
@property (nonatomic, weak) id<CPContractDetailCell6Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
