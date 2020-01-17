//
//  CPInitShortTermContractCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPInitShortTermContractCell1Delegate <NSObject>
@required
-(void)contractCellSelectPassengerType:(NSInteger)type;
@end

@interface CPInitShortTermContractCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UILabel *leftLbl;
@property (weak, nonatomic) IBOutlet UIImageView *leftImgV;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *rightLbl;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgV;
@property(nonatomic, assign) NSInteger passengerType;
@property (nonatomic, weak) id<CPInitShortTermContractCell1Delegate> delegate;

@end

NS_ASSUME_NONNULL_END
