//
//  XTCAblumViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "AblumChoicenessCell.h"
#import <ZLCollectionViewFlowLayout/ZLCollectionViewVerticalLayout.h>
#import "AblumHeaderReusableView.h"
#import "ChoicenessAblumManager.h"
#import "TravelNoteDetailCollectionViewCell.h"
#import "XTCAblumDetailViewController.h"
#import "XTCAlbumChoicenessDetailViewController.h"

typedef void (^MovePathSuccessBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XTCAblumViewController : XTCBaseViewController<UICollectionViewDelegate, UICollectionViewDataSource, ZLCollectionViewBaseFlowLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *ablumCollectionView;
@property (nonatomic, strong) NSArray *myChoicenessArray;
@property (nonatomic, strong) NSArray *systemAblumArray;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (nonatomic, assign) BOOL isMoveSource;
@property (nonatomic, strong) TZAlbumModel *selectAlbumModel;
@property (nonatomic, strong) AblumModel *selectChoicenessAlbumModel;
@property (nonatomic, strong) NSMutableArray *moveAssetArray; // 要移动的数据文件
@property (nonatomic, strong) MoveSuccessBlock moveSuccessBlock;
@property (nonatomic, strong) MovePathSuccessBlock movePathSuccessBlock;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;

- (void)queryFindAllChoiceness;
- (void)getAllAlbumsName;

@end

NS_ASSUME_NONNULL_END
