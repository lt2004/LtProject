//
//  XTCAlbumPrivateViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/14.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCAlbumPrivateViewController.h"

@interface XTCAlbumPrivateViewController () {
    
}

@property (nonatomic, strong) UIButton *createButton;

@end

@implementation XTCAlbumPrivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"私密相册";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _passwordTextField.secureTextEntry = YES;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"忘记密码"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_forgetPasswordButton setAttributedTitle:str forState:UIControlStateNormal];
    [_forgetPasswordButton addTarget:self action:@selector(forgetPasswordButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createButton setTitle:@"创建" forState:UIControlStateNormal];
    [_createButton sizeToFit];
    [_createButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    _createButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [_createButton addTarget:self action:@selector(createButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _createButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_createButton];
    
    UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeperator.width = -10.0;
    self.navigationItem.rightBarButtonItems = @[rightSeperator, rightBarItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumCallBack:^(NSMutableArray *privateAlbumArray) {
        if (privateAlbumArray.count >= 2) {
            self.createButton.hidden = YES;
        } else {
            
        }
    }];
}

#pragma mark - 忘记密码被点击
- (void)forgetPasswordButtonClick {
    /*
    [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumCallBack:^(NSMutableArray *privateAlbumArray) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"XTCSelectPrivateAlbum" bundle:nil];
        XTCSelectPrivateAlbumViewController *selectPrivateAlbumVC = [storyboard instantiateViewControllerWithIdentifier:@"XTCSelectPrivateAlbumViewController"];
        selectPrivateAlbumVC.privateArray = privateAlbumArray;
        [self.navigationController pushViewController:selectPrivateAlbumVC animated:YES];
    }];
    */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"XTCSelectPrivateAlbum" bundle:nil];
    XTCSelectPrivateAlbumViewController *selectPrivateAlbumVC = [storyboard instantiateViewControllerWithIdentifier:@"XTCSelectPrivateAlbumViewController"];
    [self.navigationController pushViewController:selectPrivateAlbumVC animated:YES];
}

- (void)createButtonClick {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCCreatePrivateAlbum" bundle:nil];
    XTCCreatePrivateAlbumViewController *createPrivateAlbumVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCCreatePrivateAlbumViewController"];
    createPrivateAlbumVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createPrivateAlbumVC animated:YES];
    
}

- (IBAction)enterPrivateDetailClick:(id)sender {
    if (_passwordTextField.text == nil || _passwordTextField.text.length == 0) {
        [self alertMessage:XTCLocalizedString(@"ser_005", nil)];
    } else {
        [self.view endEditing:YES];
        [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumByPassword:_passwordTextField.text CallBack:^(NSMutableArray *privateAlbumArray) {
            if (privateAlbumArray.count) {
                self->_passwordTextField.text = @"";
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumPrivateDetail" bundle:nil];
                XTCAlbumPrivateDetailViewController *albumPrivateDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumPrivateDetailViewController"];
                albumPrivateDetailVC.albumModel = privateAlbumArray.firstObject;
                [self.navigationController pushViewController:albumPrivateDetailVC animated:YES];
            } else {
                [self alertMessage:@"密码错误"];
            }
        }];
       
    }
    
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
