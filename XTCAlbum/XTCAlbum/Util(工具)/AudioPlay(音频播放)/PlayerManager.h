//
//  PlayerManager.h
//  Podbean
//
//  Created by Jacky on 12/5/14.
//  Copyright (c) 2014 Podbean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HysteriaPlayer/HysteriaPlayer.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol PlayerManagerStopDelegate <NSObject>
@required
- (void)playerManagerVideoFinish;

@end

@interface PlayerManager : NSObject<HysteriaPlayerDelegate, HysteriaPlayerDataSource>

@property (nonatomic, strong) HysteriaPlayer * player;
@property (nonatomic, strong) NSArray * playingList;
@property (nonatomic, weak) id<PlayerManagerStopDelegate> finishDelegate;

//播放列表
- (void)setPlayingList:(NSArray *)list;
+ (PlayerManager *)sharedInstance;
- (void)play:(NSArray *)playinglist;

@end
