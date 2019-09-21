//
//  SStreamingScrollLayout.h
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/5.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SStreamingScrollLayout;

#pragma mark - Delegate
@protocol SStreamingCollectionViewDelegateLayout <UICollectionViewDelegate>
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


@interface SStreamingScrollLayout : UICollectionViewLayout

@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) CGFloat minimumRowSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic) CGFloat containerHeight;

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section;

@end
