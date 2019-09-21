//
//  HomeSearchHeaderView.h
//  vs
//
//  Created by Xie Shu on 2017/8/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeSearchHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;
@property (weak, nonatomic) IBOutlet UIImageView *selelctFlagImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;

@end
