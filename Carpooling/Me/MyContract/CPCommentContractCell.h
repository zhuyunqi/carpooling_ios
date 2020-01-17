//
//  CPCommentContractCell.h
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPCommentContractCellDelegate <NSObject>
@required
- (void)commentContractCellTVDidEditing:(NSString*)text;
@end

@interface CPCommentContractCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *descTV;
@property (nonatomic, weak) id<CPCommentContractCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
