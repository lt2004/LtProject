//
//  VRDetailShowDescViewController.m
//  vs
//
//  Created by Xie Shu on 2018/4/9.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "VRDetailShowDescViewController.h"

@interface VRDetailShowDescViewController ()

@end

@implementation VRDetailShowDescViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView.layer.cornerRadius = 6;
    self.bgView.layer.masksToBounds = YES;
    self.userHeaderImageView.layer.cornerRadius = 40;
    self.userHeaderImageView.layer.masksToBounds = YES;
    [self.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.descTextView.showsVerticalScrollIndicator = NO;
}

- (void)closeButtonClick {
    [self dismissViewControllerAnimated:NO completion:^{
        
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
