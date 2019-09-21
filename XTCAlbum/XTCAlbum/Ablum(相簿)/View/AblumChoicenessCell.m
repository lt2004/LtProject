//
//  AblumChoicenessCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "AblumChoicenessCell.h"

@implementation AblumChoicenessCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createAblumChoicenessCellUI];
    }
    return self;
}

- (void)createAblumChoicenessCellUI {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 8;
    _ablumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _ablumCollectionView.backgroundColor = [UIColor whiteColor];
    _ablumCollectionView.delegate = self;
    _ablumCollectionView.dataSource = self;
    _ablumCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:_ablumCollectionView];
    [_ablumCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [_ablumCollectionView registerClass:[AblumChoicenessSubCell class] forCellWithReuseIdentifier:@"AblumChoicenessSubCellName"];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_ablumArray) {
        if (_ablumArray.count < 3) {
            return _ablumArray.count+1;
        } else {
            return _ablumArray.count;
        }
    } else {
       return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth-30)/3.0, (kScreenWidth-30)/3.0+50);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AblumChoicenessSubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AblumChoicenessSubCellName" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.item == _ablumArray.count) {
        cell.nameLabel.text = XTCLocalizedString(@"Album_Create_Choiceness_Album", nil);
        cell.photoCountLabel.text = @"";
        cell.asset = nil;
        cell.showImageView.image = nil;
        cell.defaultImageView.hidden = NO;
    } else {
        cell.defaultImageView.hidden = YES;
        AblumModel *ablumModel = _ablumArray[indexPath.item];
        cell.nameLabel.text = ablumModel.ablum_name;
        NSArray *flagArray = [ablumModel.ablum_source_paths componentsSeparatedByString:@","];
        NSMutableArray *flagCountArray = [[NSMutableArray alloc] init];
        for (NSString *flagStr in flagArray) {
            if (flagStr && flagStr.length) {
                [flagCountArray addObject:flagStr];
            } else {
                
            }
        }
        cell.photoCountLabel.text = [NSString stringWithFormat:@"%d", (int)flagCountArray.count];
        if (flagCountArray.count > 0) {
            cell.showImageView.image = nil;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:flagArray options:nil];
            cell.asset = fetchResult.firstObject;
            
        } else {
            cell.asset = nil;
            cell.showImageView.image = nil;
            cell.defaultImageView.hidden = NO;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == _ablumArray.count) {
        if (self.createChoicenessCallBack) {
            self.createChoicenessCallBack();
        } else {
            
        }
    } else {
        AblumModel *ablumModel = _ablumArray[indexPath.item];
        if (self.ablumChoicenessSelectCallBack) {
            self.ablumChoicenessSelectCallBack(ablumModel);
        } else {
            
        }
    }
}

- (void)loadAboutData:(NSArray *)flagArray {
    _ablumArray = flagArray;
    [_ablumCollectionView reloadData];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
