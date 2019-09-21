//
//  CommonWebViewViewController.m
//  vs
//
//  Created by Xie Shu on 2017/8/29.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "CommonWebViewViewController.h"
#import <RegexKitLite/RegexKitLite.h>

@interface CommonWebViewViewController () {
    WKWebView *_h5WebView;
}

@end

@implementation CommonWebViewViewController
@synthesize urlString = _urlString;
@synthesize titleString = _titleString;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isPreventPanPop) {
        UIPanGestureRecognizer *cancelFullScreenGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cancelFullScreenGes)];
        [self.view addGestureRecognizer:cancelFullScreenGes];
    } else {
        
    }
    if (self.verifyWebCallBack) {
         NSString *regulaStr = @"((http[s]{0,1})://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        if ([_urlString isMatchedByRegex:regulaStr]) {
            self.navigationItem.title = @"验证中...";
        } else {
            self.verifyWebCallBack(NO);
            self.navigationItem.title = @"验证失败";
        }
        
    } else {
        self.navigationItem.title = _titleString;
    }
    _h5WebView = [[WKWebView alloc] init];
    _h5WebView.backgroundColor = [UIColor whiteColor];
    _h5WebView.opaque = NO;
    _h5WebView.navigationDelegate = self;
    [self.view addSubview:_h5WebView];
    
    [_h5WebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [_h5WebView loadRequest:request];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = [UIColor blueColor];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.height.mas_equalTo(2);
    }];
    
    // 给webview添加监听
    [_h5WebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"] && object == _h5WebView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:_h5WebView.estimatedProgress animated:YES];
        if (_h5WebView.estimatedProgress  >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:YES];
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)cancelFullScreenGes {
    
}


// 3 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.verifyWebCallBack) {
        self.verifyWebCallBack(YES);
        self.navigationItem.title = @"验证成功";
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"网页加载失败");
    if (self.verifyWebCallBack) {
        self.verifyWebCallBack(NO);
        self.navigationItem.title = @"验证失败";
    }
}

- (void)backButtonClick {
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    DDLogInfo(@"网页加载释放");
    [_h5WebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_h5WebView setNavigationDelegate:nil];
    [_h5WebView setUIDelegate:nil];
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
