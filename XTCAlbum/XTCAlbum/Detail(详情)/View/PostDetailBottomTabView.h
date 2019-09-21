//
//  PostDetailBottomTabView.h
//  vs
//
//  Created by Xie Shu on 2017/10/23.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailBottomTabView : UIView

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *goodCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end
