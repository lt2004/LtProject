//
//  XTCPublishViewController.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/5.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCPublishTitleCell.h"
#import "XTCPublishShowSourceCell.h"
#import "XTCPublishManager.h"
#import "SDAVAssetExportSession.h"
#import "PublishVideoTrimmerViewController.h"
#import "PublishBottomSwitchViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "NewPublishPostAboutCell.h"
#import "NewPublishDescCell.h"
#import "NewPublishTagCell.h"
#import "PublishLinkUrlViewController.h"
#import "NewPublishRecordAudioViewController.h"
#import "PresentTransition.h"
#import "NewPublishMakeTagViewController.h"
#import "PublishMoveSourceViewController.h"
#import "PublishProVideoViewController.h"
#import "PublishDraftAlertViewController.h"
#import "NewPublishShowMapViewController.h"
#import "DeviceOrientation.h"
#import "PublishSourceModel.h"
#import "UIView+WebVideoCache.h"
#import "NBZUtil.h"
#import "XTCPublishSearchLinkCell.h"
#import "XTCMapView.h"
#import "MAMapView+ZoomLevel.h"


NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishViewController : XTCBaseViewController <UITableViewDelegate,UITableViewDataSource, UIViewControllerTransitioningDelegate, MAMapViewDelegate, AMapSearchDelegate, UITextViewDelegate, MWPhotoBrowserDelegate, DeviceOrientationDelegate>

@property (nonatomic, strong) PublishNormalPostModel *publishNormalPostModel; // 发布主model

@property (nonatomic, strong) NSString *interactivePostId; // 互动帖子id
@property (nonatomic, strong) NSString *tk; // 互动帖子id
@property (nonatomic, strong) NSString *chatType;
@property (nonatomic, strong) NSString *chatId;

@property (weak, nonatomic) IBOutlet UITableView *publishTableView;

@property (nonatomic, strong) NSMutableArray *sourceModelArray;

@property (nonatomic, assign) int recoderTime;

@property (nonatomic, strong) NSString *postShowCity; // 帖子城市
@property (nonatomic, strong) NSString *countryCode; // 国旗

@property (nonatomic, assign) PublishContentEnum publishContentEnum;
@property (nonatomic, assign) PublishTypeEnum publishTypeEnum;

@property (nonatomic, strong) XTCMapView *postDetailMapView;

@property (weak, nonatomic) IBOutlet UIView *bottomBgvIew;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (weak, nonatomic) IBOutlet UIButton *addTagButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *popButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *selectBusinessTypeButton;
@property (weak, nonatomic) IBOutlet UIView *selectBusinessTypeBgView;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) PublishBottomSwitchViewController *publishBottomSwitchVC;

@property (nonatomic, strong) NSString *audioDateString;


@property (nonatomic, strong) AVAsset *selectVideoAsset;
@property (nonatomic, strong) PHAsset *selectVideoPHAsset;


@property (nonatomic, strong) SDAVAssetExportSession *encoder;
@property (nonatomic, assign) BOOL isPlayVideo; // 是否正在播放视频
@property (nonatomic, strong) XTCPublishShowSourceCell *videoCell;
@property (nonatomic, assign) BOOL isVerticalPlay;// 是否是竖的视频

@property (nonatomic, strong) XTCBaseNavigationController *publishNavigationViewController;


- (void)loadPublishData:(NSMutableArray *)sourceAssetArray byPhoto:(NSMutableArray *)sourcePhotoArray byPublishType:(SelectPublishTypeEnum)selectPublishTypeEnum;

@end

NS_ASSUME_NONNULL_END
