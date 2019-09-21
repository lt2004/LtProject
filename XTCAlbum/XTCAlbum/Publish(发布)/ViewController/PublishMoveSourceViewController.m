//
//  PublishMoveSourceViewController.m
//  ViewSpeaker
//
//  Created by Mac on 2019/2/18.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PublishMoveSourceViewController.h"

@interface PublishMoveSourceViewController () {
    UILongPressGestureRecognizer *_longPress;
}

@end

@implementation PublishMoveSourceViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _finishButton.layer.cornerRadius = 16;
    _finishButton.layer.masksToBounds = YES;
    [_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _sourceArray = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    flowLayout.itemSize = CGSizeMake((kScreenWidth-60)*0.25, (kScreenWidth-60)*0.25);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _sourceCollectionView.collectionViewLayout = flowLayout;
    _sourceCollectionView.backgroundColor = [UIColor clearColor];
    _sourceCollectionView.delegate = self;
    _sourceCollectionView.dataSource = self;
    [_sourceCollectionView registerClass:[PublishMoveSourceCell class] forCellWithReuseIdentifier:@"PublishMoveSourceCellName"];
    
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    [_sourceCollectionView addGestureRecognizer:_longPress];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PublishSourceModel *flagSource = _sourceArray[indexPath.item];
    PublishMoveSourceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PublishMoveSourceCellName" forIndexPath:indexPath];
    cell.sourceImageView.image = flagSource.sourceImage;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
    PublishSourceModel *publishSourceModel = _sourceArray[sourceIndexPath.item];
    //从资源数组中移除该数据
    [_sourceArray removeObject:publishSourceModel];
    //将数据插入到资源数组中的目标位置上
    [_sourceArray insertObject:publishSourceModel atIndex:(int)destinationIndexPath.item];
    dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
    dispatch_after(showTime, dispatch_get_main_queue(), ^{
        [self.sourceCollectionView reloadData];
    });
    
    
}


- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress
{
    switch (_longPress.state) {
        case UIGestureRecognizerStateBegan: {
            {
                NSIndexPath *selectIndexPath = [_sourceCollectionView indexPathForItemAtPoint:[_longPress locationInView:_sourceCollectionView]];
                if (selectIndexPath.row >= _sourceArray.count) {
                    
                } else {
                    [_sourceCollectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [_sourceCollectionView updateInteractiveMovementTargetPosition:[longPress locationInView:_longPress.view]];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            NSIndexPath *selectIndexPath = [_sourceCollectionView indexPathForItemAtPoint:[_longPress locationInView:_sourceCollectionView]];
            if (selectIndexPath.row == _sourceArray.count || selectIndexPath == nil) {
                [_sourceCollectionView cancelInteractiveMovement];
            } else {
                [_sourceCollectionView endInteractiveMovement];
            }
            break;
        }
        default: [_sourceCollectionView cancelInteractiveMovement];
            break;
    }
}

- (IBAction)cancelButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)finishButtonClick {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.publishSortCallBack) {
            self.publishSortCallBack(self.sourceArray);
        }
    }];
}

- (void)dealloc {
    DDLogInfo(@"发布资源交换界面内存释放");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
