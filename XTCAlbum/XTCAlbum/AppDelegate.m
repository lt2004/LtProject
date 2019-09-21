//
//  AppDelegate.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "AppDelegate.h"
#import "XTCHomePageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置语言
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language = [languages objectAtIndex:0];
    if ([language hasPrefix:@"zh"]) {
        
    } else{
        //其他语言
        [[NSUserDefaults standardUserDefaults] setObject:@"zh" forKey:@"appLanguage"];//App语言设置为中文
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [TZImageManager manager].sortAscendingByModificationDate = NO;
    
    // 启动进入app禁止转屏
    self.allowRotation = NO;
    // app当前状态是否是竖屏
    _portraitScreen = YES;
    
    // UI入口
    UIStoryboard *coupon = [UIStoryboard storyboardWithName:@"XTCHomePage" bundle:nil];
    _homePageVC = [coupon instantiateViewControllerWithIdentifier:@"XTCHomePageViewController"];
    XTCBaseNavigationController *homePageViewController = [[XTCBaseNavigationController alloc] initWithRootViewController:_homePageVC];
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = homePageViewController;
    [self.window makeKeyAndVisible];
    
    
    // 获取登陆用户相关信息
    if ([[EGOCache globalCache] objectForKey:CACHE_USER_OBJECT]) {
        id userFlagModel = [[EGOCache globalCache] objectForKey:CACHE_USER_OBJECT];
        if ([userFlagModel isKindOfClass:[User class]]) {
            User *user = (User *)userFlagModel;
            XTCUserModel *userModel = [[XTCUserModel alloc] init];
            userModel.user_id = user.user_id;
            userModel.token = user.token;
            userModel.nick_name = user.nick_name;
            userModel.headimgurl = user.headimgurl;
            userModel.mobile = user.mobile;
            [[EGOCache globalCache] setObject:userModel forKey:CACHE_USER_OBJECT];
            if (userModel.token != nil) {
                [GlobalData sharedInstance].userModel = userModel;
            }
        } else {
            XTCUserModel *userModel = (XTCUserModel *)userFlagModel;
            if (userModel.token != nil) {
                [GlobalData sharedInstance].userModel = userModel;
            }
        }
        [self userInit];
    }
    [EGOCache globalCache].defaultTimeoutInterval = 86400 * 365 * 10;
    
    // 高德
    [AMapServices sharedServices].apiKey = @"5e224967a3af3be281254ec8b7370780";
    [AMapServices sharedServices].enableHTTPS = YES;
    
    // 获取服务器地址
    GetUrlRequesModel *requestModel = [[GetUrlRequesModel alloc] init];
    requestModel.app_type = @"IOS";
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestGetUrlEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        
    }];
    
    // 拉取广告
    [self getAdvertAboutData];
    
    // 展示闪屏广告
    NSString *launchUrl = (NSString *)[[EGOCache globalCache] objectForKey:LaunchAdvertImageUrl];
    if (launchUrl && launchUrl.length && [XHLaunchAd checkImageInCacheWithURL:[NSURL URLWithString:launchUrl]]) {
        NSString *linkUrl = (NSString *)[[EGOCache globalCache] objectForKey:LaunchAdvertLink];
        //使用默认配置
        XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration defaultConfiguration];
        imageAdconfiguration.imageNameOrURLString = launchUrl;
        imageAdconfiguration.duration = 5;
        imageAdconfiguration.showFinishAnimateTime = 0.25;
        imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFit;
        imageAdconfiguration.openURLString = linkUrl;
        [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
    } else {
        
    }
    
    //  CoreData
    [self setUpMagicalRecord];
    
    // 日志
    [self ddlogConfig];
    
    // 监听横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    
    return YES;
}

#pragma mark - 判断应用当前是否是竖屏（照片或视频时用）
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation{
    UIDevice *device = [UIDevice currentDevice] ;
    
    switch (device.orientation) {
        case UIDeviceOrientationLandscapeLeft: {
            _portraitScreen = NO;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
             _portraitScreen = NO;
        }
            break;
        case UIDeviceOrientationPortrait: {
             _portraitScreen = YES;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown: {
            _portraitScreen = YES;
        }
            break;
            
        default:
            DDLogInfo(@"无法辨识");
            break;
    }
    
}

#pragma mark - log日志配置
- (void)ddlogConfig {
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelInfo];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
}

#pragma mark - 点击广告跳转
- (void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenURLString:(NSString *)openURLString {
    if (openURLString && openURLString.length) {
        NSString *launchAdvertTitle = (NSString *)[[EGOCache globalCache] objectForKey:LaunchAdvertTitle];
        CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
        commonWebViewVC.hidesBottomBarWhenPushed = YES;
        commonWebViewVC.urlString = openURLString;
        commonWebViewVC.titleString = launchAdvertTitle ? launchAdvertTitle : @"";
        commonWebViewVC.hidesBottomBarWhenPushed = YES;
        [_homePageVC.navigationController pushViewController:commonWebViewVC animated:YES];
    } else {
        
    }
}


#pragma mark - 获取首页侧拉广告和闪屏广告
- (void)getAdvertAboutData {
    
    // 首页广告
    AdvertRequestModel *advertRequestModel = [[AdvertRequestModel alloc] init];
    advertRequestModel.index = @"1";
    advertRequestModel.device_id =  [GlobalData sharedInstance].deviceId;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestHomeAdvertEnum byRequestDict:advertRequestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        
    }];

    // 闪屏广告
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AdvertRequestModel *advertRequestModel = [[AdvertRequestModel alloc] init];
        advertRequestModel.index = @"";
        advertRequestModel.device_id =  [GlobalData sharedInstance].deviceId;
        [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestAdvertEnum byRequestDict:advertRequestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
            if (errorModel.errorEnum == ResponseSuccessEnum) {
                if (object) {
                    AdvertResponseModel *responseModel = object;
                    [GlobalData sharedInstance].advertResponseModel = responseModel;
                    // 缓存闪屏广告
                    if (responseModel.prc_url && responseModel.prc_url.length) {
                        [[EGOCache globalCache] setObject:responseModel.prc_url forKey:LaunchAdvertImageUrl];
                        [XHLaunchAd downLoadImageAndCacheWithURLArray:@[[NSURL URLWithString:responseModel.prc_url]]];
                        if (responseModel.prc_link && responseModel.prc_link.length) {
                            [[EGOCache globalCache] setObject:responseModel.prc_link forKey:LaunchAdvertLink];
                        } else {
                            
                        }
                        if (responseModel.title && responseModel.title.length) {
                            [[EGOCache globalCache] setObject:responseModel.title forKey:LaunchAdvertTitle];
                        } else {
                            
                        }
                    } else {
                        [[EGOCache globalCache] setObject:@"" forKey:LaunchAdvertImageUrl];
                    }
                    
                } else {
                    [[EGOCache globalCache] setObject:@"" forKey:LaunchAdvertImageUrl];
                }
            } else {
                [[EGOCache globalCache] setObject:@"" forKey:LaunchAdvertImageUrl];
            }
        }];
    });
}


#pragma mark - 统计用户相关数据
- (void)userInit {
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            __block NSString *Country = @"";
            __block NSString *State = @"";
            __block NSString *City = @"";
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                if(placemarks.count > 0) {
                    CLPlacemark *placemark = placemarks.firstObject;
                    if([placemark.addressDictionary objectForKey:@"Country"] != NULL) {
                        Country = [placemark.addressDictionary objectForKey:@"Country"];
                    }
                    if([placemark.addressDictionary objectForKey:@"State"] != NULL) {
                        State = [placemark.addressDictionary objectForKey:@"State"];
                    }
                    if([placemark.addressDictionary objectForKey:@"City"] != NULL) {
                        City = [placemark.addressDictionary objectForKey:@"City"];
                    }
                }
                
                NSString *lat = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
                NSString *lng = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
                NSString *position = [NSString stringWithFormat:@"%@,%@,%@", Country, State, City];
                [self statisticUserAboutDataByLat:lat byLng:lng byPosition:position];
                
            }];
        } else {
            [self statisticUserAboutDataByLat:@"" byLng:@"" byPosition:@""];
        }
    }];
}

- (void)statisticUserAboutDataByLat:(NSString *)latStr byLng:(NSString *)lngStr byPosition:(NSString *)position {
    UserInitRequestModel *userInitRequesModel = [[UserInitRequestModel alloc] init];
    XTCUserModel *userModel = [GlobalData sharedInstance].userModel;
    if (userModel) {
        userInitRequesModel.user_id = userModel.user_id;
    } else {
        userInitRequesModel.user_id = @"0";
    }
    userInitRequesModel.lat = latStr;
    userInitRequesModel.lng = lngStr;
    userInitRequesModel.position = position;
    
    userInitRequesModel.device_id =  [GlobalData sharedInstance].deviceId;
    
    NSString *systemName = [NSString stringWithFormat:@"%@%@",[UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    userInitRequesModel.mobile_system = systemName;
    
    NSString *deviceName = [[GlobalData sharedInstance] getDeviceName];
    userInitRequesModel.mobile_brand = deviceName;
    
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    userInitRequesModel.version_code = version;
    
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestInitEnum byRequestDict:userInitRequesModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 分享时出现状态栏隐藏了
    if ([[self topViewController] isKindOfClass:NSClassFromString(@"MWPhotoBrowser")]) {
        
    } else {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    //跳转授权页面
    NSString *urlStr = url.absoluteString;
    if ([urlStr hasPrefix:@"FreeTime://"]) {
        if ([urlStr hasSuffix:@"auth=cancel"]) {
            [KVNProgress showErrorWithStatus:@"取消授权"];
        } else {
            NSString *responseStr = [urlStr stringByRemovingPercentEncoding];
            NSString *subrResponseStr = [responseStr substringFromIndex:11];
            NSData *data = [subrResponseStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            XTCUserModel * userMoel = [[XTCUserModel alloc] initUserWithDict:tempDict];
            [GlobalData sharedInstance].userModel = userMoel;
            [[EGOCache globalCache] setObject:userMoel forKey:CACHE_USER_OBJECT];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAuthSuccessByTravel object:nil];
            
            
        }
        return YES;
    } else {
        return NO;
    }
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
    
}


- (UIViewController *)topViewController {
    if (self.window != nil) {
        return [self topViewControllerWithRootViewController:self.window.rootViewController];
    } else {
        UIViewController *viewController = [[UIViewController alloc] init];
        return viewController;
    }
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *) rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        if (navigationController.visibleViewController == nil) {
            return navigationController;
        } else {
            return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
        }
    } else if (rootViewController.presentedViewController != nil) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

#pragma mark - 初始化MagicalRecord
- (void)setUpMagicalRecord {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"MagicRecordAblum"];
}


@end
