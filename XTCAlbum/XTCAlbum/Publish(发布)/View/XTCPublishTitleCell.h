//
//  XTCPublishTitleCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/5.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *recordAudioButton;

@end

NS_ASSUME_NONNULL_END
