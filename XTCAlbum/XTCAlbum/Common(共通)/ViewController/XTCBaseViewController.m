//
//  XTCBaseViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"

@interface XTCBaseViewController () {
    MBProgressHUD *_hud;
}

@end

@implementation XTCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"home_back_black"] forState:UIControlStateNormal];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 13)];
    _backButton.frame = CGRectMake(0, 0, 55, 40);
    [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    self.navigationItem.leftBarButtonItem = backBarItem;
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[GlobalData createImageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [GlobalData createImageWithColor:kTableviewColor];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].enable = NO;
    AppDelegate *appDeleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDeleagte.allowRotation) {
        [self fixInterfaceOrientation];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        appDeleagte.allowRotation = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)fixInterfaceOrientation {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIDeviceOrientationPortrait;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)alertMessage:(NSString *)msg {
    [self hideHub];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:1.25];
}

- (void)showHubWithDescription:(NSString *)des
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.label.text = des;
}

- (void)hideHub
{
    [_hud hideAnimated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
