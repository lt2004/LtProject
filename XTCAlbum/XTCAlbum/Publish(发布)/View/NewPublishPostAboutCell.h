//
//  NewPublishPostAboutCell.h
//  vs
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewPublishPostAboutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *localImageView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *countryImageView;

- (void)insertAbouData:(PostDetail *)postDetailModel;

@end

NS_ASSUME_NONNULL_END
