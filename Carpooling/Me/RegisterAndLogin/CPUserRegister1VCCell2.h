//
//  CPUserRegister1VCCell2.h
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BWGetVerifyCodeButton;
NS_ASSUME_NONNULL_BEGIN
@protocol CPUserRegister1VCCell2Delegate <NSObject>
@optional
-(void)userRegister1VCCell2TFText:(NSString*)text;
-(void)userRegister1VCCell2GetVerifyAction;
-(void)userRegister1VCCell2ConfirmAction;
@end

@interface CPUserRegister1VCCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *TFBgView;
@property (weak, nonatomic) IBOutlet UITextField *textTF;
@property (weak, nonatomic) IBOutlet BWGetVerifyCodeButton *getVerifyCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic, assign) BOOL startCount;
@property (nonatomic, weak) id<CPUserRegister1VCCell2Delegate> delegate;

@end

NS_ASSUME_NONNULL_END
