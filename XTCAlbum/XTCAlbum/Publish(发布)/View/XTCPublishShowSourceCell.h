//
//  XTCPublishShowSourceCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/6.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishShowSourceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet UIView *videoBgView;
@property (weak, nonatomic) IBOutlet UIButton *showImageButton;

@end

NS_ASSUME_NONNULL_END
