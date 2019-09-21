//
//  AblumChoicenessCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AblumChoicenessSubCell.h"
#import "AblumModel+CoreDataClass.h"

typedef void(^AblumChoicenessSelectCallBack)(AblumModel *ablumModel);
typedef void(^CreateChoicenessCallBack)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AblumChoicenessCell : UICollectionViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *ablumCollectionView;
@property (nonatomic, strong) NSArray * ablumArray;
@property (nonatomic, strong) AblumChoicenessSelectCallBack ablumChoicenessSelectCallBack;
@property (nonatomic, strong) CreateChoicenessCallBack createChoicenessCallBack;

- (void)loadAboutData:(NSArray *)flagArray;

@end

NS_ASSUME_NONNULL_END
