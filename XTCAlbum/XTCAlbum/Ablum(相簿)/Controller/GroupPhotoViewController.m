//
//  GroupPhotoViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/21.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "GroupPhotoViewController.h"

@interface GroupPhotoViewController () {
    CGFloat _picTime; // 每张图片展示时间
}

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, assign) BOOL isCreateVideoFinish;
@property (nonatomic, strong) NSString *videoPhotoPath;
@property (nonatomic, strong) NSString *videoFinishPath;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) int frameNumber;
@property (nonatomic, assign) CGSize naturalSize;

@end

@implementation GroupPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"照片处理中";
    _naturalSize = CGSizeMake(720, 1080);
    _frameNumber = 25;
    _isCreateVideoFinish = NO;
    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createButton setTitle:@"合成" forState:UIControlStateNormal];
    _createButton.frame = CGRectMake(0, 0, 55, 44);
    [_createButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    _createButton.titleLabel.font = kSystemNormalFont;
    [_createButton addTarget:self action:@selector(createButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_createButton];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    _imageArray = [[NSMutableArray alloc]init];
    
    __weak typeof(self) weakSelf = self;
    [self showHubWithDescription:@"照片处理中"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (PHAsset *flagAsset in weakSelf.photoAssetArray) {
            [[TZImageManager manager] getPhotoWithAsset:flagAsset photoWidth:720 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    
                } else {
                    [weakSelf.imageArray addObject:[self imageWithImage:photo scaledToSize:self.naturalSize]];
                    dispatch_semaphore_signal(semaphore);
                }
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        // 照片获取完毕准备合成视频
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
            weakSelf.navigationItem.title = @"照片处理完成";
        });
    });
    
}

//视频合成按钮点击操作
- (void)createButtonClick {
    if (_isCreateVideoFinish) {
        
    } else {
        // 照片合成视频
        _picTime = 3;
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"empty_video" ofType:@".mp4"];
        CGFloat tempDuration = self.imageArray.count*_picTime;
        self.duration = tempDuration > 180.0 ? 180.0 : tempDuration;
        
        //设置mov路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *outMoviePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"photo_group_video"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:outMoviePath]) {
            @try {
                [[NSFileManager defaultManager] removeItemAtPath:outMoviePath error:nil];
            } @catch(NSException *exception) {
                
            }
        } else {
            
        }
        _videoPhotoPath = outMoviePath;
        AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        AVMutableComposition *mutableComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        
        //合成视频时间
        CMTime endTime = CMTimeMake(videoAsset.duration.timescale * (int)self.duration, videoAsset.duration.timescale);
        CMTimeRange timeR = CMTimeRangeMake(kCMTimeZero, endTime);
        
        @try {
            [videoCompositionTrack insertTimeRange:timeR ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
        } @catch(NSException *exception) {
            
        }
        //创建合成指令
        AVMutableVideoCompositionInstruction *videoCompostionInstruction = [AVMutableVideoCompositionInstruction new];
        //设置时间范围
        videoCompostionInstruction.timeRange = timeR;
        
        //创建层指令，并将其与合成视频轨道相关联
        AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
        [videoLayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
        [videoLayerInstruction setOpacity:0 atTime:endTime];
        videoCompostionInstruction.layerInstructions = @[videoLayerInstruction];
        
        //创建视频组合
        AVMutableVideoComposition *mutableVideoComposition = [[AVMutableVideoComposition alloc] init];
        mutableVideoComposition.renderSize = self.naturalSize;
        //设置帧率
        mutableVideoComposition.frameDuration = CMTimeMake(1, _frameNumber);
        mutableVideoComposition.instructions = @[videoCompostionInstruction];
        [self addLayerByComposition:mutableVideoComposition byImagess:self.imageArray];
        [self setupAssetExportByComposition:mutableComposition byVideoCom:mutableVideoComposition byAudioMix:nil];
    }
}

#pragma mark - 照片合成视频
- (void)setupAssetExportByComposition:(AVMutableComposition *)mutableComposition byVideoCom: (AVMutableVideoComposition *)videoCom byAudioMix:(AVMutableAudioMix *)audioMix {
    __weak typeof(self) weakSelf = self;
    [self showHubWithDescription:@"照片合成视频中..."];
    AVAssetExportSession *assetExport = [AVAssetExportSession exportSessionWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeMPEG4;
    assetExport.outputURL = [NSURL fileURLWithPath:self.videoPhotoPath];
    assetExport.shouldOptimizeForNetworkUse = NO;
    assetExport.videoComposition = videoCom;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHub];
            [self showHubWithDescription:@"视频添加音频中..."];
        });
        if (assetExport.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"合成完毕");
            // 音频路径
            NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"audio_group_style_1" ofType:@".aac"];
            [weakSelf insertAudioToVideoBgAudioPath:audioPath byVideoPath:weakSelf.videoPhotoPath byAudioVolume:3 byNeedVoice:NO];
        }
    }];
}

- (void)addLayerByComposition:(AVMutableVideoComposition *)composition byImagess:(NSMutableArray *)imgs {
    CGSize naturalSize = self.naturalSize;
    CALayer *bgLayer = [[CALayer alloc] init];
    bgLayer.frame = CGRectMake(0, 0, naturalSize.width, naturalSize.height);
    bgLayer.position = CGPointMake(naturalSize.width / 2, naturalSize.height / 2);
    bgLayer.backgroundColor = [UIColor redColor].CGColor;
    NSMutableArray *imageLayers = [[NSMutableArray alloc] init];
    for (UIImage *temp in imgs) {
        CALayer *imageL = [[CALayer alloc] init];
        imageL.contents = (__bridge id _Nullable)(temp.CGImage);
        imageL.bounds = CGRectMake(0, 0, naturalSize.width, naturalSize.height);
        imageL.contentsGravity = kCAGravityResizeAspect;
        imageL.backgroundColor = [UIColor blackColor].CGColor;
        imageL.anchorPoint = CGPointMake(0, 0);
        [bgLayer addSublayer:imageL];
        [imageLayers addObject:imageL];
    }
    [self positionAni:imageLayers];
    CALayer *parentLayer = [[CALayer alloc] init];
    CALayer *videoLayer = [[CALayer alloc] init];
    parentLayer.frame = CGRectMake(0, 0, naturalSize.width, naturalSize.height);
    videoLayer.frame = CGRectMake(0, 0, naturalSize.width, naturalSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:bgLayer];
    parentLayer.geometryFlipped = YES;
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

- (void)positionAni:(NSMutableArray *)layers {
    CGSize naturalSize = self.naturalSize;
    for (int index=0; index < layers.count; index++) {
        CALayer *layer = layers[index];
        CABasicAnimation *animation = [CABasicAnimation new];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.removedOnCompletion = NO;
        animation.beginTime = 0.1 + _picTime*index;
        NSLog(@"时间分段%f", animation.beginTime);
        if (index == 0) {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
        } else {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(naturalSize.width, 0)];
        }
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
        animation.duration = 0.35;
        animation.fillMode = kCAFillModeBoth;
        [layer addAnimation:animation forKey:@"position"];
    }
}

/**
 添加音频
 
 @param needVoice 是否需要视频的原来声音
 
 */
- (void)insertAudioToVideoBgAudioPath:(NSString *)audioPath byVideoPath:(NSString *)videoPath byAudioVolume:(CGFloat)audioVolume byNeedVoice:(BOOL)needVoice {
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    
    AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
    AVAsset *audioAsset = [AVAsset assetWithURL:audioURL];
    
    
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    
    CGFloat ff1 = [GroupPhotoViewController getMediaDurationWithMediaUrl:videoPath];
    NSRange videoRange = NSMakeRange(0.0, ff1);
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    if (needVoice) {
        //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
        AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
    }
    
    //声音长度截取范围==视频长度
    //    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 不循环的
    //    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    // 音频循环的
    int flagVideoDurtion = [GroupPhotoViewController getMediaDurationWithMediaUrl:videoPath];
    int flagAudioDurtion = [GroupPhotoViewController getMediaDurationWithMediaUrl:audioPath];
    
    int loopCount = flagVideoDurtion/flagAudioDurtion;
    CMTime duration = kCMTimeZero;
    for (int i = 0; i < loopCount; i++) {
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:duration error:nil];
        duration = CMTimeAdd(duration, audioAsset.duration);
    }
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    
    
    
    // 最终视频合成路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *outMoviePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"group_finish_video"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outMoviePath]) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:outMoviePath error:nil];
        } @catch(NSException *exception) {
            
        }
    } else {
        
    }
    //合成视频时间
    CMTime endTime = CMTimeMake(videoAsset.duration.timescale * (int)self.duration, videoAsset.duration.timescale);
    CMTimeRange timeR = CMTimeRangeMake(kCMTimeZero, endTime);
    assetExportSession.timeRange = timeR;
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = AVFileTypeMPEG4;
    assetExportSession.outputURL = [NSURL fileURLWithPath:outMoviePath];
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = NO;
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        if (assetExportSession.status == AVAssetExportSessionStatusCompleted) {
            self.videoFinishPath = outMoviePath;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHub];
            });
            [self saveVideoToSysytemAlbum];
            NSLog(@"最终视频导出完成");
        }
    }];
}

/**
 根据视频路径获取视频时长
 
 @param mediaUrlStr 本地路径
 @return 返回时长
 */
+ (CGFloat)getMediaDurationWithMediaUrl:(NSString *)mediaUrlStr {
    
    NSURL *mediaUrl = [NSURL fileURLWithPath:mediaUrlStr];
    AVURLAsset *mediaAsset = [[AVURLAsset alloc] initWithURL:mediaUrl options:nil];
    CMTime duration = mediaAsset.duration;
    
    return duration.value / duration.timescale;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    // 宽比高
    CGFloat scale = 1.0*image.size.width/image.size.height;
    
    if (newSize.width/scale > newSize.height) {
        // 宽度铺满 高度大于预定尺寸
        [image drawInRect:CGRectMake((newSize.width-newSize.height*scale)*0.5, 0, newSize.height*scale, newSize.height)];
    } else {
        [image drawInRect:CGRectMake(0, (newSize.height-newSize.width/scale)*0.5, newSize.width, newSize.width/scale)];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 保存视频到相册
- (void)saveVideoToSysytemAlbum {
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:self.videoFinishPath]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertMessage:@"保存视频成功"];
            });
        } else {
            
        }
    }];
}

#pragma mark - 两个视频合并
- (void)combVideos {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *firstVideo = [mainBundle pathForResource:@"1" ofType:@"mp4"];
    NSString *secondVideo = [mainBundle pathForResource:@"2" ofType:@"mp4"];
    
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVAsset *firstAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:firstVideo] options:optDict];
    AVAsset *secondAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideo] options:optDict];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    //为视频类型的的Track
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //由于没有计算当前CMTime的起始位置，现在插入0的位置,所以合并出来的视频是后添加在前面，可以计算一下时间，插入到指定位置
    //CMTimeRangeMake 指定起去始位置
    CMTimeRange firstTimeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    CMTimeRange secondTimeRange = CMTimeRangeMake(kCMTimeZero, secondAsset.duration);
    [compositionTrack insertTimeRange:secondTimeRange ofTrack:[secondAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
    [compositionTrack insertTimeRange:firstTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
    
    //只合并视频，导出后声音会消失，所以需要把声音插入到混淆器中
    //添加音频,添加本地其他音乐也可以,与视频一致
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:secondTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
    [audioTrack insertTimeRange:firstTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"comp.mp4"];
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporterSession.outputFileType = AVFileTypeMPEG4;
    exporterSession.outputURL = [NSURL fileURLWithPath:filePath]; //如果文件已存在，将造成导出失败
    exporterSession.shouldOptimizeForNetworkUse = NO; //用于互联网传输
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exporterSession.status) {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"exporter Failed");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporter Completed");
                break;
        }
    }];
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
