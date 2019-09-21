//
//  XTCSourceDetailVRViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/8.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCSourceDetailVRViewController.h"

@interface XTCSourceDetailVRViewController ()

@end

@implementation XTCSourceDetailVRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [_popButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _panoramaView = [[GVRPanoramaView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _panoramaView.enableCardboardButton = false;
    _panoramaView.enableTouchTracking = true;
    _panoramaView.enableFullscreenButton = false;
    _panoramaView.enableInfoButton = NO;
    _panoramaView.delegate = self;
    [self.view addSubview:_panoramaView];
    [self.view sendSubviewToBack:_panoramaView];
    
    XTCDateFormatter *dateFormatter = [XTCDateFormatter shareDateFormatter];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    _timeLabel.text = [dateFormatter stringFromDate:_vrAsset.creationDate];
    
    _bottomView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
    [self createBottomHandleUI];
     [self loadVRImage];
    
}

- (void)loadVRImage {
    if (_vrImage) {
         [self.panoramaView loadImage:_vrImage];
    } else {
        __weak typeof(self) weakSelf = self;
        [[TZImageManager manager] getPhotoWithAsset:_vrAsset photoWidth:kScreenWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.panoramaView loadImage:photo];
            });
        }];
    }
}

- (void)createBottomHandleUI {
    UIView *menuView = [[UIView alloc] init];
    [_bottomView addSubview:menuView];
    NSArray *itemName;
    NSArray *itemImgName;
    itemName = @[XTCLocalizedString(@"XTC_Delete", nil), XTCLocalizedString(@"XTC_Infor", nil), XTCLocalizedString(@"XTC_Share", nil)];;
    itemImgName = @[@"pic_detail_del", @"pic_detail_info", @"vr_tool_tab_share"];
    int flagHeight = 49;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]) {
        [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView);
            make.top.equalTo(self.bottomView);
            make.width.mas_equalTo(210);
            make.height.mas_equalTo(flagHeight);
        }];
    } else {
        [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView);
            make.top.equalTo(self.bottomView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(flagHeight);
        }];
    }
    
    for (int i = 0; i < itemName.count; i++) {
        TabBarButton *tabBarButton;
        NSString *deviceType = [UIDevice currentDevice].model;
        if([deviceType isEqualToString:@"iPad"]) {
            tabBarButton = [[TabBarButton alloc] initWithFrame:CGRectMake(i*(15+60), 0, 60, flagHeight)
                                                         title:itemName[i]
                                                         image:itemImgName[i]];
        } else {
            tabBarButton = [[TabBarButton alloc] initWithFrame:CGRectMake(i * kScreenWidth * (1.0 / itemName.count), 0, kScreenWidth * (1.0 / itemName.count), flagHeight)
                                                         title:itemName[i]
                                                         image:itemImgName[i]];
        }
        
        tabBarButton.tag = i + 100;
        [tabBarButton addTarget:self action:@selector(meunButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        tabBarButton.label.textColor = [UIColor whiteColor];
        [menuView addSubview:tabBarButton];
    }
}

- (void)meunButtonClick:(TabBarButton *)button {
    
    if (button.tag == 100) {
        [self deletePhoto];
    } else if (button.tag == 101) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPhotoVideoInfor" bundle:nil];
        XTCPhotoVideoInforViewController *photoVideoInforVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPhotoVideoInforViewController"];
        photoVideoInforVC.sourceAsset = _vrAsset;

         if (_privateUrl && _privateUrl.length) {
             photoVideoInforVC.sourceFileUrl = _privateUrl;
         } else {

         }
        photoVideoInforVC.photoVideoDismisCallabck = ^() {

        };
        [self.navigationController pushViewController:photoVideoInforVC animated:YES];
    } else {
        [self shareOrPublishPhoto];
    }
}

#pragma mark - 删除照片
- (void)deletePhoto {
    if (_currentAlbumModel) {
        __weak typeof(self) weakSelf = self;
        NSMutableArray *flagArray = [[NSMutableArray alloc] init];
        [flagArray addObject:_vrAsset];
        PHAssetCollection *assetCollection = [self fetchAssetColletion:self.currentAlbumModel.name];
        BOOL isCanRemove = NO;
        if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumRegular) {
            isCanRemove = YES;
        } else {
            isCanRemove = NO;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"您要删除照片或将它们从此相簿中移除吗？"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相簿中移除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //创建一个操作图库的对象
                PHAssetCollectionChangeRequest *assetCollectionChangeRequest;
                // 已有相册
                assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                [assetCollectionChangeRequest removeAssets:flagArray];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                
                //弹出一个界面提醒用户是否保存成功
                if (success) {
                    // 移除成功
                    if (self.deleteCallBack) {
                        self.deleteCallBack(self.vrAsset);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                    
                } else {
                    
                }
            }];
        }];
        
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:flagArray];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        // 删除成功
                        if (self.deleteCallBack) {
                            self.deleteCallBack(self.vrAsset);
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    } else {
                        
                    }
                });
            }];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (isCanRemove) {
            [alert addAction:albumAction];
        } else {
            
        }
        [alert addAction:removeAction];
        [alert addAction:cancelAction];
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            popPresenter.sourceView = _bottomView;
            popPresenter.sourceRect = _bottomView.bounds;
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        }
    } else {
        // 精选删除
        __weak typeof(self) weakSelf = self;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"您是否要将它移除精选码"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"移除精选" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.deleteCallBack) {
                weakSelf.deleteCallBack(self.vrAsset);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:removeAction];
        [alert addAction:cancelAction];
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            popPresenter.sourceView = _bottomView;
            popPresenter.sourceRect = _bottomView.bounds;
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        }
        
    }
}

- (PHAssetCollection *)fetchAssetColletion:(NSString *)albumTitle {
    // 获取所有的相册
    
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //遍历相册数组,是否已创建该相册
    for (PHAssetCollection *assetCollection in result) {
        NSLog(@"%@", assetCollection.localizedTitle);
    }
    for (PHAssetCollection *assetCollection in result) {
        
        if ([assetCollection.localizedTitle isEqualToString:albumTitle]) {
            
            return assetCollection;
            
        }
        
    }
    
    return nil;
}

#pragma mark - 分享或发布照片
- (void)shareOrPublishPhoto {
    [[TZImageManager manager] getOriginalPhotoWithAsset:_vrAsset completion:^(UIImage *photo, NSDictionary *info) {
        [[XTCShareHelper sharedXTCShareHelper] shreDataByTitle:@"小棠菜相册" byDesc:@"" byThumbnailImage:photo byMedia:@"" byVC:self byiPadView:self.bottomView];
    }];
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


- (void)orientationDidChanged {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        [UIApplication sharedApplication].statusBarHidden = NO;
        for (UIView *subView in self.panoramaView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"QTMButton")]) {
                subView.hidden = YES;
            } else {
                subView.hidden = NO;
            }
        }
    }
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        for (UIView *subView in self.panoramaView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"GVRGlView")]) {
                subView.hidden = NO;
            } else {
                subView.hidden = YES;
            }
        }
    }
    self.panoramaView.enableCardboardButton = false;
    self.panoramaView.enableFullscreenButton = false;
}

- (void)widgetView:(GVRWidgetView *)widgetView didChangeDisplayMode:(GVRWidgetDisplayMode)displayMode {
    _panoramaView.enableCardboardButton = false;
    _panoramaView.enableFullscreenButton = false;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[GlobalData createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [GlobalData createImageWithColor:[UIColor clearColor]];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
