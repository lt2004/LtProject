//
//  NBZStreamingScrollLayout.h
//  viewspeaker
//
//  Created by Jacky on 1/16/15.
//  Copyright (c) 2015 XTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NBZStreamingScrollLayout;

#pragma mark - Delegate
@protocol NBZStreamingCollectionViewDelegateLayout <UICollectionViewDelegate>
@required
/**
 *  Asks the delegate for the size of the specified item’s cell.
 *
 *  @param collectionView
 *    The collection view object displaying the layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param indexPath
 *    The index path of the item.
 *
 *  @return
 *    The original size of the specified item. Both width and height must be greater than 0.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - NBZStreamingScrollLayout

@interface NBZStreamingScrollLayout : UICollectionViewLayout

@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) CGFloat minimumRowSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic) CGFloat containerHeight;

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section;

@end

