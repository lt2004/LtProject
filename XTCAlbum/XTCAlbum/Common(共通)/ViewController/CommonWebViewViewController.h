//
//  CommonWebViewViewController.h
//  vs
//
//  Created by Xie Shu on 2017/8/29.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"
#import <WebKit/WebKit.h>

typedef void (^VerifyWebCallBack) (BOOL isFinish);

@interface CommonWebViewViewController : XTCBaseViewController <WKNavigationDelegate>

@property (nonatomic, strong) NSString * _Nullable urlString;
@property (nonatomic, strong) NSString * _Nullable titleString;
@property (nonatomic, assign) BOOL isPreventPanPop; // 是否阻止侧拉返回
@property (nonatomic, strong) UIProgressView * _Nullable progressView;
@property (nonatomic, strong) VerifyWebCallBack _Nullable verifyWebCallBack;

@end
