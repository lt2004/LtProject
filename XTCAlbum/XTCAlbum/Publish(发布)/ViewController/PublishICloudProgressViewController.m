//
//  PublishICloudProgressViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PublishICloudProgressViewController.h"

@interface PublishICloudProgressViewController ()

@end

@implementation PublishICloudProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_dismisButton setTitle:@"取消iCloud下载" forState:UIControlStateNormal];
    _bgView.layer.cornerRadius = 6;
    _bgView.layer.masksToBounds = YES;
    
    _circleProgress = [[ZZCircleProgress alloc] initWithFrame:CGRectMake(85, 35, 70, 70) pathBackColor:kTableviewCellColor pathFillColor:HEX_RGB(0x8FDA3C) startAngle:0 strokeWidth:3];
    _circleProgress.progress = 0.5;
    _circleProgress.increaseFromLast = YES;
    _circleProgress.showPoint = NO;
//    _circleProgress.progressLabel.font = [UIFont fontWithName:kHelvetica size:16];
    [_bgView addSubview:_circleProgress];
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
