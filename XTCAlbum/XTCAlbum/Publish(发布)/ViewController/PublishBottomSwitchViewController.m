//
//  PublishBottomSwitchViewController.m
//  vs
//
//  Created by Xie Shu on 2017/10/17.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishBottomSwitchViewController.h"

@interface PublishBottomSwitchViewController ()

@end

@implementation PublishBottomSwitchViewController
@synthesize bgView = _bgView;
@synthesize switchBgView = _switchBgView;
@synthesize mapSwitch = _mapSwitch;
@synthesize friendSwitch = _friendSwitch;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _bgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClick)];
    [self.view addGestureRecognizer:tapGes];
    
    UITapGestureRecognizer *flagTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagTapGesClick)];
    [_switchBgView addGestureRecognizer:flagTapGes];
    
    _businessCountLabel.layer.cornerRadius = 10;
    _businessCountLabel.layer.masksToBounds = YES;
    
    _businessCountLabel.text =  [GlobalData sharedInstance].bus_count;
    
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_switchBgView.bounds.origin.x, _switchBgView.bounds.origin.y, kScreenWidth, 200) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(_switchBgView.bounds.origin.x, _switchBgView.bounds.origin.y, kScreenWidth, 200);
    maskLayer.path = maskPath.CGPath;
    _switchBgView.layer.mask = maskLayer;
}


- (void)tapGesClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)doneButtonClick:(id)sender {
    [self tapGesClick];
}

- (void)flagTapGesClick {
    
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
