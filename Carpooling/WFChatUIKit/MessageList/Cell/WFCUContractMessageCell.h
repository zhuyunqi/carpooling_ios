//
//  WFCUContractMessageCell.h
//  Carpooling
//
//  Created by bw on 2019/7/6.
//  Copyright © 2019 bw. All rights reserved.
//

#import "WFCUMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFCUContractMessageCell : WFCUMessageCell

//顶部标题
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *titleLbl;

//分割线
@property (nonatomic,strong) UIView  *line;
@property (nonatomic,strong) UIView  *bgView;


// from
@property (nonatomic,strong) UILabel *fromTitleLbl;
@property (nonatomic,strong) UILabel *fromContentLbl;
// to
@property (nonatomic,strong) UILabel *toTitleLbl;
@property (nonatomic,strong) UILabel *toContentLbl;
// time
@property (nonatomic,strong) UILabel *timeTitleLbl;
@property (nonatomic,strong) UILabel *timeContentLbl;
// remark
@property (nonatomic,strong) UILabel *remarkTitleLbl;
@property (nonatomic,strong) UILabel *remarkContentLbl;

//忽略按钮
@property (nonatomic,strong) UIButton *ignoreButton;
//同意按钮
@property (nonatomic,strong) UIButton *agreeButton;

@property (nonatomic, assign) CGSize size1;
@property (nonatomic, assign) CGSize size2;
@property (nonatomic, assign) CGSize size3;
@property (nonatomic, assign) CGSize size4;
@end

NS_ASSUME_NONNULL_END
