//
//  SlideSettingCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SlideSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UISwitch *vrSwitch;
@property (weak, nonatomic) IBOutlet UIButton *modifyNameButton;

@end

NS_ASSUME_NONNULL_END
