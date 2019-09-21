//
//  PublishVideoTrimmerViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "ICGVideoTrimmer.h"
#import "SDAVAssetExportSession.h"

typedef void(^TrimmerVideoCallBack)(BOOL isSuccess);

NS_ASSUME_NONNULL_BEGIN

@interface PublishVideoTrimmerViewController : XTCBaseViewController <ICGVideoTrimmerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playBgView;
@property (strong, nonatomic) PHAsset *phAsset;
@property (nonatomic, strong) AVAsset *videoAsset;

@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer * __nullable player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer * __nullable playerLayer;
@property (strong, nonatomic) NSTimer * __nullable playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;

@property (strong, nonatomic) ICGVideoTrimmerView *trimmerView;

@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;
@property (nonatomic, strong) NSString *videoDateStr;

@property (nonatomic, strong) TrimmerVideoCallBack trimmerVideoCallBack;


@property (nonatomic, strong) SDAVAssetExportSession *encoder;
@property (nonatomic, assign) BOOL isLoading;

@end

NS_ASSUME_NONNULL_END
