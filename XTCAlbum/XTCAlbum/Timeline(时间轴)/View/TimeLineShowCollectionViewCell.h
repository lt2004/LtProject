//
//  TimeLineShowCollectionViewCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SourceShowTimeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeLineShowCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *showThumbnailView;

@property (nonatomic, copy)   NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@property (weak, nonatomic) IBOutlet UIView *selectBgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;


@property (weak, nonatomic) IBOutlet UIView *corverView; // 覆盖层

@property (nonatomic, strong) SourceShowTimeModel *sourceTimeModel;
@property (nonatomic, strong) NSIndexPath *flagIndexPath;

@end

NS_ASSUME_NONNULL_END
