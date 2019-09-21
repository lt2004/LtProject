//
//  TimeLineYearCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeLineYearCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

NS_ASSUME_NONNULL_END
