//
//  HomePageSearchServiceCell.h
//  vs
//
//  Created by Xie Shu on 2017/8/19.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageSearchServiceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@end
