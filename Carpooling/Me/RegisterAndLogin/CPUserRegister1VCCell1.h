//
//  CPUserRegister1VCCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/4.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPUserRegister1VCCell1Delegate <NSObject>
@required
- (void)userRegister1VCCell1TFText:(NSString*)text;
@end

@interface CPUserRegister1VCCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *TFBgView;
@property (weak, nonatomic) IBOutlet UITextField *textTF;
@property (weak, nonatomic) IBOutlet UILabel *nationCodeLbl;
@property (nonatomic, weak) id<CPUserRegister1VCCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
