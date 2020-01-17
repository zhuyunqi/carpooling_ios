//
//  CPUserLoginCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPUserLoginCell1Delegate <NSObject>
@optional
-(void)userLoginCell1RegisterBtnAction;
-(void)userLoginCell1ForgotPwdBtnAction;
-(void)userLoginCell1ThirdPartyLoginBtnAction;
@end

@interface CPUserLoginCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgotPwdBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *descLbl;
@property (weak, nonatomic) IBOutlet UIButton *thirdPartyLoginBtn;
@property (nonatomic, weak) id<CPUserLoginCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
