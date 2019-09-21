//
//  XTCVerticalStreamLayout.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCVerticalStreamLayout.h"


@interface XTCVerticalStreamLayout () {
    
}

@property (nonatomic, weak) id <VerticalStreamDelegateLayout> delegate;
@property (nonatomic, strong) NSMutableArray *rowWidths;
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
@property (nonatomic, strong) NSMutableArray *unionRects;

@end


@implementation XTCVerticalStreamLayout

static const NSInteger unionSize = 20;

static CGFloat NBZFloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

#pragma mark - Init
- (void)commonInit {
    _horizontalRowCount = 3;
    _verticalRowCount = 1;
    _minimumRowSpacing = 10;
    _minimumInteritemSpacing = 10;
    _sectionInset = UIEdgeInsetsZero;
    _isPriorityHorizontal = YES;
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

- (void)setVerticalRowCount:(NSInteger)verticalRowCount {
    if (_verticalRowCount != verticalRowCount) {
        _verticalRowCount = verticalRowCount;
        [self invalidateLayout];
    }
}

- (void)setHorizontalRowCount:(NSInteger)horizontalRowCoun {
    if (_horizontalRowCount != horizontalRowCoun) {
        _horizontalRowCount = horizontalRowCoun;
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
    if (section == 0) {
        if (_isPriorityHorizontal) {
            return self.horizontalRowCount;
        } else {
            return self.verticalRowCount;
        }
    } else {
        if (_isPriorityHorizontal) {
            return self.verticalRowCount;
        } else {
            return self.horizontalRowCount;
        }
    }
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

- (id <VerticalStreamDelegateLayout> )delegate {
    return (id <VerticalStreamDelegateLayout> )self.collectionView.delegate;
}


#pragma mark - Methods to Override
- (void)prepareLayout {
    
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    /*
     NSAssert([self.delegate conformsToProtocol:@protocol(SStreamingCollectionViewDelegateLayout)], @"UICollectionView's delegate should conform to NBZStreamingCollectionViewDelegateLayout protocol");
     NSAssert(self.rowCount > 0, @"NBZStreamingCollectionViewDelegateLayout rowCount should be greater than 0");
     */
    
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
    
    UICollectionViewLayoutAttributes *attributes;
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        if (section == 0) {
            [self createTopsectionItemAttributes:attributes];
        } else {
            [self createBottomsectionItemAttributes:attributes];
        }
    }
    
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

- (void)createTopsectionItemAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat topContainerHeight = 0.0;
    CGFloat flagContainerHeight = self.containerHeight - self.sectionInset.top - self.sectionInset.bottom;
    CGFloat standardItemHeight = NBZFloorCGFloat((flagContainerHeight-(self.verticalRowCount+self.horizontalRowCount-1)*self.minimumRowSpacing)/(1.5*self.verticalRowCount + self.horizontalRowCount));
    if (_isPriorityHorizontal) {
        topContainerHeight = standardItemHeight*self.horizontalRowCount+(self.horizontalRowCount-1)*self.minimumRowSpacing;
    } else {
        topContainerHeight = standardItemHeight*self.verticalRowCount+(self.verticalRowCount-1)*self.minimumRowSpacing;
    }
    NSInteger rowCount = [self rowCountForSection:0];
    CGFloat itemHeight = NBZFloorCGFloat((topContainerHeight - (rowCount - 1) * self.minimumRowSpacing) / rowCount);
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
    
    //Item放到最短的行的.
    for (NSInteger idx = 0; idx < itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        NSUInteger rowIndex = [self nextRowIndexForItem:idx inSection:0];  //找到最短的那个row
        CGFloat xOffset = [self.rowWidths[0][rowIndex] floatValue];
        CGFloat yOffset = self.sectionInset.top + (itemHeight + self.minimumRowSpacing) * rowIndex;
        CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        CGFloat itemWidth = 0;
        if (itemSize.height > 0 && itemSize.width > 0) {
            itemWidth = NBZFloorCGFloat(itemSize.width * itemHeight / itemSize.height);
        }
        
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
        [itemAttributes addObject:attributes];
        [self.allItemAttributes addObject:attributes];
        self.rowWidths[0][rowIndex] = @(CGRectGetMaxX(attributes.frame) + self.minimumInteritemSpacing);
    }
    [self.sectionItemAttributes addObject:itemAttributes];
}

- (void)createBottomsectionItemAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat topContainerHeight = 0.0;
    CGFloat bottomContainerHeight = 0.0;
    CGFloat flagContainerHeight = self.containerHeight - self.sectionInset.top - self.sectionInset.bottom;
    CGFloat standardItemHeight = NBZFloorCGFloat((flagContainerHeight-(self.verticalRowCount+self.horizontalRowCount-1)*self.minimumRowSpacing)/(1.5*self.verticalRowCount + self.horizontalRowCount));
    if (_isPriorityHorizontal) {
        topContainerHeight = standardItemHeight*self.horizontalRowCount+(self.horizontalRowCount-1)*self.minimumRowSpacing;
    } else {
        topContainerHeight = standardItemHeight*self.verticalRowCount+(self.verticalRowCount-1)*self.minimumRowSpacing;
    }
    bottomContainerHeight = flagContainerHeight-topContainerHeight-self.minimumRowSpacing;
    CGFloat itemHeight = standardItemHeight*1.5;
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:1];
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
    
    //Item放到最短的行的.
    for (NSInteger idx = 0; idx < itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:1];
        NSUInteger rowIndex = [self nextRowIndexForItem:idx inSection:1];  //找到最短的那个row
        CGFloat xOffset = [self.rowWidths[1][rowIndex] floatValue];
        CGFloat yOffset = self.sectionInset.top + topContainerHeight + self.minimumRowSpacing + (itemHeight + self.minimumRowSpacing) * rowIndex;
        CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        CGFloat itemWidth = 0;
        if (itemSize.height > 0 && itemSize.width > 0) {
            itemWidth = itemSize.width * itemHeight / itemSize.height;
        }
        
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
        [itemAttributes addObject:attributes];
        [self.allItemAttributes addObject:attributes];
        self.rowWidths[1][rowIndex] = @(CGRectGetMaxX(attributes.frame) + self.minimumInteritemSpacing);
    }
    [self.sectionItemAttributes addObject:itemAttributes];
}

- (CGSize)collectionViewContentSize {
    // 如果一共0个section，没有滚动范围
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = self.containerHeight;
    
    
    // 横竖两个section
    NSUInteger rowTopIndex = [self longestColumnIndexInSection:0];
    CGFloat xTopOffset = [self.rowWidths[0][rowTopIndex] floatValue];
    
    // 获取到c比较长的那一行
    NSUInteger rowBottomIndex = [self longestColumnIndexInSection:1];
    CGFloat xBottomOffset = [self.rowWidths[1][rowBottomIndex] floatValue];
    if (xTopOffset >= xBottomOffset) {
        contentSize.width = xTopOffset;
    } else {
        contentSize.width = xBottomOffset;
    }
    
    if (contentSize.width<self.collectionView.bounds.size.width) {
        contentSize.width = self.collectionView.bounds.size.width + 50;
    }
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


- (NSUInteger)nextRowIndexForItem:(NSInteger)item inSection:(NSInteger)section {
    NSUInteger index = 0;
    index = [self shortestRowIndexInSection:section];
    return index;
}

@end
