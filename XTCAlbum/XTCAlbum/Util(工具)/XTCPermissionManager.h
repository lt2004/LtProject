//
//  XTCPermissionManager.h
//  vs
//
//  Created by Xie Shu on 2018/4/11.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, PermissionEnum) {
    PermissionSureEnum, // 授权
    PermissionNotSureEnum, // 拒绝授权
    PermissionAviableEnum, // 可用
};

typedef NS_ENUM(NSInteger, XTCImagePickerEnum) {
    XTCImagePickerCameraEnum,
    XTCImagePickerPhotoEnum
};

@interface XTCPermissionManager : NSObject

+ (void)imagePickerHelperByImagePickerEnum:(XTCImagePickerEnum)imagePickerEnum byMessage:(NSString *)message byViewController:(UIViewController *)showViewController callback:(void (^)(PermissionEnum permissionFlag))block;
+ (void)checkAudioPermissioncallBack:(void (^)(BOOL isPermission))block;

@end
