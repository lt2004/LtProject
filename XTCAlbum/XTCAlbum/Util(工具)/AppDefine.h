//
//  AppDefine.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#ifndef AppDefine_h
#define AppDefine_h

// 屏宽
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏高
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

// 状态栏高度
#define kAppStatusBar [UIApplication sharedApplication].statusBarFrame.size.height

//颜色创建
// RGB
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
// 十六进制
#define HEX_RGB(hexValue)    [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0f]

// TableView背景颜色
#define kTableviewColor RGBCOLOR(243,243,243)
// TableViewCell颜色
#define kTableviewCellColor RGBCOLOR(231,231,231)

#define API_URL @"API_URL"
#define CACHE_USER_OBJECT @"CACHE_USER_OBJECT"

#define APP_BUILD_VERSION   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]



#define kPublishPostSuccess @"PublishPostSuccess"
#define kPublishPostFailed @"PublishPostFailed"
#define kPostUploadProgress @"PostUploadProgress"

#define LaunchAdvertImageUrl @"LaunchAdvertImageUrl"
#define LaunchAdvertLink @"LaunchAdvertLink"
#define LaunchAdvertTitle @"LaunchAdvertTitle"

#define XTCDeviceId @"com.viewspeaker.vsphoto"

#define MaxUploadFileCount 16


#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define kTabBar_Height (kDevice_Is_iPhoneX ?  83 : 49)
#define kBottom_iPhoneX 34


#define XTCDeviceStreamLine @"XTCDeviceStreamLine"

#define kHelvetica @"Helvetica"
#define kHelveticaBold @"Helvetica-Bold"

// 记录系统定位的经纬度
#define kSystemLatStr @"kSystemLatStr"
#define kSystemLngStr @"kSystemLngStr"

// 是否展示VR提示框
#define KIsCloseShowVR @"KIsCloseShowVR"

// 是否展示VR
#define KIsShowVR @"KIsShowVR"

#define kNeedReloadAblumAndChoicenessData @"kNeedReloadAblumAndChoicenessData"


#define XTCLocalizedString(key,comment) [[NSBundle mainBundle] localizedStringForKey:(key)value:@""table:nil]

// 私密相册别名
#define kPrivateNickName @"kPrivateNickName"
#define kPrivateResetFinish @"kPrivateResetFinish"

// 卷轴流锁定
#define kStreamLock @"kStreamLock"
#define kStreamLockHeight 2448


// 小棠菜旅行授权成功
#define kAuthSuccessByTravel @"kAuthSuccessByTravel"

/*************************发布处理*/
// 视频压缩码率
#define kVideoBitRateKey 3000 // 720p
#define kVideoHighBitRateKey 3300 // 1080p

#define kSizeMaxSecond 430

#define kStreamSystemMax 6 // 卷轴流最大行数
#define kStreamSystemMin 3 // 卷轴流最小行数

// 隐藏显示视频播放的导航栏
#define kVideoStatusBarShow @"kVideoStatusBarShow"
#define kVideoStatusBarHide @"kVideoStatusBarHide"

#define maxNormalUploadImageCount 16 // 普通用户上传的照片张数限制
#define maxBusinessUploadImageCount 24 // VIP用户上传照片张数限制
#define maxUploadVRImageCount 9 // VR上传的张数限制

#define kSystemNormalFont [UIFont fontWithName:@"Helvetica" size:16]

#endif /* AppDefine_h */
