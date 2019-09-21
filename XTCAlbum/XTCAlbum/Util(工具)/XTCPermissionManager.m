//
//  XTCPermissionManager.m
//  vs
//
//  Created by Xie Shu on 2018/4/11.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
// 备注:小棠菜访问权限检测及授权

#import "XTCPermissionManager.h"

@implementation XTCPermissionManager

+ (void)imagePickerHelperByImagePickerEnum:(XTCImagePickerEnum)imagePickerEnum byMessage:(NSString *)message byViewController:(UIViewController *)showViewController callback:(void (^)(PermissionEnum permissionFlag))block {
    if (imagePickerEnum == XTCImagePickerCameraEnum) {
        NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted){
            [XTCPermissionManager messageAuthorityAlertViewByMessage:message byImagePickEnum:imagePickerEnum  byViewController:showViewController];
            block(PermissionNotSureEnum);
        } else if(authStatus == AVAuthorizationStatusDenied){
            [XTCPermissionManager messageAuthorityAlertViewByMessage:message byImagePickEnum:imagePickerEnum  byViewController:showViewController];
            block(PermissionNotSureEnum);
        } else if(authStatus == AVAuthorizationStatusAuthorized){
            //允许访问
            block(PermissionAviableEnum);
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){//点击允许访问时调用
                    //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                    block(PermissionSureEnum);
                }
                else {
                    block(PermissionNotSureEnum);
                }
            }];
        }else {
            [XTCPermissionManager messageAuthorityAlertViewByMessage:message byImagePickEnum:imagePickerEnum byViewController:showViewController];
            block(NO);
        }
    } else {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted){
            [XTCPermissionManager messageAuthorityAlertViewByMessage:message byImagePickEnum:imagePickerEnum byViewController:showViewController];
            block(PermissionNotSureEnum);
        } else if (status == ALAuthorizationStatusNotDetermined) {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (*stop) {
                    //点击“好”回调方法:
                    block(PermissionSureEnum);
                    return;
                    
                }
                *stop = TRUE;
            } failureBlock:^(NSError *error) {
                block(PermissionNotSureEnum);
            }];
            
        } else {
            block(PermissionAviableEnum);
        }
    }
}

#pragma mark - 相册或相机无权限提示框
+ (void)messageAuthorityAlertViewByMessage:(NSString *)messageString byImagePickEnum:(XTCImagePickerEnum)imagePickerEnum byViewController:(UIViewController *)showViewController {
    NSString *titleStr;
    if (imagePickerEnum == XTCImagePickerCameraEnum) {
        titleStr = @"请开启相机权限";
    } else {
        titleStr = @"请开启相册权限";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *openAlertController  = [UIAlertController alertControllerWithTitle:titleStr message:messageString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [openAlertController addAction:cancelAction];
        [openAlertController addAction:sureAction];
        [showViewController presentViewController:openAlertController animated:YES completion:^{
            
        }];
    });
}

#pragma mark - 麦克风权限处理
+ (void)checkAudioPermissioncallBack:(void (^)(BOOL isPermission))block {
    AVAudioSession* sharedSession = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission permission = [sharedSession recordPermission];
    switch (permission) {
        case AVAudioSessionRecordPermissionUndetermined: {
            // 还未决定，说明系统权限请求框还未弹
            NSLog(@"Undetermined");
            // 获取麦克风权限
            [sharedSession requestRecordPermission:^(BOOL granted) {
                block(granted);
            }];
        }
            break;
        case AVAudioSessionRecordPermissionDenied: {
            // 权限被禁止需要弹窗
            NSLog(@"Denied");
            UIAlertController *openAlertController  = [UIAlertController alertControllerWithTitle:@"请开启麦克风功能" message:@"分享有声游记需要访问您的麦克风" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂时不要" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [openAlertController addAction:cancelAction];
            [openAlertController addAction:sureAction];

            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [[appdelegate topViewController] presentViewController:openAlertController animated:YES completion:^{
                
            }];
            block(NO);
        }
            break;
        case AVAudioSessionRecordPermissionGranted: {
            // 已经授权
            NSLog(@"Granted");
            block(YES);
        }
            break;
        default:
            break;
    }
}

@end
