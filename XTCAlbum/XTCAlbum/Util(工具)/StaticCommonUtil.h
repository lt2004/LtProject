//
//  StaticCommonUtil.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTCBaseNavigationController.h"
@class AppDelegate;
@class XTCHomePageViewController;

NS_ASSUME_NONNULL_BEGIN

@interface StaticCommonUtil : NSObject

+ (XTCBaseNavigationController *)rootNavigationController;
+ (AppDelegate *)app;
+ (UIViewController *)topViewController;
+ (XTCHomePageViewController *)gainHomePageViewController;

@end

NS_ASSUME_NONNULL_END
