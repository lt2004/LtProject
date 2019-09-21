//
//  ProShowDetailUserInforCell.h
//  vs
//
//  Created by Xie Shu on 2017/11/7.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProDetail.h"
#import "NBZUtil.h"

@interface ProShowDetailUserInforCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userImageButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

- (void)insertDataToUserInforCell:(ProDetail *)proDetail;

@end
