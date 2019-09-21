//
//  PublishMoveSourceViewController.h
//  ViewSpeaker
//
//  Created by Mac on 2019/2/18.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublishMoveSourceCell.h"
#import "PublishSourceModel.h"

typedef void (^PublishSortCallBack)(NSMutableArray * _Nullable sourceArray) ;

NS_ASSUME_NONNULL_BEGIN

@interface PublishMoveSourceViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *sourceCollectionView;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (nonatomic, strong) PublishSortCallBack publishSortCallBack;

@end

NS_ASSUME_NONNULL_END
