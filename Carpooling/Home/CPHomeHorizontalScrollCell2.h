//
//  CPHomeHorizontalScrollCell2.h
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPHomeHorizontalScrollCell2;

@protocol CPHomeHorizontalScrollCell2Delegate <NSObject>
@required
-(void)horizontalScrollCell2ClickIndexPath:(NSIndexPath*)indexPath;
-(void)horizontalScrollCell2MatchingByIndexPath:(NSIndexPath*)indexPath;
-(void)horizontalScrollCell2NaviAction:(NSIndexPath*)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString*)destination;
@end

@interface CPHomeHorizontalScrollCell2 : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) NSArray *itemsArray;

@property (nonatomic, weak) id<CPHomeHorizontalScrollCell2Delegate> delegate;
@end

NS_ASSUME_NONNULL_END
