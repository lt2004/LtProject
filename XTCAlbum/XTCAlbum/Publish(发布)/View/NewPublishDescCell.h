//
//  NewPublishDescCell.h
//  vs
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewPublishDescCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UITextView *postDescTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descHeightLayoutConstraint;

@end

NS_ASSUME_NONNULL_END
