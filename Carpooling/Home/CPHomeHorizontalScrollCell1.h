//
//  CPHomeHorizontalScrollCell1.h
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPHomeHorizontalScrollCell1;

@protocol CPHomeHorizontalScrollCell1Delegate <NSObject>
@required
-(void)horizontalScrollCell1ClickIndexPath:(NSIndexPath*)indexPath;
-(void)horizontalScrollCell1NaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface CPHomeHorizontalScrollCell1 : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) NSArray *itemsArray;

@property (nonatomic, weak) id<CPHomeHorizontalScrollCell1Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
