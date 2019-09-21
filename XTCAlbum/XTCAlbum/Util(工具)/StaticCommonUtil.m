//
//  StaticCommonUtil.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "StaticCommonUtil.h"
#import "AppDelegate.h"
#import "XTCHomePageViewController.h"

@implementation StaticCommonUtil

+ (XTCBaseNavigationController *)rootNavigationController {
    XTCBaseNavigationController *nav = (XTCBaseNavigationController *)[StaticCommonUtil app].window.rootViewController;
    return nav;
}


+ (AppDelegate *)app {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UIViewController *)topViewController {
    if ([StaticCommonUtil app].window != nil) {
        return [StaticCommonUtil topViewControllerWithRootViewController:[StaticCommonUtil app].window.rootViewController];
    } else {
        UIViewController *viewController = [[UIViewController alloc] init];
        return viewController;
    }
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *) rootViewController {
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

+ (XTCHomePageViewController *)gainHomePageViewController {
   XTCHomePageViewController *homePageVC = [StaticCommonUtil rootNavigationController].viewControllers.firstObject;
    return homePageVC;
}

@end
