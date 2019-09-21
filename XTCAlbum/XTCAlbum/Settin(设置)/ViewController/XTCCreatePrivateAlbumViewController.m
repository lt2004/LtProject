//
//  XTCCreatePrivateAlbumViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/14.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCCreatePrivateAlbumViewController.h"

@interface XTCCreatePrivateAlbumViewController ()

@end

@implementation XTCCreatePrivateAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        self.navigationItem.title = @"私密相册";
    _enterButton.layer.borderWidth = 1;
    _enterButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _enterButton.layer.masksToBounds = YES;
    _enterButton.layer.cornerRadius = 25;
    [_enterButton addTarget:self action:@selector(enterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    NSString *createLoginStr = [NSString stringWithFormat:@"OK\n%@", XTCLocalizedString(@"Private_Create_Or_Login", nil)];
    NSMutableAttributedString *enterAttr = [[NSMutableAttributedString alloc] initWithString:createLoginStr];
    NSMutableDictionary *flagAttrDict = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [paragraphStyle setLineSpacing:2];
    [flagAttrDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [flagAttrDict setObject:@(0.5) forKey:NSKernAttributeName];
    [flagAttrDict setObject:RGBCOLOR(31, 31, 31) forKey:NSForegroundColorAttributeName];
    [flagAttrDict setObject:[UIFont fontWithName:kHelvetica size:13] forKey:NSFontAttributeName];
    [enterAttr addAttributes:flagAttrDict range:NSMakeRange(0, enterAttr.string.length)];
    _enterLabel.attributedText = enterAttr;
    
    _passwordTextField.delegate = self;
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    _passwordTextField.secureTextEntry = YES;
    _confirmTextField.delegate = self;
    _confirmTextField.returnKeyType = UIReturnKeyDone;
    _confirmTextField.secureTextEntry = YES;
    
    _headerPasswordLabel.text = XTCLocalizedString(@"ser_005", nil);
    _bottomPasswordLabel.text = XTCLocalizedString(@"Private_Again_password", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)enterButtonClick {
    [self.view endEditing:YES];
    if (_passwordTextField.text == nil || _passwordTextField.text.length == 0) {
        [self alertMessage:XTCLocalizedString(@"ser_005", nil)];
        return;
    }
    if (_confirmTextField.text == nil || _confirmTextField.text.length == 0) {
        [self alertMessage:@"请再次输入密码"];
        return;
    }
    if (![_passwordTextField.text isEqualToString:_confirmTextField.text]) {
        [self alertMessage:@"两次密码输入不一致"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumByPassword:self.passwordTextField.text CallBack:^(NSMutableArray *privateAlbumArray) {
        if (privateAlbumArray.count) {
             weakSelf.passwordTextField.text = @"";
             weakSelf.confirmTextField.text = @"";
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumPrivateDetail" bundle:nil];
            XTCAlbumPrivateDetailViewController *albumPrivateDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumPrivateDetailViewController"];
            albumPrivateDetailVC.albumModel = privateAlbumArray.firstObject;
            [self.navigationController pushViewController:albumPrivateDetailVC animated:YES];
        } else {
            [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumCallBack:^(NSMutableArray *privateAlbumArray) {
                NSString *fileName;
                if (privateAlbumArray.count == 0) {
                    fileName = @"私密_1";
                } else {
                    XTCPrivateAlbumModel *albumModel = privateAlbumArray.lastObject;
                    fileName = [NSString stringWithFormat:@"私密_%d", [albumModel.privateId intValue] + 1];
                }
                [[PublishPostDataBase sharedDataBase] insertPrivateAlbumByFileName:fileName byPassword:self.passwordTextField.text callBack:^(BOOL isSuccess) {
                    if (isSuccess) {
                        // 创建成功
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertMessage:XTCLocalizedString(@"Album_Create_Success", nil)];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumByPassword:self.passwordTextField.text CallBack:^(NSMutableArray *privateAlbumArray) {
                                if (privateAlbumArray.count) {
                                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumPrivateDetail" bundle:nil];
                                    XTCAlbumPrivateDetailViewController *albumPrivateDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumPrivateDetailViewController"];
                                    albumPrivateDetailVC.albumModel = privateAlbumArray.firstObject;
                                    [self.navigationController pushViewController:albumPrivateDetailVC animated:YES];
                                } else {
                                    
                                }
                                weakSelf.passwordTextField.text = @"";
                                weakSelf.confirmTextField.text = @"";
                            }];
                        });
                    } else {
                        weakSelf.passwordTextField.text = @"";
                        weakSelf.confirmTextField.text = @"";
                    }
                }];
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
