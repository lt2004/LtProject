//
//  PublishICloudProgressViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZZCircleProgress/ZZCircleProgress.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublishICloudProgressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *dismisButton;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) ZZCircleProgress *circleProgress;
@property (nonatomic, strong) PHAsset *videoAsset;

@end

NS_ASSUME_NONNULL_END
