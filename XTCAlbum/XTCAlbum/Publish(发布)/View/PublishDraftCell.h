//
//  PublishDraftCell.h
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCircleProgress.h"
#import "XTCDraftPublishModel.h"
#import "XTCPublishSubUploadModel+CoreDataProperties.h"

@interface PublishDraftCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) ZZCircleProgress *circleProgress;
@property (weak, nonatomic) IBOutlet UILabel *publishTypeLabel;

- (void)insertDataToCell:(XTCDraftPublishModel *)postModel;

@end
