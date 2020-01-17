//
//  CPHomeNoDataCell1.h
//  Carpooling
//
//  Created by Yang on 2019/6/13.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface CPHomeNoDataCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (nonatomic, assign) NSInteger tipsType; // 1,contract empty;  2,schedule empty;  3,activity empty;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
