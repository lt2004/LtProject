//
//  XTCAlbumChoicenessDetailViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/6.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "AblumModel+CoreDataClass.h"
#import "SStreamingScrollLayout.h"
#import "HomeCollectionViewCell.h"
#import "MWPhotoBrowser.h"
#import "TabBarButton.h"
#import "XTCShareHelper.h"
#import "ChoicenessAblumManager.h"
#import "XTCAblumViewController.h"
#import "AblumEmptyView.h"
#import "ChoicenessSelectMoreViewController.h"

#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "YBIBUtilities.h"


typedef void (^DeleteChoicenessSourceSuccessBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XTCAlbumChoicenessDetailViewController : XTCBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, SStreamingCollectionViewDelegateLayout, YBImageBrowserDataSource>

@property (weak, nonatomic) IBOutlet UIButton *popButton;
@property (strong, nonatomic)  AblumModel *albumModel;
@property (weak, nonatomic) IBOutlet UILabel *selelctCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@property (weak, nonatomic) IBOutlet UIButton *selectEditButton;

@property (nonatomic, strong) NSMutableArray *showArray;
@property (nonatomic, strong) NSMutableArray *flagAllArray;
@property (nonatomic, strong) NSMutableArray *flagPhotoArray;
@property (nonatomic, strong) NSMutableArray *flagVideoArray;

@property (weak, nonatomic) IBOutlet UIView *contentBgView;

@property (weak, nonatomic) IBOutlet UICollectionView *streamBgCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, strong) SStreamingScrollLayout *photoScrollLayout;

@property (nonatomic, strong) NSMutableArray *currentSelectArray;
@property (nonatomic, assign) BOOL isSelectAll;
@property (weak, nonatomic) IBOutlet UIView *handleBottomBgView;
@property (weak, nonatomic) IBOutlet UIView *bottomMenuView;

@property (nonatomic, strong) DeleteChoicenessSourceSuccessBlock deleteChoicenessSourceSuccessBlock;
@property (weak, nonatomic) IBOutlet UIButton *importButton;

@property (nonatomic, strong) AblumEmptyView *albumEmptyView;
@property (nonatomic, strong) UIImageView *menuImageView;

@property (nonatomic, assign) BOOL isStreamLock;

@end

NS_ASSUME_NONNULL_END
