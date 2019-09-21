//
//  XTCAlbumLoginViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/19.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAlbumLoginViewController.h"

@interface XTCAlbumLoginViewController () {
    MBProgressHUD *_hud;
}

@property (nonatomic, strong) LoginRequesModel *loginRequesModel;

@end

@implementation XTCAlbumLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    
    _loginRequesModel = [[LoginRequesModel alloc] init];
    _loginRequesModel.device_id = [GlobalData sharedInstance].deviceId;
    _loginRequesModel.mobile = @"";
    _loginRequesModel.password = @"";
    
    self.view.backgroundColor = RGBCOLOR(251, 251, 251);
    self.backButton.hidden = YES;
    _accountView.layer.cornerRadius = 10;
    _accountView.layer.masksToBounds = YES;
    _accountView.backgroundColor = RGBCOLOR(242,242,242);
    _accountTextField.secureTextEntry = NO;
    _accountTextField.tag = 101;
    [_accountTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _passwordView.layer.cornerRadius = 10;
    _passwordView.layer.masksToBounds = YES;
    _passwordView.backgroundColor = RGBCOLOR(242,242,242);
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.tag = 102;
    [_passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSMutableAttributedString *registerStr = [[NSMutableAttributedString alloc] initWithString:@"还没有账号，去注册"];
    [registerStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(31, 31, 31) range:NSMakeRange(0, 7)];
    [registerStr addAttribute:NSForegroundColorAttributeName value:HEX_RGB(0x38880D) range:NSMakeRange(7, 2)];
    _registerLabel.attributedText = registerStr;
    
    // 普通登录按钮
    _loginButton.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 21;
    _loginButton.layer.borderWidth = 1.5;
    _loginButton.layer.borderColor = HEX_RGB(0x38880D).CGColor;
    [_loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 小棠菜旅行授权登录按钮
    _travelButton.layer.masksToBounds = YES;
    _travelButton.layer.cornerRadius = 21;
    [_travelButton addTarget:self action:@selector(travelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 注册按钮
    [_registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 判断是否下载了小棠菜旅行
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ViewSpeaker://"]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        _travelButton.hidden = NO;
    } else {
        _travelButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authSuccessClick) name:kAuthSuccessByTravel object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[GlobalData createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == 101) {
        _loginRequesModel.mobile = textField.text;
    } else {
        _loginRequesModel.password = textField.text;
    }
}

#pragma mark - 账号登录
- (void)loginButtonClick {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    /*
    //电话
    if (_loginRequesModel.mobile.length == 11) {
        
    } else{
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"ser_018", nil) completion:nil];
        return;
        
    }
     */
    if (_loginRequesModel.mobile && _loginRequesModel.mobile.length) {
        
    } else{
        [KVNProgress showErrorWithStatus:@"请输入账号" completion:nil];
        return;
        
    }
    
    //密码
    if (_loginRequesModel.password.length) {
        
    }else{
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"ser_005", nil) completion:nil];
        return;
    }
    
    [self showHubWithDescription:XTCLocalizedString(@"Login_Loading", nil)];
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestLoginEnum byRequestDict:_loginRequesModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
        });
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            [KVNProgress showSuccessWithStatus:XTCLocalizedString(@"ser_007", nil) completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        if (weakSelf.loginSuccessBlock) {
                            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            [delegate userInit];
                            weakSelf.loginSuccessBlock();
                        }
                    }];
                });
            }];
        } else {
            [KVNProgress showErrorWithStatus:errorModel.errorString];
        }
    }];
}

#pragma mark - 使用小棠菜旅行登录
- (void)travelButtonClick {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ViewSpeaker://singIn"]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - 通过小棠菜旅行授权成功
- (void)authSuccessClick {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.loginSuccessBlock) {
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate userInit];
                self.loginSuccessBlock();
            }
        }];
    });
}

#pragma mark - 注册按钮被点击
- (void)registerButtonClick {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumRegister" bundle:nil];
    XTCAlbumRegisterViewController *albumLoginVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumRegisterViewController"];
    [self.navigationController pushViewController:albumLoginVC animated:YES];
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

- (IBAction)dismisButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)dealloc {
    DDLogInfo(@"登录界面内存释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAuthSuccessByTravel object:nil];
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
