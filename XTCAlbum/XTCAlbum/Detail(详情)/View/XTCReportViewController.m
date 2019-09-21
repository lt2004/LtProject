//
//  XTCReportViewController.m
//  vs
//
//  Created by Xie Shu on 2018/4/12.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "XTCReportViewController.h"

@interface XTCReportViewController () {
    ReportDiscussRequestModel *_requestModel;
}

@end

@implementation XTCReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
       
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    self.navigationItem.title = NSLocalizedString(@"XTC_Report", @"");
    _reportTextView.delegate = self;
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:NSLocalizedString(@"Report_Send", comment: @"") forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(0, 0, 55, 44);
    [sendButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    sendButton.titleLabel.font = kSystemNormalFont;
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    _defaultLabel.text = NSLocalizedString(@"Report_Reason", comment: @"");
    _requestModel = [[ReportDiscussRequestModel alloc] init];
    _requestModel.token = [GlobalData sharedInstance].userModel.token;
    _requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
    _requestModel.post_id = _reportId;
    _requestModel.discuss_id = _disId;
    _requestModel.reportcontent = @"";
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        _defaultLabel.hidden = YES;
    } else {
        _defaultLabel.hidden = NO;
    }
}

- (void)sendButtonClick {
    [self.view endEditing:YES];
    if (_reportTextView.text == nil || _reportTextView.text.length == 0) {
        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Report_Reason", comment: @"") onView:self.view completion:^{
            
        }];
    } else {
            _requestModel.reportcontent = _reportTextView.text;
            [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestReportPostEnum byRequestDict:_requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
                if (errorModel.errorEnum == ResponseSuccessEnum) {
                    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Report_Success", comment: @"") completion:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
                                [self dismissViewControllerAnimated:YES completion:nil];
                            } else {
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        });
                    }];
                } else {
                    [KVNProgress showErrorWithStatus:errorModel.errorString completion:^{
                        
                    }];
                }
            }];
    }
    
}

- (void)backButtonClick {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    DDLogInfo(@"举报界面释放了");
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
