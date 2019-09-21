//
//  XTCAlbumRegisterViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/20.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAlbumRegisterViewController.h"

@interface XTCAlbumRegisterViewController () {
    
}

@property (nonatomic, strong) RegisterRequesModel *registerRequesModel;

@end

@implementation XTCAlbumRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _registerRequesModel = [[RegisterRequesModel alloc] init];
    _registerRequesModel.device_id =  [GlobalData sharedInstance].deviceId;
    _registerRequesModel.password = @"";
    _registerRequesModel.repassword = @"";
    _registerRequesModel.nick_name = @"";
    _registerRequesModel.mobile = @"";
    
    self.view.backgroundColor = RGBCOLOR(251, 251, 251);
    
    _registerTableView.backgroundColor = RGBCOLOR(251, 251, 251);
    _registerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _registerTableView.allowsSelection = NO;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 155)];
    footerView.backgroundColor = [UIColor clearColor];
    _registerTableView.tableFooterView = footerView;
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont fontWithName:kHelveticaBold size:16];
    registerButton.layer.borderWidth = 1.5;
    registerButton.layer.borderColor = HEX_RGB(0x38880D).CGColor;
    registerButton.layer.masksToBounds = YES;
    registerButton.layer.cornerRadius = 20;
    [footerView addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footerView);
        make.left.equalTo(footerView).with.offset(35);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(footerView);
    }];
    
    NSMutableAttributedString *registerStr = [[NSMutableAttributedString alloc] initWithString:@"已有账号，去登录"];
    [registerStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(31, 31, 31) range:NSMakeRange(0, 6)];
    [registerStr addAttribute:NSForegroundColorAttributeName value:HEX_RGB(0x38880D) range:NSMakeRange(6, 2)];
    _loginLabel.attributedText = registerStr;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"AlbumRegisterCellName";
    AlbumRegisterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[AlbumRegisterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.bgView.layer.cornerRadius = 10;
    cell.bgView.layer.masksToBounds = YES;
    cell.bgView.backgroundColor = RGBCOLOR(242,242,242);
    switch (indexPath.section) {
        case 0: {
            cell.infoTextField.secureTextEntry = NO;
            cell.infoTextField.tag = 101;
            cell.infoTextField.placeholder = @"手机号";
        }
            break;
        case 1: {
            cell.infoTextField.secureTextEntry = YES;
            cell.infoTextField.tag = 102;
            cell.infoTextField.placeholder = @"密码";
        }
            break;
        case 2: {
            cell.infoTextField.secureTextEntry = YES;
            cell.infoTextField.tag = 103;
            cell.infoTextField.placeholder = @"再次确认密码";
        }
            break;
        default:
            break;
    }
    cell.infoTextField.returnKeyType = UIReturnKeyDone;
    cell.infoTextField.delegate = self;
    [cell.infoTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 30;
    } else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    switch (textField.tag) {
        case 101: {
            _registerRequesModel.mobile = textField.text;
        }
            break;
        case 102: {
            _registerRequesModel.password = textField.text;
        }
            break;
        case 103: {
            _registerRequesModel.repassword = textField.text;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 注册按钮被点击
- (void)registerButtonClick {
    __weak typeof(self) weakSelf = self;
    
    if (_registerRequesModel.nick_name.length < 19) {
        
    }else{
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"Login_Nick_Name_Max", nil) completion:nil];
        return;
    }
    
    //电话
    if (_registerRequesModel.mobile.length == 11) {
    }else{
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"ser_018", nil) completion:nil];
        return;
        
    }
    
    if ([_registerRequesModel.password isEqualToString:_registerRequesModel.repassword]) {
        
    } else {
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"ser_014", nil) completion:nil];
        return;
    }
    
    
    //密码
    
    if (_registerRequesModel.password.length > 7 && _registerRequesModel.password.length<17) {
        
    }else{
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"Login_Password_Max", nil) completion:nil];
        return;
    }
    [self showHubWithDescription:XTCLocalizedString(@"Login_Register_Loading", nil)];
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestRegisterEnum byRequestDict:_registerRequesModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
        });
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            [KVNProgress showSuccessWithStatus:XTCLocalizedString(@"ser_019", nil) completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }];
        } else {
            [KVNProgress showErrorWithStatus:errorModel.errorString];
        }
    }];
}

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    DDLogInfo(@"注册页面内存释放");
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
