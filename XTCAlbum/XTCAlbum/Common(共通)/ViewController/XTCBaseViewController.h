//
//  XTCBaseViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"

typedef void (^MoveSuccessBlock)(void);

@interface XTCBaseViewController : UIViewController

@property (nonatomic, strong) UIButton *backButton;
- (void)alertMessage:(NSString *)msg;
- (void)showHubWithDescription:(NSString *)des;
- (void)hideHub;
- (void)backButtonClick;

@end
