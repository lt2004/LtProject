//
//  NewPublishRecordAudioViewController.m
//  vs
//
//  Created by Mac on 2018/11/28.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "NewPublishRecordAudioViewController.h"

@interface NewPublishRecordAudioViewController ()

@end

@implementation NewPublishRecordAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _deleteButton.layer.cornerRadius = 25;
    _deleteButton.layer.masksToBounds = YES;
    _deleteButton.layer.borderColor = RGBCOLOR(31, 31, 31).CGColor;
    _deleteButton.layer.borderWidth = 1;
    
    _recoderWidthLayoutConstraint.constant = 0;
    
    _totalTime = 600;
    _recoderTime = 0;
    
    _recoderTimeLabel.text = [self gainShowTime:_recoderTime];
    _totalTimeLabel.text = [self gainShowTime:_totalTime];
    
    _recoderButton.selected = NO;
    [_recoderButton addTarget:self action:@selector(_recoderButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _recordClient = [JZMp3RecordingClient sharedClient];
    
    [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_playStopButton addTarget:self action:@selector(playStopButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [PlayerManager sharedInstance].finishDelegate = self;
}


- (void)playStopButtonClick {
    if (_playStopButton.selected) {
        [[PlayerManager sharedInstance].player pause];
    } else {
        [[PlayerManager sharedInstance] play:@[[self recordingMp3FilePath]]];
    }
    _playStopButton.selected = !_playStopButton.selected;
}

#pragma mark - 播放完成
- (void)playerManagerVideoFinish {
    _playStopButton.selected = NO;
}


#pragma mark - 录制音频按钮点击
- (void)_recoderButtonClick {
    if (self.recoderButton.selected) {
        [self alertMessage:@"保存中..."];
    } else {
        
    }
    [XTCPermissionManager checkAudioPermissioncallBack:^(BOOL isPermission) {
        if (isPermission) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.recoderButton.selected) {
                    [self stopRecoder];
                    [self.recordClient stop];
                    self.deleteButton.hidden = NO;
                    self.playStopButton.hidden = NO;
                } else {
                    // 开始录音
                    [self deleteButtonClick];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recoderTimerProgress) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
                    NSString *target = [self recordingMp3FilePath];
                    self.recordClient.currentMp3File = target;
                    [self.recordClient start:target];
                    [self startHud];
                }
                self.recoderButton.selected = !self.recoderButton.selected;
            });
        } else {
            
        }
    }];
}

- (void)deleteButtonClick {
    NSString *target = [self recordingMp3FilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:target]) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:target error:nil];
        } @catch(NSException *exception) {
            
        }
    } else {
        
    }
    self.recoderTime = 0;
    self.recoderButton.selected = NO;
    self.deleteButton.hidden = YES;
    self.playStopButton.hidden = YES;
    _recoderTimeLabel.text = [self gainShowTime:_recoderTime];
    _recoderWidthLayoutConstraint.constant = 1.0*kScreenWidth*_recoderTime/_totalTime;
    _playStopButton.selected = NO;
}


- (IBAction)topDismisButtonClick:(id)sender {
    if (_recoderButton.isSelected) {
        [self alertMessage:@"音频录制中"];
    } else {
        if (self.audioTimeCallabck) {
            self.audioTimeCallabck(self.recoderTime);
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
}
- (IBAction)bottomDismisButtonClick:(id)sender {
    if (_recoderButton.isSelected) {
        [self alertMessage:@"音频录制中"];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.audioTimeCallabck) {
                self.audioTimeCallabck(self.recoderTime);
            }
        }];
    }
    
}

- (void)recoderTimerProgress {
    _recoderTime++;
    _recoderWidthLayoutConstraint.constant = 1.0*kScreenWidth*_recoderTime/_totalTime;
    if (_recoderTime == _totalTime) {
        [self stopRecoder];
        _recoderButton.selected = NO;
        _recoderWidthLayoutConstraint.constant = kScreenWidth;
    } else {
        
    }
    _recoderTimeLabel.text = [self gainShowTime:_recoderTime];
}

- (NSString *)gainShowTime:(int)time {
    int min = time/60;
    int second = time%60;
    NSString *minStr = @"";
    NSString *secondStr = @"";
    
    if (min > 9) {
        minStr = [NSString stringWithFormat:@"%d", min];
    } else {
        minStr = [NSString stringWithFormat:@"0%d", min];
    }
    
    if (second > 9) {
        secondStr = [NSString stringWithFormat:@"%d", second];
    } else {
        secondStr = [NSString stringWithFormat:@"0%d", second];
    }
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@", minStr, secondStr];
    return timeStr;
}

- (void)stopRecoder {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    } else {
        
    }
    [self stopHud];
}

- (NSString *)recordingMp3FilePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [NSString stringWithFormat:@"%@/recoder_%@.mp3", path, _audioDatePathStr];
}

- (void)startHud {
    _visualizerView = [[PCSEQVisualizer alloc] initVisualizerByTypeL:VisualizerRecoderType];
    _visualizerView.layer.cornerRadius = 6;
    _visualizerView.layer.masksToBounds = YES;
    [_recoderBgView addSubview:_visualizerView];
    
    [_visualizerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.recoderBgView);
        make.size.mas_equalTo(CGSizeMake(122, 120));
    }];
    
    [_visualizerView start];
    [_recoderBgView sendSubviewToBack:_visualizerView];
}

- (void)stopHud {
    [_visualizerView stop];
    [_visualizerView removeFromSuperview];
}

- (void)alertMessage:(NSString *)msg {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:1.2];
}


- (void)dealloc {
    DDLogInfo(@"新发布录音内存释放");
    [self stopRecoder];
    [[PlayerManager sharedInstance].player pause];
    [PlayerManager sharedInstance].finishDelegate = nil;
    [[JZMp3RecordingClient sharedClient] stop];
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
