//
//  AppDelegate.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <INTULocationManager/INTULocationManager.h>
#import "User.h"
#import <XHLaunchAd/XHLaunchAd.h>
#import <MagicalRecord/MagicalRecord.h>
@class XTCHomePageViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, XHLaunchAdDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL allowRotation;
@property (nonatomic, assign) BOOL portraitScreen;

@property (nonatomic, strong) XTCHomePageViewController *homePageVC;

- (UIViewController *)topViewController;
- (void)userInit;



@end

