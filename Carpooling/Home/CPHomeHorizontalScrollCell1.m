//
//  CPHomeHorizontalScrollCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPHomeHorizontalScrollCell1.h"
#import "HorzonItemCell.h"

#define BUBBLE_DIAMETER     (kSCREENWIDTH-40)
#define BUBBLE_PADDING      20.0

@interface CPHomeHorizontalScrollCell1 ()<HorizonItemCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@end

@implementation CPHomeHorizontalScrollCell1{
    NSInteger _selectIndex;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configCollectionView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configCollectionView];
        
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configCollectionView];
    }
    return self;
    
}
- (void)configCollectionView
{
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        _collectionView.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    
    //    snapToMostVisibleColumnVelocityThreshold = 0.3;
    
    CGFloat itemWidth = MIN(_collectionView.bounds.size.width - 20, 400);
    //设置单元格大小
    self.layout.itemSize = CGSizeMake(itemWidth, 125);
}

- (void)reloadData
{
    [_collectionView reloadData];
}

- (void)setItemSize:(CGSize)itemSize{
    _itemSize = itemSize;
}

- (void)setItemsArray:(NSArray *)itemsArray{
//    if (_itemsArray != itemsArray) {
        _itemsArray = itemsArray;
        
        [self reloadData];
//    }
}

#pragma mark - UICollectionView data source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.itemsArray.count - 1) {
        return CGSizeMake(self.itemSize.width, self.itemSize.height);
    }
    return self.itemSize;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HorzonItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HorzonItemCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.contractModel = [self.itemsArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HorizontalScrollCell indexPath.row:%ld", (long)indexPath.row);
    if (self.delegate && [self.delegate respondsToSelector:@selector(horizontalScrollCell1ClickIndexPath:)]) {
        [self.delegate horizontalScrollCell1ClickIndexPath:indexPath];
    }
}





- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    UICollectionViewFlowLayout *layout = self.layout;
    CGRect bounds = scrollView.bounds;
    CGFloat xTarget = targetContentOffset->x;
    
    NSLog(@"scrollViewWillEndDragging:withVelocity velocity.x:%f, xTarget:%f", velocity.x, xTarget);
    if (fabs(velocity.x) <= 0.1) {
        CGFloat xCenter = BUBBLE_DIAMETER/2;
        
        NSArray *poses = [layout layoutAttributesForElementsInRect:bounds];
        
        CGFloat x = 0;
        if (poses.count > 0) {
            
            NSMutableArray *tmpArr = @[].mutableCopy;
            for (int i = 0; i < poses.count; i++) {
                UICollectionViewLayoutAttributes *attr = [poses objectAtIndex:i];
                [tmpArr addObject:[NSNumber numberWithFloat:fabs(attr.center.x - xCenter)]];
            }
            
            CGFloat max_number = 0;
            int max_index = 0;
            CGFloat min_number = 0;
            int min_index = 0;
            
            for (int i = 0; i<tmpArr.count; i++) {
                //取最大值和最大值的对应下标
                CGFloat a = [tmpArr[i] floatValue];
                if (a > max_number) {
                    max_index = i;
                }
                max_number = (a > max_number) ? a : max_number;
                
                //取最小值和最小值的对应下标
                CGFloat b = [tmpArr[i] floatValue];
                if (b < min_number) {
                    min_index = i;
                }
                min_number = (b < min_number) ? b : min_number;
            }
            
            NSLog(@"tmpArr:%@", tmpArr);
            
            CGPoint targetOffset = [self nearestTargetOffsetForOffset:*targetContentOffset];
            targetContentOffset->x = targetOffset.x;
            
            NSLog(@"fabs(velocity.x) <= 0.3 poses:%@, x:%f", poses, x);
        }
        
        
        
    } else if (velocity.x > 0) {
        
        NSArray *poses = [layout layoutAttributesForElementsInRect:CGRectMake(xTarget, 0, bounds.size.width, bounds.size.height)];
        
        CGFloat x = 0;
        if (poses.count > 0) {
            
            NSMutableArray *tmpArr = @[].mutableCopy;
            for (int i = 0; i < poses.count; i++) {
                UICollectionViewLayoutAttributes *attr = [poses objectAtIndex:i];
                [tmpArr addObject:[NSNumber numberWithFloat:attr.center.x]];
            }
            
            CGFloat max_number = 0;
            int max_index = 0;
            for (int i = 0; i<tmpArr.count; i++) {
                //取最大值和最大值的对应下标
                CGFloat a = [tmpArr[i] floatValue];
                if (a > max_number) {
                    max_index = i;
                }
                max_number = (a > max_number) ? a : max_number;
            }
            
            UICollectionViewLayoutAttributes *attr = [poses objectAtIndex:max_index];
            x = attr.frame.origin.x;
            
            NSLog(@"velocity.x > 0 poses:%@, x:%f, xTarget:%f", poses, x, xTarget);
            if (xTarget > x) {
                
            }
            else{
                targetContentOffset->x = MAX(x, 0);
            }
        }
        
        
        
    } else {
        NSArray *poses = [layout layoutAttributesForElementsInRect:CGRectMake(xTarget - bounds.size.width, 0, bounds.size.width, bounds.size.height)];
        
        CGFloat x = 0;
        if (poses.count > 0) {
            NSMutableArray *tmpArr = @[].mutableCopy;
            for (int i = 0; i < poses.count; i++) {
                UICollectionViewLayoutAttributes *attr = [poses objectAtIndex:i];
                [tmpArr addObject:[NSNumber numberWithFloat:attr.center.x]];
            }
            
            CGFloat max_number = 0;
            int max_index = 0;
            for (int i = 0; i<tmpArr.count; i++) {
                //取最大值和最大值的对应下标
                CGFloat a = [tmpArr[i] floatValue];
                if (a > max_number) {
                    max_index = i;
                }
                max_number = (a > max_number) ? a : max_number;
            }
            
            UICollectionViewLayoutAttributes *attr = [poses objectAtIndex:max_index];
            x = attr.frame.origin.x;
            
            
            NSLog(@"else poses:%@, x:%f", poses, x);
            
            targetContentOffset->x = MAX(x, 0);
        }
    }
}


- (CGPoint)nearestTargetOffsetForOffset:(CGPoint)offset
{
    CGFloat pageSize = BUBBLE_DIAMETER;
    NSInteger page = roundf(offset.x / pageSize);
    CGFloat targetX = pageSize * page;
    return CGPointMake(targetX, offset.y);
}

#pragma mark - HorizonItemCellDelegate
- (void)horizonItemCellNaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
    if (self.delegate && [self.delegate respondsToSelector:@selector(horizontalScrollCell1NaviAction:location:destination:)]) {
        [self.delegate horizontalScrollCell1NaviAction:indexPath location:coordinate destination:destination];
    }
}
@end
