//
//  PublishLinkUrlViewController.m
//  vs
//
//  Created by Xie Shu on 2017/10/17.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishLinkUrlViewController.h"
#import "MBProgressHUD.h"

@interface PublishLinkUrlViewController ()

@end

@implementation PublishLinkUrlViewController
@synthesize urlTextView = _urlTextView;
@synthesize bottomLayoutConstraint = _bottomLayoutConstraint;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [_urlTextView becomeFirstResponder];
    _urlTextView.delegate = self;
    _defaultLabel.text = @"请输入网址并点击\"验证网站\"按钮验证网站";
    _showWebLinkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_showWebLinkButton addTarget:self action:@selector(showWebLinkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_giveUpButton addTarget:self action:@selector(giveUpButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)giveUpButtonClick {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [_urlTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    _linkUrlBgView.hidden = NO;
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    _bottomLayoutConstraint.constant = height;
}


//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification{
    _linkUrlBgView.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (_verifyFinish) {
        [_showWebLinkButton setTitle:@"验证网站" forState:UIControlStateNormal];
        [_showWebLinkButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _verifyFinish = NO;
    } else {
        
    }
    if (textView.text.length > 0) {
        _defaultLabel.hidden = YES;
    } else {
        _defaultLabel.hidden = NO;
    }
}

- (void)showWebLinkButtonClick {
    __weak typeof(self) weakSelf = self;
    if (self.verifyFinish) {
        self.linkUrlCallabck(_urlTextView.text);
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
        commonWebViewVC.titleString = @"验证网站";
        commonWebViewVC.isPreventPanPop = NO;
        if ([_urlTextView.text hasPrefix:@"http"] || [_urlTextView.text hasPrefix:@"https"]) {
            commonWebViewVC.urlString = _urlTextView.text;
        } else {
            commonWebViewVC.urlString = [NSString stringWithFormat:@"http://%@", _urlTextView.text];
        }
        commonWebViewVC.verifyWebCallBack = ^(BOOL isFinish) {
            weakSelf.verifyFinish = isFinish;
            if (isFinish) {
                [weakSelf.showWebLinkButton setTitle:@"确定" forState:UIControlStateNormal];
                [weakSelf.showWebLinkButton setTitleColor:weakSelf.giveUpButton.titleLabel.textColor forState:UIControlStateNormal];
            } else {
                [weakSelf.showWebLinkButton setTitle:@"验证网站" forState:UIControlStateNormal];
                [weakSelf.showWebLinkButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        };
        XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:commonWebViewVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
