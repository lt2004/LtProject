//
//  NewPublishRecordAudioViewController.h
//  vs
//
//  Created by Mac on 2018/11/28.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZMp3RecordingClient.h"
#import "PCSEQVisualizer.h"
#import "PlayerManager.h"
#import "XTCPermissionManager.h"

typedef void (^AudioTimeCallabck)(int audioTime);

NS_ASSUME_NONNULL_BEGIN

@interface NewPublishRecordAudioViewController : UIViewController <PlayerManagerStopDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *playStopButton;
@property (weak, nonatomic) IBOutlet UIView *startProcessView;
@property (weak, nonatomic) IBOutlet UIView *processBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recoderWidthLayoutConstraint;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int recoderTime;
@property (nonatomic, assign) int totalTime;

@property (weak, nonatomic) IBOutlet UIButton *recoderButton;
@property (weak, nonatomic) IBOutlet UILabel *recoderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, strong) NSString *audioDatePathStr; // 录音路径
@property (nonatomic, strong) JZMp3RecordingClient *recordClient;
@property (nonatomic, strong) PCSEQVisualizer *visualizerView;
@property (weak, nonatomic) IBOutlet UIView *recoderBgView;
@property (nonatomic, strong) AudioTimeCallabck audioTimeCallabck;

- (NSString *)gainShowTime:(int)time;

@end

NS_ASSUME_NONNULL_END
