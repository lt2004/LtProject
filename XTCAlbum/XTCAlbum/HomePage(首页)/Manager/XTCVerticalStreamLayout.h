//
//  XTCVerticalStreamLayout.h
//  XTCAlbum
//
//  Created by Mac on 2019/8/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XTCVerticalStreamLayout;

#pragma mark - Delegate
@protocol VerticalStreamDelegateLayout <UICollectionViewDelegate>

@required
- (CGSize)collectionView:(UICollectionView *_Nullable)collectionView layout:(UICollectionViewLayout *_Nullable)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *_Nullable)indexPath;

@end



NS_ASSUME_NONNULL_BEGIN

@interface XTCVerticalStreamLayout : UICollectionViewLayout

@property (nonatomic, assign) BOOL isPriorityHorizontal; // 是否优先展示水平的
@property (nonatomic, assign) NSInteger verticalRowCount; // 垂直的行数
@property (nonatomic, assign) NSInteger horizontalRowCount; // 水平的行数

@property (nonatomic, assign) CGFloat minimumRowSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic) CGFloat containerHeight; // 容器高度 根据垂直和水平的 垂直的section高度  水平section高度

@end

NS_ASSUME_NONNULL_END
