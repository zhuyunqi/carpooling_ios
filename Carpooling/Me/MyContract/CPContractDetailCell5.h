//
//  CPContractDetailCell5.h
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPContractMJModel;

NS_ASSUME_NONNULL_BEGIN
@protocol CPContractDetailCell5Delegate <NSObject>
@required
- (void)collectionViewDidSelectItemAtIndex:(NSIndexPath*)indexPath isSelect:(BOOL)select;
@end

@interface CPContractDetailCell5 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) NSArray *noticeTitleItems;
@property (nonatomic, strong) NSMutableArray *noticeTag; //
@property (nonatomic) NSUInteger selectLimitCount;
@property (nonatomic, strong) CPContractMJModel *contractModel;
@property (nonatomic, weak) id<CPContractDetailCell5Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
