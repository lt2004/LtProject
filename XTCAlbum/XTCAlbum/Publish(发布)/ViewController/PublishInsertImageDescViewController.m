//
//  PublishInsertImageDescViewController.m
//  vs
//
//  Created by Xie Shu on 2017/8/29.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishInsertImageDescViewController.h"

@interface PublishInsertImageDescViewController ()

@end

@implementation PublishInsertImageDescViewController
@synthesize imageDescTextView = _imageDescTextView;
@synthesize imageDesc = _imageDesc;

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"ViewSpeaker";
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = HEX_RGB(0x4A4A4A);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = HEX_RGB(0xFAF8F8);
    _imageDescTextView.delegate = self;
    
    UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeperator.width = -10;
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton sizeToFit];
    [finishButton setTitleColor:HEX_RGB(0x4A4A4A) forState:UIControlStateNormal];
    finishButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *finishBarItem = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
    self.navigationItem.rightBarButtonItems = @[rightSeperator, finishBarItem];
    
    _imageDescTextView.text = _imageDesc;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 200) {
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 200)];
    }
    _haveInputLabel.text = [NSString stringWithFormat:@"%ld/200字", textView.text.length];
    _imageDesc = _imageDescTextView.text;
}

- (void)finishButtonClick {
    if (self.imageDescCallback) {
        self.imageDescCallback(_imageDescTextView.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
