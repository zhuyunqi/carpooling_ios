//
//  CPContractDetailCell5.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailCell5.h"
#import "CPContractDetailCell5CollectionViewCell.h"
#import "CPContractDetailCell5CollectionViewFlowLayout.h"
#import "CPContractMJModel.h"

@interface CPContractDetailCell5 ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CPContractDetailCell5CollectionViewFlowLayout *flowLayout;
@end

@implementation CPContractDetailCell5

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    
    _collectionView.scrollEnabled = false;
    _selectLimitCount = 0;
}

- (void)setContractModel:(CPContractMJModel *)contractModel{
    if (_contractModel != contractModel) {
        _contractModel = contractModel;
        
    }
}

- (void)setNoticeTitleItems:(NSArray *)noticeTitleItems{
    if (_noticeTitleItems != noticeTitleItems) {
        _noticeTitleItems = noticeTitleItems;
        
        [self.collectionView reloadData];
    }
}

- (void)setNoticeTag:(NSMutableArray *)noticeTag{
    if (_noticeTag != noticeTag) {
        _noticeTag = noticeTag;
        
        [self.collectionView reloadData];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.noticeTitleItems.count;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CPContractDetailCell5CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPContractDetailCell5CollectionViewCell" forIndexPath:indexPath];
    NSInteger tag = [[self.noticeTag objectAtIndex:indexPath.row] integerValue];
    if (tag == -1) {
        cell.customSelect = NO;
    }
    else {
        cell.customSelect = YES;
    }
    cell.textLbl.numberOfLines = 1;
    cell.textLbl.text = self.noticeTitleItems[indexPath.row];
    return cell;
}



#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kMinimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kMinimumInteritemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text = _noticeTitleItems[indexPath.item];
    return [self calculateCellSize:text];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, CGFLOAT_MIN);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"CPContractDetailCell5 collectionView didSelectItemAtIndexPath indexPath.row:%ld", (long)indexPath.row);
    
    if (indexPath.row == 0) {// the day before
        NSComparisonResult result = [self compareNowAndBeginDateIfDayBefore:YES ifSameday:NO ifBeforeOneHour:NO ifBeforeTenMinute:NO];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            [self processCellSelectWithIndexPath:indexPath];
            
        }
        else {
            [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Contract has expired", @"CPLocalizable")];
        }
        
    }
    else if (indexPath.row == 1) {// same day
        NSComparisonResult result = [self compareNowAndBeginDateIfDayBefore:NO ifSameday:YES ifBeforeOneHour:NO ifBeforeTenMinute:NO];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            [self processCellSelectWithIndexPath:indexPath];
            
        }
        else {
            [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Contract has expired", @"CPLocalizable")];
        }
        
    }
    else if (indexPath.row == 2) {// one hour ago
        NSComparisonResult result = [self compareNowAndBeginDateIfDayBefore:NO ifSameday:NO ifBeforeOneHour:YES ifBeforeTenMinute:NO];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            [self processCellSelectWithIndexPath:indexPath];
            
        }
        else {
            [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Contract has expired", @"CPLocalizable")];
        }
        
    }
    else if (indexPath.row == 3) {// ten minutes ago
        NSComparisonResult result = [self compareNowAndBeginDateIfDayBefore:NO ifSameday:NO ifBeforeOneHour:NO ifBeforeTenMinute:YES];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            [self processCellSelectWithIndexPath:indexPath];
            
        }
        else {
            [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Contract has expired", @"CPLocalizable")];
        }
    }
}

//计算cell size
- (CGSize)calculateCellSize:(NSString *)content {
    //获取文字的宽度
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f]};
    CGSize size = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, kItemHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    size.height = kItemHeight;
    size.width = floorf(size.width+20);
    return size;
}

#pragma mark - compareNowAndBeginDate if the day before
- (NSComparisonResult)compareNowAndBeginDateIfDayBefore:(BOOL)compareDayBefore
                                              ifSameday:(BOOL)sameday
                                        ifBeforeOneHour:(BOOL)beforeOneHour
                                      ifBeforeTenMinute:(BOOL)beforeTenMinute
{
    
    NSComparisonResult result;
    NSDate *beginDate;
    NSDate *date = [NSDate date];
    if (self.contractModel.contractType == 0) {// short term
        beginDate = [Utils stringToDate:self.contractModel.beginTime withDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    else if (self.contractModel.contractType == 1) {// long term
        beginDate = [Utils stringToDate:[NSString stringWithFormat:@"%@ %@", self.contractModel.endDate, self.contractModel.beginTime] withDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    if (compareDayBefore) {
        NSDate *dayBefore = [beginDate dateByAddingTimeInterval:-86400];
        return result = [date compare:dayBefore];
    }
    else if (sameday) {// 3 hour
        NSDate *dayBeforeThreeHour = [beginDate dateByAddingTimeInterval:-10800];
        return result = [date compare:dayBeforeThreeHour];
    }
    else if (beforeOneHour) {
        NSDate *dayBeforeOneHour = [beginDate dateByAddingTimeInterval:-3600];
        return result = [date compare:dayBeforeOneHour];
    }
    else if (beforeTenMinute) {
        NSDate *dayBeforeTenMinute = [beginDate dateByAddingTimeInterval:-600];
        return result = [date compare:dayBeforeTenMinute];
    }
    
    return result = [date compare:beginDate];
}

- (void)processCellSelectWithIndexPath:(NSIndexPath*)indexPath{
    CPContractDetailCell5CollectionViewCell *cell = (CPContractDetailCell5CollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (_selectLimitCount < 2) {
        cell.customSelect = !cell.customSelect;
        BOOL select = cell.customSelect;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidSelectItemAtIndex:isSelect:)]) {
            [self.delegate collectionViewDidSelectItemAtIndex:indexPath isSelect:select];
        }
        
        if (select) {
            _selectLimitCount += 1;
        }
        else {
            _selectLimitCount -= 1;
        }
        
    }
    else if (_selectLimitCount == 2) {
        if (cell.customSelect) {
            cell.customSelect = !cell.customSelect;
            BOOL select = cell.customSelect;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidSelectItemAtIndex:isSelect:)]) {
                [self.delegate collectionViewDidSelectItemAtIndex:indexPath isSelect:select];
            }
            _selectLimitCount -= 1;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
