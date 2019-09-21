//
//  XTCPrivateAlbumForgetPwdViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/15.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCPrivateAlbumForgetPwdViewController.h"

@interface XTCPrivateAlbumForgetPwdViewController () {
    SetpwdRequestModel *_setpwdRequestModel;
    NSString *_againPassword;
}

@end

@implementation XTCPrivateAlbumForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _setpwdRequestModel = [[SetpwdRequestModel alloc] init];
    _setpwdRequestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
    _setpwdRequestModel.token = [GlobalData sharedInstance].userModel.token;
    _setpwdRequestModel.password = @"";
    _setpwdRequestModel.pre_password = @"";
    _againPassword = @"";
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"重置密码";
    _resetTableView.backgroundColor = kTableviewColor;
    _resetTableView.separatorColor = kTableviewCellColor;
    _resetTableView.rowHeight = UITableViewAutomaticDimension;
    _resetTableView.estimatedRowHeight = 50.0f;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"确定" forState:UIControlStateNormal];
    [sendButton sizeToFit];
    [sendButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeperator.width = -10.0;
    self.navigationItem.rightBarButtonItems = @[rightSeperator, rightBarItem];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"XTCModifyPasswordCellName";
    XTCModifyPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[XTCModifyPasswordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    switch (indexPath.row) {
        case 0: {
            cell.headerLabel.text = @"登录密码";
            cell.detailDescLabel.text = @"Password";
            cell.inputTextField.placeholder = @"请输入登录密码";
            cell.inputTextField.tag = 101;
        }
            break;
        case 1: {
            cell.headerLabel.text = @"新密码";
            cell.detailDescLabel.text = @"New password";
            cell.inputTextField.placeholder = @"请输入新密码";
            cell.inputTextField.tag = 102;
        }
            break;
        case 2: {
            cell.headerLabel.text = @"确认新密码";
            cell.detailDescLabel.text = @"Confirm password";
            cell.inputTextField.placeholder = @"确认密码";
            cell.inputTextField.tag = 103;
        }
            break;
            
        default:
            break;
    }
    cell.inputTextField.secureTextEntry = YES;
    [cell.inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}

- (void)textFieldDidChange:(UITextField *)textField {
    switch (textField.tag) {
        case 101: {
            _setpwdRequestModel.pre_password = textField.text;
        }
            break;
        case 102: {
            _setpwdRequestModel.password = textField.text;
        }
            break;
        case 103: {
            _againPassword = textField.text;
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)sendButtonClick {
    if (_setpwdRequestModel.pre_password.length) {
        
    } else {
        [self alertMessage:@"请输入登录密码"];
        return;
    }
    
    if (_setpwdRequestModel.password.length) {
        
    } else {
        [self alertMessage:@"请输入新密码"];
        return;
    }
    
    if ([_againPassword isEqualToString:_setpwdRequestModel.password]) {
        
    } else {
        [self alertMessage:@"两次密码输入不一致"];
        return;
    }
    [self showHubWithDescription:@"校验中..."];
    self.albumModel.password = _setpwdRequestModel.password;
    LoginRequesModel *loginRequesModel = [[LoginRequesModel alloc] init];
    loginRequesModel.mobile = [GlobalData sharedInstance].userModel.mobile;
    loginRequesModel.password = _setpwdRequestModel.pre_password;
    loginRequesModel.device_id =  [GlobalData sharedInstance].deviceId;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestLoginEnum byRequestDict:loginRequesModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            [[PublishPostDataBase sharedDataBase] updateCurrentPrivateAlbumPasswordByAlbum:self.albumModel CallBack:^(BOOL isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHub];
                });
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress showSuccessWithStatus:@"密码重置成功" completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    });
                } else {
                     [KVNProgress showErrorWithStatus:@"密码重置失败"];
                }
            }];
        } else {
            [KVNProgress showErrorWithStatus:errorModel.errorString];
        }
    }];
    
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
