//
//  PublishVideoTrimmerViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PublishVideoTrimmerViewController.h"

@interface PublishVideoTrimmerViewController ()

@end

@implementation PublishVideoTrimmerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"视频截取";
    
    // 视频截取按钮
    UIButton *rightSubmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightSubmitButton setTitle:@"截取" forState:UIControlStateNormal];
    rightSubmitButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [rightSubmitButton sizeToFit];
    rightSubmitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightSubmitButton setTitleColor:HEX_RGB(0x4A4A4A) forState:UIControlStateNormal];
    [rightSubmitButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightSubmitButton];
    
    _isLoading = YES;
    // 屏蔽返回上一页手势
    UIPanGestureRecognizer *cancelFullScreenGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFullScreenGes)];
    [self.view addGestureRecognizer:cancelFullScreenGes];
    [self showHubWithDescription:@"视频下载中...."];
    __weak typeof(self) weakSelf = self;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = true;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:self.phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
            DDLogInfo(@"视频在icloud上");
        }
        weakSelf.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
            weakSelf.videoAsset = asset;
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            weakSelf.player = [AVPlayer playerWithPlayerItem:item];
            weakSelf.playerLayer = [AVPlayerLayer playerLayerWithPlayer:weakSelf.player];
            weakSelf.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
            [weakSelf.playBgView.layer addSublayer:weakSelf.playerLayer];
            weakSelf.playerLayer.frame = CGRectMake(0, 0, kScreenWidth, 0.75*kScreenWidth);
            weakSelf.playBgView.backgroundColor = [UIColor clearColor];
            [weakSelf.player play];
            [weakSelf startPlaybackTimeChecker];
            // 视频截取部分
            weakSelf.trimmerView = [[ICGVideoTrimmerView alloc] initWithFrame:CGRectMake(0, 0.75*kScreenWidth+80+30, kScreenWidth, 100) asset:asset];
            weakSelf.trimmerView.backgroundColor = [UIColor blackColor];
            [weakSelf.view addSubview:weakSelf.trimmerView];
            [weakSelf.trimmerView setThemeColor:[UIColor lightGrayColor]];
            if ([[GlobalData sharedInstance].userModel.level intValue] >= 4) {
                weakSelf.trimmerView.maxLength = 120;
            } else {
                weakSelf.trimmerView.maxLength = 60;
            }
            [weakSelf.trimmerView setShowsRulerView:YES];
            [weakSelf.trimmerView setTrackerColor:[UIColor cyanColor]];
            [weakSelf.trimmerView setDelegate:weakSelf];
            [weakSelf.trimmerView resetSubviews];
        });
    }];
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}

- (void)onPlaybackTimeCheckerTimer
{
    self.videoPlaybackPosition = CMTimeGetSeconds([self.player currentTime]);
    
    [self.trimmerView seekToTime:CMTimeGetSeconds([self.player currentTime])];
    
    if (self.videoPlaybackPosition >= self.stopTime) {
        self.videoPlaybackPosition = self.startTime;
        [self seekVideoToPos: self.startTime];
        [self.trimmerView seekToTime:self.startTime];
    }
}

#pragma mark - ICGVideoTrimmerDelegate
- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    if (startTime != self.startTime) {
        [self seekVideoToPos:startTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
}

- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)cancelFullScreenGes {
    
}


- (void)saveButtonClick {
    if (_isLoading) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self showHubWithDescription:@"截取中..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *exportUrlStr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        exportUrlStr = [NSString stringWithFormat:@"%@/%@_high_video.mp4", exportUrlStr, self.videoDateStr];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportUrlStr]) {
            @try {
                [[NSFileManager defaultManager] removeItemAtPath:exportUrlStr error:nil];
            } @catch(NSException *exception) {
                
            }
            
        } else {
            
        }
        
        
        BOOL isNeeddCom = YES;
        AVURLAsset* avUrlAsset = (AVURLAsset*)self.videoAsset;
        NSNumber *size;
        [avUrlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
        if ([size floatValue]/1024.0/self.phAsset.duration < kSizeMaxSecond) {
            isNeeddCom = NO;
        } else {
            isNeeddCom = YES;
        }
        NSURL *url = [NSURL fileURLWithPath:exportUrlStr];
        if (isNeeddCom) {
            // 视频码率压缩部分
            self.encoder = [SDAVAssetExportSession.alloc initWithAsset:self.videoAsset];
            self.encoder.outputURL = url;
            self.encoder.outputFileType = AVFileTypeMPEG4;
            self.encoder.shouldOptimizeForNetworkUse = YES;
            
            NSInteger flagWidth = self.phAsset.pixelWidth;
            NSInteger flagHeight = self.phAsset.pixelHeight;
            BOOL isHightVideo = NO;
            int standardSize = 720;
            if (flagWidth >= 1080 && flagHeight >= 1080) {
                isHightVideo = YES;
                standardSize = 1080;
            } else {
                
            }
            CGFloat scale;
            if (flagWidth > flagHeight) {
                scale = ((CGFloat)flagWidth)/flagHeight;
                flagHeight = standardSize;
                flagWidth = flagHeight*scale;
            } else {
                scale = ((CGFloat)flagHeight)/flagWidth;
                flagWidth = standardSize;
                flagHeight = flagWidth*scale;
            }
            // 预期视频的编码帧率 AVVideoExpectedSourceFrameRateKey
            NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @((isHightVideo ? kVideoHighBitRateKey : kVideoBitRateKey)*1024),
                                                     AVVideoExpectedSourceFrameRateKey : @(30),
                                                     AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel };
            //视频属性
            self.encoder.videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                            AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                            AVVideoWidthKey : @(flagWidth),
                                            AVVideoHeightKey : @(flagHeight),
                                            AVVideoCompressionPropertiesKey : compressionProperties };
            
            
            // 音频设置
            self.encoder.audioSettings = @{ AVEncoderBitRatePerChannelKey : @(60000),
                                            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                            AVNumberOfChannelsKey : @(2),
                                            AVSampleRateKey : @(44100) };
            
            [self.encoder exportAsynchronouslyWithCompletionHandler:^ {
                int status = self.encoder.status;
                if (status == AVAssetExportSessionStatusCompleted) {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        //获取视频总时长
                        [self cropWithVideoUrlStr:url start:self.startTime end:self.stopTime completion:^(NSURL *outputURL, Float64 videoDuration, BOOL isSuccess) {
                            if (isSuccess) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (weakSelf.player) {
                                        [weakSelf.playerLayer removeFromSuperlayer];
                                        weakSelf.playerLayer = nil;
                                        [weakSelf.player pause];
                                        weakSelf.player = nil;
                                    } else {
                                        
                                    }
                                     weakSelf.trimmerView.backgroundColor = [UIColor whiteColor];
                                    [weakSelf.trimmerView removeFromSuperview];
                                    [weakSelf stopPlaybackTimeChecker];
                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                    if (weakSelf.trimmerVideoCallBack) {
                                        weakSelf.trimmerVideoCallBack(YES);
                                    } else {
                                        
                                    }
                                });
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self alertMessage:@"截取失败"];
                                });
                            }
                            
                        }];
                    });
                } else if (status == AVAssetExportSessionStatusFailed) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf alertMessage:@"截取失败"];
                    });
                } else {
                    
                }
            }];
        } else {
            // 直接导出
            AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:self.videoAsset presetName:AVAssetExportPresetHighestQuality];
            exportSession.shouldOptimizeForNetworkUse = YES;
            exportSession.outputURL = [NSURL fileURLWithPath:exportUrlStr];
            exportSession.outputFileType = AVFileTypeMPEG4;
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self cropWithVideoUrlStr:url start:self.startTime end:self.stopTime completion:^(NSURL *outputURL, Float64 videoDuration, BOOL isSuccess) {
                        if (isSuccess) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 weakSelf.trimmerView.backgroundColor = [UIColor whiteColor];
                                [weakSelf.trimmerView removeFromSuperview];
                                [weakSelf stopPlaybackTimeChecker];
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                                if (weakSelf.trimmerVideoCallBack) {
                                    weakSelf.trimmerVideoCallBack(YES);
                                } else {
                                    
                                }
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf alertMessage:@"截取失败"];
                            });
                        }
                        
                    }];
                });
            }];
        }
    });
}

- (void)cropWithVideoUrlStr:(NSURL *)videoUrl start:(CGFloat)startTime end:(CGFloat)endTime completion:(void (^)(NSURL *outputURL, Float64 videoDuration, BOOL isSuccess))completionHandle
{
    AVURLAsset *asset =[[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    NSString *videoOutputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    videoOutputURL =  [NSString stringWithFormat:@"%@/%@_video.mp4", videoOutputURL, self.videoDateStr];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoOutputURL]) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:videoOutputURL error:nil];
        } @catch(NSException *exception) {
            
        }
    } else {
        
    }
    
    
    NSURL *outputFileUrl = [NSURL fileURLWithPath:videoOutputURL];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                           initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    
    exportSession.outputURL = outputFileUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    CMTime start = CMTimeMakeWithSeconds(startTime, asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(endTime - startTime, asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHub];
        });
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                completionHandle(outputFileUrl, endTime, NO);
            }
                break;
            case AVAssetExportSessionStatusCancelled:
            {
                completionHandle(outputFileUrl, endTime, NO);
            }
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                completionHandle(outputFileUrl, endTime, YES);
            }
                break;
            default:
            {
                completionHandle(outputFileUrl, endTime, NO);
            } break;
        }
    }];
}

- (void)dealloc {
    DDLogInfo(@"视频截取内存页释放");
    if (self.player) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        [self.player pause];
        self.player = nil;
    } else {
        
    }
}

- (void)backButtonClick {
    if (self.player) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        [self.player pause];
        self.player = nil;
    } else {
        
    }
    [self stopPlaybackTimeChecker];
    self.playBgView.backgroundColor = [UIColor whiteColor];
     self.trimmerView.backgroundColor = [UIColor whiteColor];
    [self.trimmerView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToViewController: self.navigationController.viewControllers[self.navigationController.viewControllers.count-3] animated:YES];
    if (self.trimmerVideoCallBack) {
        self.trimmerVideoCallBack(NO);
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
