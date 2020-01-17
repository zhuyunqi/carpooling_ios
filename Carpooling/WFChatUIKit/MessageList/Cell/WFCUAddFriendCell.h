//
//  WFCUAddFriendCell.h
//  Carpooling
//
//  Created by bw on 2019/7/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import "WFCUMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCUAddFriendCell : WFCUMessageCell
//忽略按钮
@property(nonatomic,strong)UIButton *ignoreButton;
//同意按钮
@property(nonatomic,strong)UIButton *agreeButton;
//
@property(nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *infoLabel;
@end

NS_ASSUME_NONNULL_END
