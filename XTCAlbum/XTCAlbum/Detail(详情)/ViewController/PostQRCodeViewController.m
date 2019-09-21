//
//  PostQRCodeViewController.m
//  vs
//
//  Created by Mac on 2018/12/17.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "PostQRCodeViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PostQRCodeViewController ()

@end

@implementation PostQRCodeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userHeaderButton.layer.cornerRadius = 25;
    self.userHeaderButton.layer.masksToBounds = YES;
    self.postNameLabel.hidden = YES;
    self.userHeaderButton.hidden = YES;
    self.userNameLabel.hidden = YES;
    
    self.qrCodeBgView.layer.cornerRadius = 4;
    self.qrCodeBgView.layer.masksToBounds = YES;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if (kScreenWidth == 320) {
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 0, 0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 1;
        flowLayout.minimumLineSpacing = 1;
    } else {
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 15, 0, 15);
        flowLayout.minimumInteritemSpacing = 1;
        flowLayout.minimumLineSpacing = 1;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    _selectCollectionView.collectionViewLayout = flowLayout;
    _selectCollectionView.backgroundColor = [UIColor clearColor];
    _selectCollectionView.delegate = self;
    _selectCollectionView.dataSource = self;
    [_selectCollectionView registerClass:[PostCodeSelectCell class] forCellWithReuseIdentifier:@"PostCodeSelectCellName"];
}

- (void)loadAboutData {
    if (_isPrinting) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
        [mutableDictionary setObject:@"printing" forKey:@"type"];
        [mutableDictionary setObject:@"viewspeaker" forKey:@"sign"];
        [mutableDictionary setObject:_postDetailModel.postDetailId forKey:@"type_id"];
        [mutableDictionary setObject:_postDetailModel.post_type forKey:@"post_type"];
        self.qrCodeImageView.image = [QRCodeManager createQRCodeByDict:mutableDictionary];
        _bottomLabel.text = @"用于印刷的二维码";
    } else {
        self.postNameLabel.hidden = NO;
        self.userHeaderButton.hidden = NO;
        self.userNameLabel.hidden = NO;
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
        [mutableDictionary setObject:@"interaction" forKey:@"type"];
        [mutableDictionary setObject:@"viewspeaker" forKey:@"sign"];
        [mutableDictionary setObject:_postDetailModel.postDetailId forKey:@"type_id"];
        [mutableDictionary setObject:_postDetailModel.post_type forKey:@"post_type"];
        self.qrCodeImageView.image = [QRCodeManager createQRCodeByDict:mutableDictionary];
        self.postNameLabel.text = _postDetailModel.postName;
        self.userNameLabel.text = _postDetailModel.userName;
        [self.userHeaderButton sd_setImageWithURL:[NSURL URLWithString:_postDetailModel.userImage] forState:UIControlStateNormal];
        _bottomLabel.text = @"扫一扫 参与互动";
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (kScreenWidth == 320) {
        return CGSizeMake(60, 80);
    } else {
        return CGSizeMake((kScreenWidth-30-10)*0.2, 80);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCodeSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCodeSelectCellName" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    switch (indexPath.item) {
        case 0: {
            cell.selectImageView.image = [UIImage imageNamed:@"qr_code_save"];
            cell.selectLabel.text = @"保存到相册";
        }
            break;
        case 1: {
            cell.selectImageView.image = [UIImage imageNamed:@"qr_code_weichat"];
            cell.selectLabel.text = @"微信";
        }
            break;
        case 2: {
            cell.selectImageView.image = [UIImage imageNamed:@"qr_code_friend"];
            cell.selectLabel.text = @"朋友圈";
        }
            break;
        case 3: {
            cell.selectImageView.image = [UIImage imageNamed:@"qr_code_qq"];
            cell.selectLabel.text = @"QQ";
        }
            break;
        case 4: {
            cell.selectImageView.image = [UIImage imageNamed:@"qr_code_sina"];
            cell.selectLabel.text = @"新浪";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *saveImage;
    if (_isPrinting) {
        saveImage = [self snapshotWithView:_qrCodeImageView];
    } else {
        saveImage = [self snapshotWithView:_qrCodeBgView];
    }
    [[XTCShareHelper sharedXTCShareHelper] shreDataByImages:@[saveImage] byVC:self byiPadView:_selectCollectionView];
    /*
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    shareObject.thumbImage = saveImage;
    shareObject.shareImage = saveImage;
    messageObject.shareObject = shareObject;
    
    switch (indexPath.row) {
        case 0: {
            [self saveQrCode:saveImage];
        }
            break;
        case 1: {
            if([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
                //调用微信分享接口
                [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
                    dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                    dispatch_after(showTime, dispatch_get_main_queue(), ^{
                        if (error) {
                            [KVNProgress showErrorWithStatus:@"分享失败"];
                        } else{
                            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                                 [KVNProgress showSuccessWithStatus:@"分享成功"];
                                
                            }else{
                                [KVNProgress showErrorWithStatus:@"分享失败"];
                            }
                        }
                    });
                }];
            } else {
                 [self alertMessage:@"请安装微信"];
            }
        }
            break;
        case 2: {
            if([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
                //调用微信朋友圈分享接口
                [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatTimeLine messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
                    dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                    dispatch_after(showTime, dispatch_get_main_queue(), ^{
                        if (error) {
                            [KVNProgress showErrorWithStatus:@"分享失败"];
                        }else{
                            [KVNProgress showSuccessWithStatus:@"分享成功"];
                        }
                    });
                }];
            } else {
                 [self alertMessage:@"请安装微信"];
            }
        }
            break;
        case 3: {
            if([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
                //调用微信分享接口
                [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_QQ messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
                    dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                    dispatch_after(showTime, dispatch_get_main_queue(), ^{
                        if (error) {
                            [KVNProgress showErrorWithStatus:@"分享失败"];
                        }else{
                            [KVNProgress showSuccessWithStatus:@"分享成功"];
                        }
                    });
                }];
            } else {
                 [self alertMessage:@"请安装QQ"];
            }
        }
            break;
        case 4: {
            if([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Sina]) {
                //调用微信分享接口
                [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
                    dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
                    dispatch_after(showTime, dispatch_get_main_queue(), ^{
                        if (error) {
                            [KVNProgress showErrorWithStatus:@"分享失败"];
                        }else{
                            [KVNProgress showSuccessWithStatus:@"分享成功"];
                        }
                    });
                }];
            } else {
                [self alertMessage:@"请安装新浪微博"];
            }
        }
            break;
            
        default:
            break;
    }
     */
}

- (void)saveQrCode:(UIImage *)saveImage {
    [XTCPermissionManager imagePickerHelperByImagePickerEnum:XTCImagePickerPhotoEnum byMessage:@"小棠菜旅行相机需要保存照片到相册，需要访问您的相册权限" byViewController:self callback:^(PermissionEnum permissionFlag) {
        if (permissionFlag) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //写入图片到相册
                [PHAssetChangeRequest creationRequestForAssetFromImage:saveImage];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [self alertMessage:@"保存失败"];
                    } else {
                        [self alertMessage:@"保存成功"];
                    }
                });
                
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertMessage:@"保存失败"];
            });
            
        }
    }];
}

- (UIImage *)snapshotWithView:(UIView *)view
{
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)alertMessage:(NSString *)msg {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:0.8];
}

- (IBAction)dismisButtonClick:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
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
