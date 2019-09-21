//
//  SlideSettingViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/26.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SlideSettingViewController.h"

@interface SlideSettingViewController () {
    
}

@end

@implementation SlideSettingViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _isCloseShowVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsCloseShowVR];
    _titleLabel.textColor = RGBCOLOR(31, 31, 31);
    _titleLabel.font = [UIFont fontWithName:kHelvetica size:18];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _privateNickName = [[NSUserDefaults standardUserDefaults] objectForKey:kPrivateNickName];
    if (_privateNickName) {
        
    } else {
        _privateNickName = XTCLocalizedString(@"Setting_Private_Album", nil);
    }
    if (kDevice_Is_iPhoneX) {
        _topLayoutConstraint.constant = 84;
    } else {
        _topLayoutConstraint.constant = 64;
    }
    _titleLabel.text = XTCLocalizedString(@"Setting_Album_Setting_Name", nil);
    [self.dismisButton addTarget:self action:@selector(dismisButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _settingTableView.backgroundColor = [UIColor whiteColor];
    _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-100, 75)];
    headerView.backgroundColor = [UIColor whiteColor];
    _settingTableView.tableHeaderView = headerView;
    
    _userHeadeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _userHeadeButton.backgroundColor = kTableviewColor;
    [_userHeadeButton addTarget:self action:@selector(userHeaderButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_userHeadeButton];
    [_userHeadeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView).with.offset(-3);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(headerView).with.offset(20);
    }];
    
    _levelImageView = [[UIImageView alloc] init];
    [headerView addSubview:_levelImageView];
    [_levelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.userHeadeButton);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    
    UIBezierPath *bzpath = [self roundedPolygonPathWithRect:CGRectMake(0, 0, 50, 50) lineWidth:1.0 sides:6 cornerRadius:8];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = bzpath.CGPath;
    mask.lineWidth = 2.0;
    mask.borderColor = [UIColor whiteColor].CGColor;
    mask.strokeColor = [UIColor clearColor].CGColor;
    mask.fillColor = [UIColor whiteColor].CGColor;
    _userHeadeButton.layer.mask = mask;
    
    _nickNameLabel = [[UILabel alloc] init];
    _nickNameLabel.textColor = RGBCOLOR(31, 31, 31);
    _nickNameLabel.text = XTCLocalizedString(@"Setting_Please_Login", nil);
    _nickNameLabel.font = [UIFont fontWithName:kHelvetica size:16];
    [headerView addSubview:_nickNameLabel];
    
    [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(self.userHeadeButton.mas_right).with.offset(10);
    }];
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(userHeaderButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerView);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kTableviewCellColor;
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(headerView);
        make.height.mas_equalTo(1);
    }];
}

- (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *bzpath  = [UIBezierPath bezierPath];
    
    CGFloat theta       = 2.0 * M_PI / sides;                           // how much to turn at every corner
    CGFloat offset      = cornerRadius * tanf(theta / 2.0);             // offset from which to start rounding corners
    CGFloat squareWidth = MIN(square.size.width, square.size.height);   // width of the square
    
    // calculate the length of the sides of the polygon
    
    CGFloat length      = squareWidth - lineWidth;
    if (sides % 4 != 0) {                                               // if not dealing with polygon which will be square with all sides ...
        length = length * cosf(theta / 2.0) + offset/2.0;               // ... offset it inside a circle inside the square
    }
    CGFloat sideLength = length * tanf(theta / 2.0);
    
    // start drawing at `point` in lower right corner
    
    CGPoint point = CGPointMake(squareWidth / 2.0 + sideLength / 2.0 - offset, squareWidth - (squareWidth - length) / 2.0);
    CGFloat angle = M_PI;
    [bzpath moveToPoint:point];
    
    // draw the sides and rounded corners of the polygon
    
    for (NSInteger side = 0; side < sides; side++) {
        point = CGPointMake(point.x + (sideLength - offset * 2.0) * cosf(angle), point.y + (sideLength - offset * 2.0) * sinf(angle));
        [bzpath addLineToPoint:point];
        
        CGPoint center = CGPointMake(point.x + cornerRadius * cosf(angle + M_PI_2), point.y + cornerRadius * sinf(angle + M_PI_2));
        [bzpath addArcWithCenter:center radius:cornerRadius startAngle:angle - M_PI_2 endAngle:angle + theta - M_PI_2 clockwise:YES];
        
        point = bzpath.currentPoint; // we don't have to calculate where the arc ended ... UIBezierPath did that for us
        angle += theta;
    }
    
    [bzpath closePath];
    
    // rotate it 90 degrees
    [bzpath applyTransform:CGAffineTransformMakeRotation(M_PI/2)];
    // now move it back so that the top left of its bounding box is (0,0)
    [bzpath applyTransform:CGAffineTransformMakeTranslation(squareWidth, 0)];
    
    return bzpath;
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"SlideSettingCellName";
    SlideSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[SlideSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }
    cell.modifyNameButton.hidden = YES;
    cell.vrSwitch.hidden = YES;
    cell.titleLabel.textColor = RGBCOLOR(31, 31, 31);
    cell.bottomLabel.textColor = RGBCOLOR(31, 31, 31);
    cell.titleLabel.font = [UIFont fontWithName:kHelvetica size:16];
    cell.bottomLabel.font = [UIFont fontWithName:kHelvetica size:14];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = XTCLocalizedString(@"Setting_Draft", nil);
            cell.bottomLabel.text = @"";
        }
            break;
        case 1: {
            cell.titleLabel.text = XTCLocalizedString(@"Setting_Send_Feedback", nil);
            cell.bottomLabel.text = @"";
        }
            break;
        case 2: {
            cell.titleLabel.text = XTCLocalizedString(@"Setting_About_Us", nil);
            cell.bottomLabel.text = @"";
        }
            break;
        case 3: {
            cell.titleLabel.text = XTCLocalizedString(@"Setting_Invite_Friends", nil);
            cell.bottomLabel.text = @"";
        }
            break;
        case 4: {
            cell.titleLabel.text = XTCLocalizedString(@"Setting_Close_VR_Alert", nil);
            cell.bottomLabel.text = @"";
            cell.vrSwitch.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.vrSwitch.on = _isCloseShowVR;
            [cell.vrSwitch addTarget:self action:@selector(vrSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 5: {
            cell.titleLabel.text = XTCLocalizedString(@"Setting_Download_Travel", nil);
            cell.bottomLabel.text = @"";
        }
            break;
        case 6: {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kPrivateNickName]) {
                cell.modifyNameButton.hidden = YES;
                if (_longPressGestureRecognizer == nil) {
                    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
                    _longPressGestureRecognizer.delegate = self;
                    [_longPressGestureRecognizer addTarget:self action:@selector(longPressModifyNameAlert)];
                    [cell addGestureRecognizer:_longPressGestureRecognizer];
                } else {
                    
                }
            } else {
                cell.modifyNameButton.hidden = NO;
            }
            cell.titleLabel.text = _privateNickName;
            cell.bottomLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.modifyNameButton addTarget:self action:@selector(longPressModifyNameAlert) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 点击了tableViewCell，view的类名为UITableViewCellContentView，则不接收Touch点击事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return YES;
    }
    return NO;
}

#pragma mark - 修改私有相册名称
- (void)longPressModifyNameAlert {
    if ([GlobalData sharedInstance].userModel.token && [GlobalData sharedInstance].userModel.token.length) {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入私密相册别名" message:@"设置完成后可以长按私密相册别名进行编辑" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            
        }];
        UITextField *nameTextField = alertController.textFields.firstObject;
        nameTextField.returnKeyType = UIReturnKeyDone;
        nameTextField.placeholder = @"私密相册别名";
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (nameTextField.text && nameTextField.text.length) {
                [[NSUserDefaults standardUserDefaults] setObject:nameTextField.text forKey:kPrivateNickName];
                weakSelf.privateNickName = nameTextField.text;
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kPrivateNickName];
                weakSelf.privateNickName = @"";
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf.settingTableView reloadData];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];;
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self enterLogin];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
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
    return 55.0f;
}

- (void)loadSettingAboutData {
    XTCUserModel *userModel =  [GlobalData sharedInstance].userModel;
    if (userModel.token && userModel.token.length) {
        _nickNameLabel.text = userModel.nick_name;
        [_userHeadeButton sd_setImageWithURL:[NSURL URLWithString:userModel.headimgurl] forState:UIControlStateNormal];
        [_levelImageView sd_setImageWithURL:[NSURL URLWithString:userModel.level_prc] placeholderImage:nil options:SDWebImageRetryFailed];
    } else {
        _nickNameLabel.text = XTCLocalizedString(@"Setting_Please_Login", nil);
        [_userHeadeButton setImage:nil forState:UIControlStateNormal];
        _levelImageView.image = nil;
    }
    _isCloseShowVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsCloseShowVR];
    [_settingTableView reloadData];
}

- (void)userHeaderButtonClick {
    __weak typeof(self) weakSelf = self;
    XTCUserModel *userModel =  [GlobalData sharedInstance].userModel;
    if (userModel.token && userModel.token.length) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCUserInfor" bundle:nil];
        XTCUserInforViewController *userInforVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCUserInforViewController"];
        userInforVC.exitLoginCallBack = ^(BOOL isLogin) {
            [weakSelf loadSettingAboutData];
            if (isLogin) {
                [weakSelf enterLogin];
            } else {
                
            }
        };
        userInforVC.modifyNickNameCallBack = ^() {
            [weakSelf loadSettingAboutData];
        };
        [[StaticCommonUtil rootNavigationController] pushViewController:userInforVC animated:YES];
    } else {
        [self enterLogin];
    }
    
}

- (void)enterLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumLogin" bundle:nil];
        XTCAlbumLoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumLoginViewController"];
        loginVC.loginSuccessBlock = ^() {
            [weakSelf loadSettingAboutData];
        };
        
        XTCBaseNavigationController *baseNavigation = [[XTCBaseNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:baseNavigation animated:YES completion:^{
            
        }];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XTCUserModel *userModel =  [GlobalData sharedInstance].userModel;
    switch (indexPath.row) {
        case 0: {
            if (userModel.token && userModel.token.length) {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishDraftList" bundle:nil];
                PublishDraftListViewController *publishDraftListVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishDraftListViewController"];
                publishDraftListVC.hidesBottomBarWhenPushed = YES;
                [[StaticCommonUtil rootNavigationController] pushViewController:publishDraftListVC animated:YES];
            } else {
                [self enterLogin];
            }
        }
            break;
        case 1: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCFeedback" bundle:nil];
            XTCFeedbackViewController *feedbackVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCFeedbackViewController"];
            feedbackVC.hidesBottomBarWhenPushed = YES;
            [[StaticCommonUtil rootNavigationController] pushViewController:feedbackVC animated:YES];
        }
            break;
        case 2: {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAboutUs" bundle:nil];
            XTCAboutUsViewController *aboutUsVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAboutUsViewController"];
            [[StaticCommonUtil rootNavigationController] pushViewController:aboutUsVC animated:YES];
        }
            break;
        case 3: {
            // 邀请好友
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCRecommend" bundle:nil];
            XTCRecommendViewController *aboutViewController = [storyBoard instantiateViewControllerWithIdentifier:@"XTCRecommendViewController"];
            aboutViewController.hidesBottomBarWhenPushed = YES;
            [[StaticCommonUtil rootNavigationController] pushViewController:aboutViewController animated:YES];
        }
            break;
        case 4: {
            
        }
            break;
        case 5: {
            // 下载小棠菜旅行
            NSString *urlStr = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.viewspeaker.travel";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
            break;
        case 6: {
            // 私密相册
            __weak typeof(self) weakSelf = self;
            if (userModel.token && userModel.token.length) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kPrivateResetFinish]) {
                    UIStoryboard *createPrivateStoryBoard = [UIStoryboard storyboardWithName:@"XTCCreatePrivateAlbum" bundle:nil];
                    XTCCreatePrivateAlbumViewController *createPrivateAlbumVC = [createPrivateStoryBoard instantiateViewControllerWithIdentifier:@"XTCCreatePrivateAlbumViewController"];
                    createPrivateAlbumVC.hidesBottomBarWhenPushed = YES;
                    [[StaticCommonUtil rootNavigationController] pushViewController:createPrivateAlbumVC animated:YES];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPrivateResetFinish];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
                    requestModel.token = [GlobalData sharedInstance].userModel.token;
                    requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestCloseForgetPwdEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
                        
                    }];
                } else {
                    [self showHubWithDescription:@""];
                    XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
                    requestModel.token = [GlobalData sharedInstance].userModel.token;
                    requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestCheckForgetPwdEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf hideHub];
                            if (errorModel.errorEnum == ResponseSuccessEnum) {
                                NSString *isForgetPwd = object;
                                if ([isForgetPwd intValue]) {
                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"XTCSelectPrivateAlbum" bundle:nil];
                                    XTCSelectPrivateAlbumViewController *selectPrivateAlbumVC = [storyboard instantiateViewControllerWithIdentifier:@"XTCSelectPrivateAlbumViewController"];
                                    [[StaticCommonUtil rootNavigationController] pushViewController:selectPrivateAlbumVC animated:YES];
                                } else {
                                    UIStoryboard *createPrivateStoryBoard = [UIStoryboard storyboardWithName:@"XTCCreatePrivateAlbum" bundle:nil];
                                    XTCCreatePrivateAlbumViewController *createPrivateAlbumVC = [createPrivateStoryBoard instantiateViewControllerWithIdentifier:@"XTCCreatePrivateAlbumViewController"];
                                    createPrivateAlbumVC.hidesBottomBarWhenPushed = YES;
                                    [[StaticCommonUtil rootNavigationController] pushViewController:createPrivateAlbumVC animated:YES];
                                }
                            } else {
                                UIStoryboard *createPrivateStoryBoard = [UIStoryboard storyboardWithName:@"XTCCreatePrivateAlbum" bundle:nil];
                                XTCCreatePrivateAlbumViewController *createPrivateAlbumVC = [createPrivateStoryBoard instantiateViewControllerWithIdentifier:@"XTCCreatePrivateAlbumViewController"];
                                createPrivateAlbumVC.hidesBottomBarWhenPushed = YES;
                                [[StaticCommonUtil rootNavigationController] pushViewController:createPrivateAlbumVC animated:YES];
                            }
                        });
                    }];
                }
            } else {
                [self enterLogin];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)dismisButtonClick {
    [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight);
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    }];
}

- (void)vrSwitchAction:(UISwitch *)flagSwitch {
    _isCloseShowVR = flagSwitch.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:_isCloseShowVR forKey:KIsCloseShowVR];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
