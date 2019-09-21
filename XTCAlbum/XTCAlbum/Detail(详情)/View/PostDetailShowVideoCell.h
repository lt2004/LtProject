//
//  PostDetailShowVideoCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/7/12.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCPostDetailSourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostDetailShowVideoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (weak, nonatomic) IBOutlet UIView *playBgView;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;
- (void)insertAboutData:(XTCPostDetailSourceModel *)detailSourceModel;

@end

NS_ASSUME_NONNULL_END
