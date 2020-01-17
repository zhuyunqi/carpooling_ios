//
//  GoodsCollectionCell.h
//  BanTang
//
//  Created by liaoyp on 15/4/13.
//  Copyright (c) 2015年 JiuZhouYunDong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPContractMJModel, CPScheduleMJModel;

@protocol HorizonItemCellDelegate <NSObject>
@optional
-(void)horizonItemCellMatchingByIndexPath:(NSIndexPath*)indexPath;
-(void)horizonItemCellNaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface HorzonItemCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *fromLbl;
@property (weak, nonatomic) IBOutlet UILabel *toLbl;
@property (weak, nonatomic) IBOutlet UILabel *fromMarkLbl;
@property (weak, nonatomic) IBOutlet UILabel *toMarkLbl;
@property (weak, nonatomic) IBOutlet UIButton *matchingBtn;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) CPContractMJModel *contractModel;
@property (nonatomic, strong) CPScheduleMJModel *scheduleModel;
@property (nonatomic, weak) id<HorizonItemCellDelegate> delegate;
@end
