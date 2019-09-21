//
//  XTCDraftPublishModel.h
//  ViewSpeaker
//
//  Created by Mac on 2019/7/11.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishMainModel+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCDraftPublishModel : NSObject

@property (nonatomic, strong) UIImage *showImage;
@property (nonatomic, strong) XTCPublishMainModel *publishMainModel;

@end

NS_ASSUME_NONNULL_END
