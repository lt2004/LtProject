//
//  PostDetailLoadingCell.h
//  vs
//
//  Created by Xie Shu on 2018/3/20.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailLoadingCell : UITableViewCell

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UIView *loadingLeftView;
@property (nonatomic, strong) UIView *loadingUpView;
@property (nonatomic, strong) UIView *loadingDownView;
@property (nonatomic, strong) UIView *loadingRightView;
@property (nonatomic, strong) UIView *circleView;
- (void)startAnimation:(BOOL)fromOpacity;

@end
