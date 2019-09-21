//
//  NewPublishMakeTagViewController.m
//  ViewSpeaker
//
//  Created by Mac on 2019/3/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "NewPublishMakeTagViewController.h"

@interface NewPublishMakeTagViewController ()

@end

@implementation NewPublishMakeTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    _selectSystemStr = @"";
    _historyTagArray = [[NSMutableArray alloc] init];
    NSString *historyTagString = [[NSUserDefaults standardUserDefaults] objectForKey:@"HistoryTag"];
    if (historyTagString && historyTagString.length) {
        [_historyTagArray addObjectsFromArray: [historyTagString componentsSeparatedByString:@","]];
    } else {
        
    }
    
    // 40为顶部的取消确认
    if (_historyTagArray.count) {
        _heightLayoutConstraint.constant = 225 + 40;
    } else {
        _heightLayoutConstraint.constant = 165 + 40;
    }
    
    NSDictionary *flagDict = (NSDictionary *)[[EGOCache globalCache] objectForKey:@"XtcSubTag"];
    NSDictionary *resultDict = flagDict[@"result"];
    if (resultDict) {
        NSArray *publishArray = resultDict[@"publish"];
        if (publishArray.count) {
            _systemTagArray = [[NSMutableArray alloc] init];
            for (NSDictionary *flagTagDict in publishArray) {
                [_systemTagArray addObject:flagTagDict[@"name"]];
            }
        } else {
            _systemTagArray = [[NSMutableArray alloc] initWithArray: [NSArray arrayWithObjects:@"风景", @"美食", @"人文", @"娱乐", nil]];
        }
    } else {
        _systemTagArray = [[NSMutableArray alloc] initWithArray: [NSArray arrayWithObjects:@"风景", @"美食", @"人文", @"娱乐", nil]];
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_bgView.bounds.origin.x, _bgView.bounds.origin.y, kScreenWidth, _heightLayoutConstraint.constant) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(_bgView.bounds.origin.x, _bgView.bounds.origin.y, kScreenWidth, _heightLayoutConstraint.constant);
    maskLayer.path = maskPath.CGPath;
    _bgView.layer.mask = maskLayer;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    // 取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"关闭" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:16];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.right.equalTo(headerView).with.offset(-8);
        make.size.mas_equalTo(CGSizeMake(50, 35));
    }];
    
    _tagTableView.tableHeaderView = headerView;
    _tagTableView.scrollEnabled = NO;
    _tagTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _inputTextField.returnKeyType = UIReturnKeyDone;
    _inputTextField.enablesReturnKeyAutomatically = YES;
    _inputTextField.delegate = self;
}

#pragma mark - 确定选择的标签
- (void)submitlButtonClick {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.showSelectPublishTagsCallback) {
            self.showSelectPublishTagsCallback(self.selectArray);
        } else {
            
        }
    }];
}

- (void)cancelButtonClick {
    [self submitlButtonClick];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_inputTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        // 有选中标签
        if (_selectArray.count) {
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.showSelectPublishTagsCallback) {
                    self.showSelectPublishTagsCallback(self.selectArray);
                } else {
                    
                }
            }];
        } else {
            [self alertMessage:@"请输入标签"];
        }
    } else {
        // 添加标签判断
        if (textField.text.length > 6) {
            [self alertMessage:@"标签不能大于6个字"];
        } else {
            if ([_selectArray containsObject:textField.text]) {
                [self alertMessage:@"不能添加重复标签"];
            } else {
                if (_selectArray.count >= 6) {
                    [self alertMessage:@"标签数已达上限"];
                } else {
                    if ([_systemTagArray containsObject:textField.text]) {
                        // 替换
                        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",_systemTagArray];
                        NSArray *filterArray = [_selectArray filteredArrayUsingPredicate:filterPredicate];
                        _selectArray = [[NSMutableArray alloc] initWithArray:filterArray];
                        [_selectArray addObject:textField.text];
                        _selectSystemStr = textField.text;
                    } else {
                        [_selectArray addObject:textField.text];
                    }
                    [_tagTableView reloadData];
                    textField.text = @"";
                }
            }
        }
        
        
        
    }
    return YES;
}

- (void)alertMessage:(NSString *)msg {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:0.8];
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_historyTagArray.count) {
        return 3;
    } else {
        return 2;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    static NSString *cellName = @"NewPublishMakeTagCellName";
    NewPublishMakeTagCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[NewPublishMakeTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    switch (indexPath.section) {
        case 0: {
            cell.publishTagType = NewPublishTagSelectType;
            [cell loadAboutData:_selectArray];
        }
            break;
        case 1: {
            cell.selectSystemStr = _selectSystemStr;
            cell.publishTagType = NewPublishTagSystemType;
            [cell loadAboutData:_systemTagArray];
        }
            break;
        case 2: {
            cell.publishTagType = NewPublishTagHistoryType;
            [cell loadAboutData:_historyTagArray];
        }
            break;
            
        default:
            break;
    }
    cell.deleteSelectTagCallback = ^(NSString * _Nullable deleteStr) {
        [weakSelf.selectArray removeObject:deleteStr];
        if ([weakSelf.systemTagArray containsObject:deleteStr]) {
            weakSelf.selectSystemStr = @"";
        } else {
            
        }
        [weakSelf.tagTableView reloadData];
    };
    cell.addSelectTagCallback = ^(NSString * _Nullable addStr) {
        if ([weakSelf.selectArray containsObject:addStr]) {
            [self alertMessage:@"不能添加重复标签"];
        } else {
            if ([weakSelf.selectArray containsObject:weakSelf.selectSystemStr] && [weakSelf.systemTagArray containsObject:addStr]) {
                [weakSelf.selectArray removeObject:weakSelf.selectSystemStr];
            } else {
                if (weakSelf.selectArray.count >= 6) {
                    [self alertMessage:@"标签数已达上限"];
                    return;
                } else {
                    
                }
            }
            [weakSelf.selectArray addObject:addStr];
            if ([weakSelf.systemTagArray containsObject:addStr]) {
                weakSelf.selectSystemStr = addStr;
            } else {
                
            }
            [weakSelf.tagTableView reloadData];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:kHelvetica size:14];
    titleLabel.textColor = RGBCOLOR(31, 31, 31);
    switch (section) {
        case 0: {
            titleLabel.text = @"已选标签(点击删除)";
        }
            break;
        case 1: {
            titleLabel.text = @"推荐标签";
        }
            break;
        case 2: {
            titleLabel.text = @"历史标签";
        }
            break;
            
        default:
            break;
    }
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).with.offset(15);
        make.centerY.equalTo(headerView);
    }];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

- (IBAction)dismisButtonClick:(id)sender {
    [self submitlButtonClick];
}


- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        if (kDevice_Is_iPhoneX) {
            self.keyBottomLayoutContraint.constant = height-kBottom_iPhoneX;
        } else {
            self.keyBottomLayoutContraint.constant = height;
        }
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)addButtonClick:(id)sender {
    if (_inputTextField.text && _inputTextField.text.length) {
        [self textFieldShouldReturn:_inputTextField];
    } else {
        [self alertMessage:@"请输入标签"];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
