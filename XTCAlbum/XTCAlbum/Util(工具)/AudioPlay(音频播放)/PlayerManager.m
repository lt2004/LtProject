//
//  PlayerManager.m
//  Podbean
//
//  Created by Jacky on 12/5/14.
//  Copyright (c) 2014 Podbean. All rights reserved.
// modify by 漫漫

#import "PlayerManager.h"

@implementation PlayerManager

+ (PlayerManager *)sharedInstance {
    static PlayerManager *_sharedInstance = nil;
    static dispatch_once_t onceTokenPlayer;
    dispatch_once(&onceTokenPlayer, ^{
        _sharedInstance = [[PlayerManager alloc] init];
        [_sharedInstance setupAudioPlayer];
    });
    
    return _sharedInstance;
}


- (void)setupAudioPlayer {
    self.player = [HysteriaPlayer sharedInstance];
    self.player.delegate = self;
    self.player.datasource = self;
}

- (void)hysteriaPlayerReadyToPlay:(HysteriaPlayerReadyToPlay)identifier {
    switch (identifier) {
            case HysteriaPlayerReadyToPlayPlayer:
            break;
            case HysteriaPlayerReadyToPlayCurrentItem:
            break;
        default:
            break;
    }
}

- (void)hysteriaPlayerDidFailed:(HysteriaPlayerFailed)identifier error:(NSError *)error {
    DDLogInfo(@"播放失败");
    [_finishDelegate playerManagerVideoFinish];
}

- (NSInteger)hysteriaPlayerNumberOfItems {
    return self.playingList.count;
}

- (NSURL *)hysteriaPlayerURLForItemAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer {
    NSURL *mediaUrl = nil;
    NSString *urlStr = self.playingList[index];
    if ([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"]) {
        mediaUrl = [NSURL URLWithString:urlStr];
    }else {
        mediaUrl = [NSURL fileURLWithPath:urlStr];
    }
    return mediaUrl;
}


- (void)play:(NSArray *)playinglist {
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    if (playinglist.count <= 0 || ![playinglist isKindOfClass:[NSArray class]]) {
        return;
    }
    self.playingList = playinglist;
    [self.player pause];
    if (self.player.playerItems.count) {
        [self.player removeAllItems];
    }
    [self.player fetchAndPlayPlayerItem:0];
    [self.player setPlayerRepeatMode:HysteriaPlayerRepeatModeOff];
    [self.player play];
}

#pragma mark - Streaming delegate
- (void)hysteriaPlayerCurrentItemChanged:(AVPlayerItem *)item {
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in item.asset.tracks) {
        AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:1.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    [item setAudioMix:audioZeroMix];
    DDLogInfo(@"current item changed.");
    
}

- (void)hysteriaPlayerCurrentItemPreloaded:(CMTime)time
{
    DDLogInfo(@"current item pre-loaded time: %f", CMTimeGetSeconds(time));
}

- (void)hysteriaPlayerDidReachEnd {
    DDLogInfo(@"播放完成");
     [_finishDelegate playerManagerVideoFinish];
}

- (void)hysteriaPlayerRateChanged:(BOOL)isPlaying
{
    DDLogInfo(@"player rate changed");
}

#pragma mark - Playing control
- (void)setPlayingList:(NSArray *)list {
    _playingList = list;
}


@end
