//
//  CPChangeLanguageCell.h
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPChangeLanguageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (nonatomic, assign) BOOL customSelected;
@end

NS_ASSUME_NONNULL_END
