//
//  XTCSourceDetailVRViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/8.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "GVRPanoramaView.h"
#import "AppDelegate.h"
#import "TabBarButton.h"
#import "XTCShareHelper.h"
#import "MWPhotoBrowser.h"
#import "XTCPhotoVideoInforViewController.h"

typedef void(^AlbumImageDeleteCallback)(PHAsset *deleteAsset);

NS_ASSUME_NONNULL_BEGIN

@interface XTCSourceDetailVRViewController : XTCBaseViewController <GVRWidgetViewDelegate>

@property (nonatomic, strong) GVRPanoramaView *panoramaView;
@property (nonatomic, strong) PHAsset *vrAsset;
@property (nonatomic, strong) TZAlbumModel *currentAlbumModel;
@property (nonatomic, strong) AlbumImageDeleteCallback deleteCallBack;
@property (nonatomic, strong) NSString *privateUrl;
@property (nonatomic, strong) UIImage *vrImage;

@property (weak, nonatomic) IBOutlet UIButton *popButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

NS_ASSUME_NONNULL_END
