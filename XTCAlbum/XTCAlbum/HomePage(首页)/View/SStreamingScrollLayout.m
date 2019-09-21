//
//  SStreamingScrollLayout.m
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/5.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import "SStreamingScrollLayout.h"

@interface SStreamingScrollLayout ()
/// The delegate will point to collection view's delegate automatically.
@property (nonatomic, weak) id <SStreamingCollectionViewDelegateLayout> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *rowWidths;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;
@end


@implementation SStreamingScrollLayout
/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

static CGFloat NBZFloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

#pragma mark - Public Accessors
- (void)setRowCount:(NSInteger)rowCount {
    if (_rowCount != rowCount) {
        _rowCount = rowCount;
        [self invalidateLayout];
    }
}

- (void)setMinimumRowSpacing:(CGFloat)minimumRowSpacing {
    if (_minimumRowSpacing != minimumRowSpacing) {
        _minimumRowSpacing = minimumRowSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    if (_minimumInteritemSpacing != minimumInteritemSpacing) {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

- (NSInteger)rowCountForSection:(NSInteger)section {
    return self.rowCount;
}

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section {
    //    UIEdgeInsets sectionInset = self.sectionInset;
    //    CGFloat width = self.collectionView.frame.size.width - sectionInset.left - sectionInset.right;
    //    NSInteger columnCount = [self rowCountForSection:section];
    //    return NBZFloorCGFloat((width - (columnCount - 1) * self.minimumRowSpacing) / columnCount);
    NSAssert(NO, @"不应该进到这里来哟");
    return 0;
}

#pragma mark - Private Accessors
- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableArray *)rowWidths {
    if (!_rowWidths) {
        _rowWidths = [NSMutableArray array];
    }
    return _rowWidths;
}

- (NSMutableArray *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

- (id <SStreamingCollectionViewDelegateLayout> )delegate {
    return (id <SStreamingCollectionViewDelegateLayout> )self.collectionView.delegate;
}

#pragma mark - Init
- (void)commonInit {
    _rowCount = 2;
    _minimumRowSpacing = 10;
    _minimumInteritemSpacing = 10;
    _sectionInset = UIEdgeInsetsZero;
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}


#pragma mark - Methods to Override
- (void)prepareLayout {
    
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    NSAssert([self.delegate conformsToProtocol:@protocol(SStreamingCollectionViewDelegateLayout)], @"UICollectionView's delegate should conform to NBZStreamingCollectionViewDelegateLayout protocol");
    NSAssert(self.rowCount > 0, @"NBZStreamingCollectionViewDelegateLayout rowCount should be greater than 0");
    
    // Initialize variables
    NSInteger idx = 0;
    
    [self.unionRects removeAllObjects];
    [self.rowWidths removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger rowCount = [self rowCountForSection:section];
        NSMutableArray *widths = [NSMutableArray arrayWithCapacity:rowCount];
        for (idx = 0; idx < rowCount; idx++) {
            [widths addObject:@(self.sectionInset.left)];
        }
        [self.rowWidths addObject:widths];
    }
    // Create attributes
    UICollectionViewLayoutAttributes *attributes;
    
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        
        //可用容器高度，算出CELL可用的高度itemHeight
        CGFloat height = self.containerHeight - self.sectionInset.top - self.sectionInset.bottom;
        NSInteger rowCount = [self rowCountForSection:section];
        CGFloat itemHeight = NBZFloorCGFloat((height - (rowCount - 1) * self.minimumRowSpacing) / rowCount);
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        //Item放到最短的行的.
        for (idx = 0; idx < itemCount; idx++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            NSUInteger rowIndex = [self nextRowIndexForItem:idx inSection:section];  //找到最短的那个row
            CGFloat xOffset = [self.rowWidths[section][rowIndex] floatValue];
            CGFloat yOffset = self.sectionInset.top + (itemHeight + self.minimumRowSpacing) * rowIndex;
            //NSLog(@"x:%f, y:%f", xOffset, yOffset);
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat itemWidth = 0;
            if (itemSize.height > 0 && itemSize.width > 0) {
                //W = w/h * H
                itemWidth = NBZFloorCGFloat(itemSize.width * itemHeight / itemSize.height);
            }
            
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            self.rowWidths[section][rowIndex] = @(CGRectGetMaxX(attributes.frame) + self.minimumInteritemSpacing);
        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)
    
    // Build union rects
    idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = self.containerHeight;
    
    NSUInteger rowIndex = [self longestColumnIndexInSection:0];
    CGFloat xOffset = [self.rowWidths[0][rowIndex] floatValue];
    contentSize.width = xOffset;
    if (contentSize.width<self.collectionView.bounds.size.width) {
        contentSize.width = self.collectionView.bounds.size.width + 50;
    }
    //NSLog(@"content size:%@", NSStringFromCGSize(contentSize));
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count]) {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    CGRect oldBounds = self.collectionView.bounds;
    
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods

/**
 *  Find the shortest row.
 *
 *  @return index for the shortest row
 */
- (NSUInteger)shortestRowIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat shortestWidth = MAXFLOAT;
    
    [self.rowWidths[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat width = [obj floatValue];
        if (width < shortestWidth) {
            shortestWidth = width;
            index = idx;
        }
    }];
    
    return index;
}

/**
 *  Find the longest row.
 *
 *  @return index for the longest row
 */
- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat longestWidth = 0;
    
    [self.rowWidths[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat width = [obj floatValue];
        if (width > longestWidth) {
            longestWidth = width;
            index = idx;
        }
    }];
    
    return index;
}

/**
 *  Find the index for the next column.
 *
 *  @return index for the next column
 */
- (NSUInteger)nextRowIndexForItem:(NSInteger)item inSection:(NSInteger)section {
    NSUInteger index = 0;
    index = [self shortestRowIndexInSection:section];
    return index;
}

@end
