//
//  XTCPostTitleDescCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTCPostTitleDescCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *showTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@end

NS_ASSUME_NONNULL_END
