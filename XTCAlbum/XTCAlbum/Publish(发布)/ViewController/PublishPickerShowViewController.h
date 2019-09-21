//
//  PublishPickerShowViewController.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "PublishPickerShowCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SourceICloudManager.h"
#import <TZImagePickerController/UIView+Layout.h>
#import "XTCPublishPickerViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AlbumSelectCallBack)(void);

@interface PublishPickerShowViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *showBgView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *selectCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (nonatomic, strong) UICollectionViewFlowLayout *previewLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *selectMutableArray;

@property (nonatomic, assign) SelectPublishTypeEnum selectPublishTypeEnum;
@property (nonatomic, assign) BOOL isPublishSelect;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AlbumSelectCallBack albumSelectCallBack;
@property (nonatomic, assign) NSInteger maxPhotoSelect;

@property (weak, nonatomic) IBOutlet UIView *topMenuView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *safeView;

@end

NS_ASSUME_NONNULL_END
