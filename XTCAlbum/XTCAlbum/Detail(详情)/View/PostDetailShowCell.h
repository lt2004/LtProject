//
//  PostDetailShowCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCPostDetailSourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostDetailShowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;



- (void)insertAboutData:(XTCPostDetailSourceModel *)detailSourceModel;

@end

NS_ASSUME_NONNULL_END
