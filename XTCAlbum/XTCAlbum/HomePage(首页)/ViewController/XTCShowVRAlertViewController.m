//
//  XTCShowVRAlertViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/8.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCShowVRAlertViewController.h"

@interface XTCShowVRAlertViewController ()

@end

@implementation XTCShowVRAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_selelctButton addTarget:self action:@selector(selelctButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _bgView.layer.cornerRadius = 4;
    _bgView.layer.masksToBounds = YES;
    [_vrButton addTarget:self action:@selector(vrButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_normalButton addTarget:self action:@selector(normalButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)vrButtonClick {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.alertSelectCallBack) {
            self.alertSelectCallBack(YES);
        }
    }];
}

- (void)normalButtonClick {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.alertSelectCallBack) {
            self.alertSelectCallBack(NO);
        }
    }];
}

- (void)selelctButtonClick {
    BOOL isShowVRAlert = [[NSUserDefaults standardUserDefaults] boolForKey:KIsCloseShowVR];
    if (isShowVRAlert) {
        _switchImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KIsCloseShowVR];
    } else {
        _switchImageView.image = [UIImage imageNamed:@"photo_selected_on"];
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KIsCloseShowVR];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)dismisButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
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
