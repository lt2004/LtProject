//
//  XTCAlbumPrivateDetailViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/15.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "SStreamingScrollLayout.h"
#import "MWPhotoBrowser.h"
#import "HomeCollectionViewCell.h"
#import "TZImagePickerController.h"
#import "SourceShowTimeModel.h"
#import "TabBarButton.h"
#import "AblumEmptyView.h"

#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "YBIBUtilities.h"

@interface XTCAlbumPrivateDetailViewController : XTCBaseViewController <SStreamingCollectionViewDelegateLayout, UINavigationControllerDelegate, TZImagePickerControllerDelegate, YBImageBrowserDataSource>

@property (nonatomic, strong) XTCPrivateAlbumModel *albumModel;

@property (weak, nonatomic) IBOutlet UICollectionView *streamPhotoCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *streamBgCollectionView;
@property (weak, nonatomic) IBOutlet UIView *contentBgView;


@property (weak, nonatomic) IBOutlet UILabel *selectCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectEditButton;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UIView *handleView;
@property (nonatomic, assign) BOOL isSelectAll;
@property (nonatomic, strong) AblumEmptyView *albumEmptyView;
@property (nonatomic, assign) BOOL isStreamLock;

@end
