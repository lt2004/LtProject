//
//  HomeStreamLayout.h
//  vs
//
//  Created by Mac on 2018/8/31.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBZStreamingScrollLayout.h"

#pragma mark - Delegate
@protocol HomeStreamLayoutDelegateLayout <UICollectionViewDelegate>
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

@interface HomeStreamLayout : UICollectionViewLayout

@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) CGFloat minimumRowSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) BOOL isTakeUserWidth; // 是否带上侧边用户宽度

@property (nonatomic) CGFloat containerHeight;

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section;

@end
