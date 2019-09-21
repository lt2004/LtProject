//
//  PublishPickerShowCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCPublishPhotoShowView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishPickerShowCell : UICollectionViewCell

@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, strong) XTCPublishPhotoShowView *previewView;

@end

NS_ASSUME_NONNULL_END
