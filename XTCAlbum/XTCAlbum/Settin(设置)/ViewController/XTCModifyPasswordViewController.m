//
//  XTCModifyPasswordViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCModifyPasswordViewController.h"

@interface XTCModifyPasswordViewController () {
    SetpwdRequestModel *_setpwdRequestModel;
    NSString *_againPassword;
}

@end

@implementation XTCModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = XTCLocalizedString(@"Infor_Modify_Password", nil);
    if (@available(iOS 11.0, *)) {
        _modifyPasswordTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _setpwdRequestModel = [[SetpwdRequestModel alloc] init];
    _setpwdRequestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
    _setpwdRequestModel.token = [GlobalData sharedInstance].userModel.token;
    _setpwdRequestModel.password = @"";
    _setpwdRequestModel.pre_password = @"";
    _againPassword = @"";
    
    _modifyPasswordTableView.separatorColor = kTableviewCellColor;
    _modifyPasswordTableView.backgroundColor = kTableviewColor;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"确定" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(0, 0, 55, 44);
//    sendButton.backgroundColor = [UIColor redColor];
//    [sendButton sizeToFit];
    [sendButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
            cell.headerLabel.text = XTCLocalizedString(@"Info_Current_Password", nil);
            cell.detailDescLabel.text = @"Password";
            cell.inputTextField.placeholder = XTCLocalizedString(@"Info_Please_Input_Current_Password", nil);
            cell.inputTextField.tag = 101;
        }
            break;
        case 1: {
            cell.headerLabel.text = XTCLocalizedString(@"Info_New_Password", nil);
            cell.detailDescLabel.text = @"New password";
            cell.inputTextField.placeholder = XTCLocalizedString(@"Infor_Please_New_Password", nil);
            cell.inputTextField.tag = 102;
        }
            break;
        case 2: {
            cell.headerLabel.text = XTCLocalizedString(@"Info_Again_Password", nil);
            cell.detailDescLabel.text = @"Confirm password";
            cell.inputTextField.placeholder = XTCLocalizedString(@"Infor_Please_Again_New_Password", nil);
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
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"Info_Please_Input_Current_Password", nil) completion:^{
            
        }];
        return;
    }
    
    if ([_againPassword isEqualToString:_setpwdRequestModel.password]) {
        
    } else {
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"ser_014", nil) completion:^{
            
        }];
        return;
    }
    
    //密码
    if (_setpwdRequestModel.password.length>7 && _setpwdRequestModel.password.length<17) {
        
    }else{
        [KVNProgress showErrorWithStatus:XTCLocalizedString(@"Login_Password_Max", nil) completion:^{
            
        }];
        return;
    }
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestSetpwdEnum byRequestDict:_setpwdRequestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            [KVNProgress showSuccessWithStatus:XTCLocalizedString(@"ser_022", nil) completion:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
                if (self.modifyPasswordSuccessBlock) {
                    self.modifyPasswordSuccessBlock();
                } else {
                    
                }
            }];
        } else {
            [KVNProgress showErrorWithStatus:errorModel.errorString completion:^{
                
            }];
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
