//
//  UserSearchTagsCell.m
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "UserSearchTagsCell.h"

@implementation UserSearchTagsCell
@synthesize tagCollectionView = _tagCollectionView;
@synthesize tagArray = _tagArray;
@synthesize isEdit = _isEdit;
@synthesize isMayAddTag = _isMayAddTag;

- (void)awakeFromNib {
    [super awakeFromNib];
    _tagCollectionView.delegate = self;
    _tagCollectionView.dataSource = self;
    _tagCollectionView.bounces = NO;
    
    UICollectionViewFlowLayout *userFlowLayOut = [[UICollectionViewFlowLayout alloc] init];
    userFlowLayOut.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    userFlowLayOut.minimumLineSpacing = 5;
    userFlowLayOut.minimumInteritemSpacing = 5;
    userFlowLayOut.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _tagCollectionView.collectionViewLayout = userFlowLayOut;
    [_tagCollectionView registerClass:[UserSearchTagCollectionViewCell class] forCellWithReuseIdentifier:@"UserSearchTagCollectionViewCellName"];
    
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    [_tagCollectionView addGestureRecognizer:_longPress];
    
    if (@available(iOS 11.0, *)) {
        _tagCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_tagArray) {
        return _tagArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserSearchTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserSearchTagCollectionViewCellName" forIndexPath:indexPath];
    cell.tagLabel.layer.borderWidth = 0.5;
    cell.tagLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.tagLabel.layer.cornerRadius = 15;
    cell.tagLabel.layer.masksToBounds = YES;
    NSString *flagTagString = _tagArray[indexPath.row];
    cell.tagLabel.text = flagTagString;
    if (_isEdit) {
        cell.delButton.hidden = NO;
    } else {
        cell.delButton.hidden = YES;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth-50)*0.25, 35);
    
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
    id objc = [_tagArray objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [_tagArray removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [_tagArray insertObject:objc atIndex:destinationIndexPath.item];
    [_tagCollectionView reloadData];
    
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEdit) {
        return YES;
    } else {
        return NO;;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isMayAddTag) {
        if (self.addUserTagCallabck) {
            self.addUserTagCallabck(_tagArray[indexPath.row]);
        } else {
            
        }
    } else {
        if (self.deleteUserTagCallabck) {
            self.deleteUserTagCallabck(_tagArray[indexPath.row]);
        }
    }
}

- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress
{
    if (_isEdit) {
        switch (_longPress.state) {
            case UIGestureRecognizerStateBegan: {
                {
                    NSIndexPath *selectIndexPath = [_tagCollectionView indexPathForItemAtPoint:[_longPress locationInView:_tagCollectionView]];
                    [_tagCollectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
                }
                break;
            }
            case UIGestureRecognizerStateChanged: {
                [_tagCollectionView updateInteractiveMovementTargetPosition:[longPress locationInView:_longPress.view]];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                [_tagCollectionView endInteractiveMovement];
                break;
            }
            default: [_tagCollectionView cancelInteractiveMovement];
                break;
        }
    } else {
        
    }
}


- (void)insertDataToCell:(NSMutableArray *)tagArray {
    _tagArray = tagArray;
    [_tagCollectionView reloadData];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
