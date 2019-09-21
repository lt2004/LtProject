//
//  PostDetailLoadingView.h
//  vs
//
//  Created by Xie Shu on 2018/3/20.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetailLoadingCell.h"

@interface PostDetailLoadingView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *loadingTableView;

@end
