//
//  CloudSaveViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "UserHomeIndexResponseModel.h"
#import "UserHeaderTagCollectionViewCell.h"
#import "ScrollstreamRequestModel.h"
#import "ScrollstreamResponseModel.h"
#import "SStreamingScrollLayout.h"
#import "UserHomeStreamCell.h"
#import "UserHomePageSearchViewController.h"
#import "PostDetailPhotoViewController.h"
#import "SideRefreshHeader.h"
#import "UICollectionView+SideRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface CloudSaveViewController : XTCBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SStreamingCollectionViewDelegateLayout, UserHomeSearchDelegate>

@property (nonatomic, strong) UserHomeIndexResponseModel *userHomeIndexResponseModel;
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (nonatomic, strong) NSMutableArray *bottomTagArray;
@property (nonatomic, assign) NSInteger selectBottomIndex;
@property (nonatomic, strong) SStreamingScrollLayout *streamingScrollLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *streamCollectionView;

@property (nonatomic, strong) SStreamingScrollLayout *streamingBgScrollLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *streamBgCollectionView;
@property (weak, nonatomic) IBOutlet UIView *contentBgView;

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) ScrollstreamRequestModel *allRequestModel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

NS_ASSUME_NONNULL_END
