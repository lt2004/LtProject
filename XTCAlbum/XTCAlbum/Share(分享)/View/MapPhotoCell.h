//
//  MapPhotoCell.h
//  vs
//
//  Created by Xie Shu on 2018/2/23.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublishSourceModel.h"

@interface MapPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *photoImageView;
- (void)loadAboutData:(NSDictionary *)postDict;
- (void)loadPhotoByModel:(PublishSourceModel *)flagSource;

@end
