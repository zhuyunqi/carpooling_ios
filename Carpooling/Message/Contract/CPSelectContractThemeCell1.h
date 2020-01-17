//
//  CPSelectContractThemeCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/2.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPSelectContractThemeCell1Delegate <NSObject>
@required
- (void)selectContractThemeCell1TFDidEndEditing:(NSString*)text;
- (void)selectContractThemeCell1TFShouldReturn:(NSString*)text;
@end

@interface CPSelectContractThemeCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (nonatomic, weak) id<CPSelectContractThemeCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
