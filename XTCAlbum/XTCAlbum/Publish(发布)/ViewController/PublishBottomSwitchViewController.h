//
//  PublishBottomSwitchViewController.h
//  vs
//
//  Created by Xie Shu on 2017/10/17.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SwitchCallabck)();

@interface PublishBottomSwitchViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *switchBgView;
@property (weak, nonatomic) IBOutlet UISwitch *friendSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mapSwitch;
@property (nonatomic, strong) SwitchCallabck switchCallabck;
@property (weak, nonatomic) IBOutlet UILabel *businessCountLabel;
@property (weak, nonatomic) IBOutlet UISwitch *businessSwitch;

@end
