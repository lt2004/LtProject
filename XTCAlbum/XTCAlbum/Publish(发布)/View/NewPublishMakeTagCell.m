//
//  NewPublishMakeTagCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/3/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "NewPublishMakeTagCell.h"

@implementation NewPublishMakeTagCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createNewPublishMakeTagCellUI];
    }
    return self;
}

- (void)createNewPublishMakeTagCellUI {
    _selectSystemStr = @"";
    _showArray = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 0, 0);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 8;
    flowLayout.minimumInteritemSpacing = 8;
    _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _tagCollectionView.delegate = self;
    _tagCollectionView.dataSource = self;
    _tagCollectionView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_tagCollectionView];
    [_tagCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [_tagCollectionView registerClass:[NewPublishMakeTagCollectionViewCell class] forCellWithReuseIdentifier:@"NewPublishMakeTagCollectionViewCellName"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _showArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NewPublishMakeTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewPublishMakeTagCollectionViewCellName" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.tagLabel.text = _showArray[indexPath.item];
    if (_publishTagType == NewPublishTagSystemType) {
        if ([_showArray[indexPath.item] isEqualToString:_selectSystemStr]) {
            cell.tagLabel.backgroundColor = HEX_RGB(0x8FDA3C); // 8FDA3C
        } else {
            cell.tagLabel.backgroundColor = kTableviewColor;
        }
    } else {
        cell.tagLabel.backgroundColor = kTableviewColor;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tagStr = _showArray[indexPath.item];
    CGRect rect = [tagStr boundingRectWithSize:CGSizeMake(kScreenWidth*0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:12]} context:nil];
    
    return CGSizeMake(rect.size.width+15, 25);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_publishTagType == NewPublishTagSelectType) {
        if (self.deleteSelectTagCallback) {
            self.deleteSelectTagCallback(_showArray[indexPath.item]);
        }
    } else if (_publishTagType == NewPublishTagSystemType) {
        if ([_showArray[indexPath.item] isEqualToString:_selectSystemStr]) {
            if (self.deleteSelectTagCallback) {
                self.deleteSelectTagCallback(_showArray[indexPath.item]);
            }
        } else {
            if (self.addSelectTagCallback) {
                self.addSelectTagCallback(_showArray[indexPath.item]);
            }
        }
    } else {
        if (self.addSelectTagCallback) {
            self.addSelectTagCallback(_showArray[indexPath.item]);
        }
    }
}

- (void)loadAboutData:(NSMutableArray *)flagShowArray {
    _showArray = flagShowArray;
    [_tagCollectionView reloadData];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
