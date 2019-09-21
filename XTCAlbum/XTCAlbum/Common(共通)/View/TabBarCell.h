//
//  TabBarCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface TabBarCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *statusLabel;

@end

NS_ASSUME_NONNULL_END
