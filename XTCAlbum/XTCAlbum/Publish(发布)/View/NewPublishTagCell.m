//
//  NewPublishTagCell.m
//  vs
//
//  Created by Mac on 2018/11/27.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "NewPublishTagCell.h"

@implementation NewPublishTagCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        DetailTagFlowLayout *flowLayOut = [[DetailTagFlowLayout alloc] init];
        flowLayOut.minimumLineSpacing = 3;
        _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayOut];
        [self.contentView addSubview:_tagCollectionView];
        _tagCollectionView.delegate = self;
        _tagCollectionView.dataSource = self;
        _tagCollectionView.backgroundColor = [UIColor clearColor];
        
        [_tagCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(10);
            make.right.equalTo(self.contentView).with.offset(-10);
            make.top.equalTo(self.contentView).with.offset(5);
            make.bottom.equalTo(self.contentView).with.offset(-5);
        }];
        [_tagCollectionView registerClass:[DetailTagCell class] forCellWithReuseIdentifier:@"UICollectionViewCellName"];
    }
    return self;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_tagArray) {
        return 1;
    } else {
        return 0;
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tagArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellName" forIndexPath:indexPath];
    cell.tagLabel.text = _tagArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 27);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}

- (void)loadTagData:(NSArray *)flagTagArray {
    _tagArray = flagTagArray;
    [_tagCollectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
