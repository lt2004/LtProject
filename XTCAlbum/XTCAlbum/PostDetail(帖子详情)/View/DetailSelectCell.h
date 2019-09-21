//
//  DetailSelectCell.h
//  vs
//
//  Created by Xie Shu on 2017/8/5.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetail.h"

@interface DetailSelectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

- (void)insertAbouData:(PostDetail *)postDetailModel;

@end
