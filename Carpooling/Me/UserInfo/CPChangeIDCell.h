//
//  CPChangeIDCell.h
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPChangeIDCellDelegate <NSObject>
@required
- (void)changeIDCellTFDidEndEditing:(NSString*)text;
- (void)changeIDCellTFShouldReturn:(NSString*)text;
@end

@interface CPChangeIDCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (nonatomic, weak) id<CPChangeIDCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
