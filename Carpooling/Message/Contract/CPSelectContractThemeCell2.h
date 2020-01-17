//
//  CPSelectContractThemeCell2.h
//  Carpooling
//
//  Created by Yang on 2019/6/2.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPSelectContractThemeCell2Delegate <NSObject>
@required
- (void)selectContractThemeCell2TVDidEndEditing:(NSString*)text;
@end

@interface CPSelectContractThemeCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *titleTV;
@property (nonatomic, weak) id<CPSelectContractThemeCell2Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
