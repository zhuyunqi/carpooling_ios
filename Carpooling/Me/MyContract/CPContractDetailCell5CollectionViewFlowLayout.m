//
//  CPContractDetailCell5CollectionViewFlowLayout.m
//  Carpooling
//
//  Created by bw on 2019/5/22.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPContractDetailCell5CollectionViewFlowLayout.h"
#import "CPContractDetailCell5CollectionReusableView.h"


//elementKind
NSString *decorationViewOfKind = @"decorationBgView";

@interface CPContractDetailCell5CollectionViewFlowLayout()
@property (strong, nonatomic) NSMutableArray *itemAttributes;
@end

@implementation CPContractDetailCell5CollectionViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.itemAttributes = [NSMutableArray new];
    NSInteger numberOfSection = self.collectionView.numberOfSections;
    for (int section = 0; section < numberOfSection; section++) {
        NSInteger lastIndex = [self.collectionView numberOfItemsInSection:section] - 1;
        CGRect frame = CGRectZero;
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewOfKind withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        attributes.zIndex = -1;
        NSLog(@"CPContractDetailCell5CollectionViewFlowLayout lastIndex:%ld", (long)lastIndex);
        
        UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:section]];
        
        frame = CGRectUnion(firstItem.frame, lastItem.frame);
        frame.origin.x -= self.sectionInset.left;
        frame.origin.y -= self.sectionInset.top;
        frame.size.width = self.collectionView.frame.size.width;
        frame.size.height += self.sectionInset.top + self.sectionInset.bottom;
        
        
        attributes.frame = frame;
        [self.itemAttributes addObject:attributes];
        [self registerClass:[CPContractDetailCell5CollectionReusableView class] forDecorationViewOfKind:decorationViewOfKind];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    //使cell紧随前一个
    for (int i = 1; i < [attributes count]; ++i) {
        //当前attributes
        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
        //上一个attributes
        UICollectionViewLayoutAttributes *prevLayoutAttributes = attributes[i - 1];
        //间距
        NSInteger maximumSpacing = kMinimumLineSpacing;
        //前一个cell的最右边
        NSInteger prevOrigin = CGRectGetMaxX(prevLayoutAttributes.frame);
//        NSLog(@"prevOrigin:%ld, i:%d", (long)prevOrigin, i);
//        NSLog(@"current width:%f", currentLayoutAttributes.frame.size.width);
//        NSLog(@"max width:%f", self.collectionViewContentSize.width - self.sectionInset.right);
        
        //需要做偏移
        if ((prevOrigin + maximumSpacing + currentLayoutAttributes.frame.size.width <= self.collectionViewContentSize.width - self.sectionInset.right) && currentLayoutAttributes.indexPath.section == prevLayoutAttributes.indexPath.section) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = prevOrigin + maximumSpacing;
//            NSLog(@"<= expect frame:%@", NSStringFromCGRect(frame));
            currentLayoutAttributes.frame = frame;
        }
        else if ((prevOrigin + maximumSpacing + currentLayoutAttributes.frame.size.width > self.collectionViewContentSize.width - self.sectionInset.right) && currentLayoutAttributes.indexPath.section == prevLayoutAttributes.indexPath.section) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = 0;
//            NSLog(@"> expect frame:%@", NSStringFromCGRect(frame));
            currentLayoutAttributes.frame = frame;
        }
    }
    
    for (UICollectionViewLayoutAttributes *attribute in self.itemAttributes){
        if (!CGRectIntersectsRect(rect, attribute.frame))
            continue;
        [attributes addObject:attribute];
    }
    return attributes;
}
@end
