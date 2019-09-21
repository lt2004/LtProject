//
//  SourceShowTimeModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface SourceShowTimeModel : NSObject

@property (nonatomic, strong) PHAsset *photoAsset;
@property (nonatomic, assign) BOOL is_video;
@property (nonatomic, strong) NSString *source_path;
@property (nonatomic, strong) NSDate *source_time;
@property (nonatomic, assign) BOOL isSelectStatus;
@property (nonatomic, strong) UIImage *sourceImage;

@end

NS_ASSUME_NONNULL_END
