//
//  CPBindingPhoneCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BWGetVerifyCodeButton;
NS_ASSUME_NONNULL_BEGIN

@protocol CPBindingPhoneCell1Delegate <NSObject>
@required
-(void)bindingPhoneCell1TFTextField:(UITextField*)textField;
-(void)bindingPhoneCell1GetVerifyAction;
-(void)bindingPhoneCell1GoNationCodeVCAction;
-(void)bindingPhoneCell1ConfirmAction;
@end

@interface CPBindingPhoneCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *veriCodeTF;
@property (weak, nonatomic) IBOutlet BWGetVerifyCodeButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *countingLbl;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;
@property (weak, nonatomic) IBOutlet UILabel *codeLbl;
@property (weak, nonatomic) IBOutlet UILabel *line1;
@property (weak, nonatomic) IBOutlet UILabel *line2;

@property (nonatomic, assign) BOOL startCount;

@property (nonatomic, weak) id<CPBindingPhoneCell1Delegate> delegate;

@end

NS_ASSUME_NONNULL_END
