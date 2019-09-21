//
//  XTCUserHeaderCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTCUserHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userHeaderButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
