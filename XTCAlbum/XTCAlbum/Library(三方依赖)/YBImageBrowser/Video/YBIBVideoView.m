//
//  YBIBVideoView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "YBIBVideoView.h"
#import "YBIBVideoActionBar.h"
#import "YBIBVideoTopBar.h"
#import "YBIBUtilities.h"
#import "YBIBIconManager.h"

@interface YBIBVideoView () <YBIBVideoActionBarDelegate>
@property (nonatomic, strong) YBIBVideoTopBar *topBar;
@property (nonatomic, strong) YBIBVideoActionBar *actionBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, getter=isPlayFailed) BOOL playFailed;
@end

@implementation YBIBVideoView {
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    BOOL _active;
}

#pragma mark - life cycle

- (void)dealloc {
    [self removeObserverForSystem];
    [self reset];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
        self.backgroundColor = UIColor.clearColor;
        
        [self addSubview:self.thumbImageView];
        [self addSubview:self.topBar];
        [self addSubview:self.actionBar];
        [self addSubview:self.playButton];
        [self addSubview:self.inforTableView];
        [self addObserverForSystem];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapGesture:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)initValue {
    _playing = NO;
    _active = YES;
    _needAutoPlay = NO;
    _autoPlayCount = 0;
    _playFailed = NO;
}

#pragma mark - public

- (void)updateLayoutWithExpectOrientation:(UIDeviceOrientation)orientation containerSize:(CGSize)containerSize {
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    CGFloat width = containerSize.width - padding.left - padding.right, height = containerSize.height;
    self.topBar.frame = CGRectMake(padding.left, padding.top+kAppStatusBar, width, [YBIBVideoTopBar defaultHeight]);
    self.actionBar.frame = CGRectMake(padding.left, height - [YBIBVideoActionBar defaultHeight] - padding.bottom - 10, width, [YBIBVideoActionBar defaultHeight]);
    self.playButton.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
    _playerLayer.frame = (CGRect){CGPointZero, containerSize};
}

- (void)reset {
    [self removeObserverForPlayer];
    
    // If set '_playerLayer.player = nil' or '_player = nil', can not cancel observeing of 'addPeriodicTimeObserverForInterval'.
    [_player pause];
    _playerItem = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    
    [self finishPlay];
}

- (void)hideToolBar:(BOOL)hide {
    if (hide) {
        self.actionBar.hidden = YES;
        self.topBar.hidden = YES;
    } else if (self.isPlaying) {
        self.actionBar.hidden = NO;
        self.topBar.hidden = NO;
    }
}

- (void)hidePlayButton {
    self.playButton.hidden = YES;
}

#pragma mark - private

- (void)videoJumpWithScale:(float)scale {
    CMTime startTime = CMTimeMakeWithSeconds(scale, _player.currentTime.timescale);
    AVPlayer *tmpPlayer = _player;
    [_player seekToTime:startTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
        if (finished && tmpPlayer == self->_player) {
            [self startPlay];
        }
    }];
}

- (void)preparPlay {
    _playFailed = NO;
    self.playButton.hidden = YES;
    [self.videoDelegate yb_preparePlayForVideoView:self];
    
    if (!_playerLayer) {
        if (_data.videoPHAsset) {
            _playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        } else {
            _playerItem = [AVPlayerItem playerItemWithURL:_data.videoURL];
        }
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = (CGRect){CGPointZero, [self.videoDelegate yb_containerSizeForVideoView:self]};
        [self.layer insertSublayer:_playerLayer above:self.thumbImageView.layer];
        
        [self addObserverForPlayer];
    } else {
        [self videoJumpWithScale:0];
    }
}

- (void)startPlay {
    if (_player) {
        self.playing = YES;
        
        [_player play];
        [self.actionBar play];
        
        self.topBar.hidden = NO;
        self.actionBar.hidden = NO;
        
        [self.videoDelegate yb_startPlayForVideoView:self];
    }
}

- (void)finishPlay {
    self.playButton.hidden = NO;
    [self.actionBar setCurrentValue:0];
    self.actionBar.hidden = YES;
    self.topBar.hidden = YES;
    self.playing = NO;
    [self.videoDelegate yb_finishPlayForVideoView:self];
}

- (void)playerPause {
    if (_player) {
        [_player pause];
        [self.actionBar pause];
    }
}

- (BOOL)autoPlay {
    if (self.autoPlayCount == NSUIntegerMax) {
        [self preparPlay];
    } else if (self.autoPlayCount > 0) {
        --self.autoPlayCount;
        [self.videoDelegate yb_autoPlayCountChanged:self.autoPlayCount];
        [self preparPlay];
    } else {
        return NO;
    }
    return YES;
}

#pragma mark - <YBIBVideoActionBarDelegate>

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPlayButton:(UIButton *)playButton {
    [self startPlay];
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPauseButton:(UIButton *)pauseButton {
    [self playerPause];
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar changeValue:(float)value {
    [self videoJumpWithScale:value];
}

#pragma mark - observe

- (void)addObserverForPlayer {
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) wSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        float currentTime = time.value / time.timescale;
        [self.actionBar setCurrentValue:currentTime];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)removeObserverForPlayer {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![self.videoDelegate yb_isFreezingForVideoView:self]) {
        if (object == _playerItem) {
            if ([keyPath isEqualToString:@"status"]) {
                [self playerItemStatusChanged];
            }
        }
    }
}

- (void)didPlayToEndTime:(NSNotification *)noti {
    if (noti.object == _playerItem) {
        [self finishPlay];
        [self.videoDelegate yb_didPlayToEndTimeForVideoView:self];
    }
}

- (void)playerItemStatusChanged {
    if (!_active) return;
    
    switch (_playerItem.status) {
        case AVPlayerItemStatusReadyToPlay: {
            [self startPlay];
            
            double max = CMTimeGetSeconds(_playerItem.duration);
            [self.actionBar setMaxValue:isnan(max) || isinf(max) ? 0 : max];
        }
            break;
        case AVPlayerItemStatusUnknown: {
            _playFailed = YES;
            [self.videoDelegate yb_playFailedForVideoView:self];
            [self reset];
        }
            break;
        case AVPlayerItemStatusFailed: {
            _playFailed = YES;
            [self.videoDelegate yb_playFailedForVideoView:self];
            [self reset];
        }
            break;
    }
}

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    _active = NO;
    [self playerPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    _active = YES;
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > YBIBStatusbarHeight()) {
        [self playerPause];
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self playerPause];
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
    }
}

#pragma mark - event

- (void)respondsToTapGesture:(UITapGestureRecognizer *)tap {
    if (self.isPlaying) {
        self.actionBar.hidden = !self.actionBar.isHidden;
        self.topBar.hidden = !self.topBar.isHidden;
    } else {
        [self.videoDelegate yb_respondsToTapGestureForVideoView:self];
    }
}

- (void)clickCancelButton:(UIButton *)button {
    [self reset];
    [self finishPlay];
    [self.videoDelegate yb_cancelledForVideoView:self];
}

- (void)clickPlayButton:(UIButton *)button {
    [self preparPlay];
}

#pragma mark - getters & setters

- (void)setNeedAutoPlay:(BOOL)needAutoPlay {
    if (needAutoPlay && _asset && !self.isPlaying) {
        [self autoPlay];
    } else {
        _needAutoPlay = needAutoPlay;
    }
}

@synthesize asset = _asset;
- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    if (!asset) return;
    if (self.needAutoPlay) {
        if (![self autoPlay]) {
            self.playButton.hidden = NO;
        }
        self.needAutoPlay = NO;
    } else {
        self.playButton.hidden = NO;
    }
}
- (AVAsset *)asset {
    if ([_asset isKindOfClass:AVURLAsset.class]) {
        _asset = [AVURLAsset assetWithURL:((AVURLAsset *)_asset).URL];
    }
    return _asset;
}

- (YBIBVideoTopBar *)topBar {
    if (!_topBar) {
        _topBar = [YBIBVideoTopBar new];
        [_topBar.cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        _topBar.hidden = YES;
    }
    return _topBar;
}

- (YBIBVideoActionBar *)actionBar {
    if (!_actionBar) {
        _actionBar = [YBIBVideoActionBar new];
        _actionBar.delegate = self;
        _actionBar.hidden = YES;
    }
    return _actionBar;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.bounds = CGRectMake(0, 0, 100, 100);
        [_playButton setImage:YBIBIconManager.sharedManager.videoBigPlayImage() forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.hidden = NO;
//        _playButton.hidden = YES;
        _playButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _playButton.layer.shadowOffset = CGSizeMake(0, 1);
        _playButton.layer.shadowOpacity = 1;
        _playButton.layer.shadowRadius = 4;
    }
    return _playButton;
}

- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}

- (UITableView *)inforTableView {
    if (!_inforTableView) {
        _inforTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _inforTableView.delegate = self;
        _inforTableView.dataSource = self;
        _inforTableView.allowsSelection = NO;
        _inforTableView.maximumZoomScale = 1.0;
        _inforTableView.minimumZoomScale = 1.0;
        _inforTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _inforTableView.estimatedRowHeight = 50.0f;
        _inforTableView.scrollEnabled = NO;
        _inforTableView.hidden = YES;
        _inforTableView.backgroundColor = [UIColor blackColor];
        _inforTableView.rowHeight = UITableViewAutomaticDimension;
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        _inforTableView.tableHeaderView = statusView;
    }
    return _inforTableView;
}

- (MAMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] init];
        _mapView.mapType = MAMapTypeStandard;
        _mapView.delegate = self;
        _mapView.showsUserLocation = NO;
        _mapView.showsScale = NO;
        _mapView.showsCompass = NO;
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled = NO;
        _mapView.showsWorldMap = @1;
    }
    return _mapView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_photoVideoInforModel) {
        return 3;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 0;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellName = @"SourceInforTimeCellName";
            SourceInforTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.timeLabel.hidden = NO;
            cell.dateLabel.text = _photoVideoInforModel.timeHeaderStr;
            cell.timeLabel.text = _photoVideoInforModel.timeDetailStr;
            cell.backgroundColor = [UIColor clearColor];
            cell.headerImageView.hidden = NO;
            return cell;
        } else if (indexPath.row == 1) {
            static NSString *cellName = @"XTCCameraCommonCellName";
            XTCCameraCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCCameraCommonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            // 名字 像素 尺寸 大小
            cell.flagImageView.image = [UIImage imageNamed:@"media_info"];
            cell.headerLabel.text = _photoVideoInforModel.fileName;
            cell.detailFooterLabel.text = [NSString stringWithFormat:@"%@  %@", _photoVideoInforModel.fileSizeStr, _photoVideoInforModel.capacityStr];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else if (indexPath.row == 2) {
            static NSString *cellName = @"SourceInforTimeCellName";
            SourceInforTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.dateLabel.text = _photoVideoInforModel.deviceModel;
            cell.timeLabel.hidden = YES;
            cell.headerImageView.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            static NSString *cellName = @"SourceInforTimeCellName";
            SourceInforTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.dateLabel.text = _photoVideoInforModel.cameraInfoStr;
            cell.timeLabel.hidden = YES;
            cell.headerImageView.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            static NSString *cellName = @"SourceInforExposureCellName";
            SourceInforExposureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforExposureCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.headerLabel.text = _photoVideoInforModel.exposureBiasValue;
            cell.backLabel.text = [NSString stringWithFormat:@"Mode: %@", _photoVideoInforModel.exposureProgramDesc];
            cell.headerImageView.image = [UIImage imageNamed:@"exposure_bias"];
            return cell;
        } else {
            static NSString *cellName = @"XTCCameraInforCellName";
            XTCCameraInforCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCCameraInforCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            if (indexPath.row == 0) {
                cell.headerLabel.text = _photoVideoInforModel.f_number;
                cell.headerImageView.image = [UIImage imageNamed:@"media_f_number"];
                cell.backLabel.text = _photoVideoInforModel.focalLength;
                cell.backImageView.image = [UIImage imageNamed:@"media_focal_length"];
            } else {
                cell.headerLabel.text = _photoVideoInforModel.exposureTime;
                cell.headerImageView.image = [UIImage imageNamed:@"media_exposure_time"];
                cell.backLabel.text = _photoVideoInforModel.ISO;
                cell.backImageView.image = [UIImage imageNamed:@"media_iso"];
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    } else {
        static NSString *cellName = @"XTCCameraCommonCellName";
        XTCCameraCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[XTCCameraCommonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        cell.backgroundColor = [UIColor clearColor];
        // 经纬度 海拔信息
        cell.flagImageView.image = [UIImage imageNamed:@"media_location"];
        cell.headerLabel.text = @"地图坐标";
        NSString *gpsStr = [NSString stringWithFormat:@"%@  %@\nH %@", _photoVideoInforModel.lng, _photoVideoInforModel.lat, _photoVideoInforModel.altitude];
        
        NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:gpsStr];
        NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [titleParagraphStyle setLineSpacing:5];
        titleParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [titleAttributedString addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, titleAttributedString.string.length)];
        cell.detailFooterLabel.attributedText = titleAttributedString;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 44;
        }
        if (indexPath.row == 1) {
            return 54;
        }
        if (indexPath.row == 2) {
            return 30;
        }
        if (indexPath.row == 3) {
            return 30;
        }
    }
    if (indexPath.section == 1) {
        return 33;
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    if (_photoVideoInforModel.isHaveGps && section == 2) {
        if (_photoVideoInforModel.isHaveGps) {
            return  (kScreenWidth-30)*0.5+30;
        } else {
            return 0.01f;
        }
        
    }
    return 0.01f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weakSelf = self;
    if (_photoVideoInforModel.isHaveGps && section== 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [footerView addSubview:weakSelf.mapView];
            weakSelf.mapView.frame = CGRectMake(15, 15, kScreenWidth-30, (kScreenWidth-30)*0.5);
            
            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
            
            weakSelf.mapView.layer.cornerRadius = 10;
            weakSelf.mapView.layer.masksToBounds = YES;
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([weakSelf.photoVideoInforModel.mapLat doubleValue], [weakSelf.photoVideoInforModel.mapLng doubleValue]);
            XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
            
            if (![TQLocationConverter isLocationOutOfChina:coor]) {
                coor = [TQLocationConverter transformFromWGSToGCJ:coor];
            }
            
            pointAnnotation.coordinate = coor;
            pointAnnotation.title = @"";
            pointAnnotation.subtitle = @"";
            pointAnnotation.showIndex = 1;
            [weakSelf.mapView addAnnotation:pointAnnotation];
            
            
            // 两边各加一个点
            CLLocationCoordinate2D leftCoordinate = CLLocationCoordinate2DMake(coor.latitude+0.025, coor.longitude+0.025);
            XTCPointAnnotation *leftPointAnnotation = [[XTCPointAnnotation alloc] init];
            leftPointAnnotation.coordinate = leftCoordinate;
            leftPointAnnotation.title = @"";
            leftPointAnnotation.subtitle = @"";
            leftPointAnnotation.showIndex = 0;
            [weakSelf.mapView addAnnotation:leftPointAnnotation];
            
            CLLocationCoordinate2D rightCoordinate = CLLocationCoordinate2DMake(coor.latitude-0.025, coor.longitude-0.025);
            XTCPointAnnotation *rightPointAnnotation = [[XTCPointAnnotation alloc] init];
            rightPointAnnotation.coordinate = rightCoordinate;
            rightPointAnnotation.title = @"";
            rightPointAnnotation.subtitle = @"";
            rightPointAnnotation.showIndex = 0;
            [weakSelf.mapView addAnnotation:rightPointAnnotation];
            [weakSelf.mapView showAnnotations:weakSelf.mapView.annotations animated:YES];
            
            dispatch_after(0.5, dispatch_get_main_queue(), ^{
                [weakSelf.mapView setCenterCoordinate:coor zoomLevel:12 animated:NO];
            });
            
            
        });
        
    } else {
        
    }
    return footerView;
}



- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[XTCPointAnnotation class]])
    {
        XTCPointAnnotation *pointAnnotation = annotation;
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        XTCCommonAnnotationView *annotationView = (XTCCommonAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[XTCCommonAnnotationView alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:AnnotatioViewReuseID];
        }
        annotationView.tintColor = [UIColor clearColor];
        annotationView.annotation = annotation;
        if (pointAnnotation.showIndex == 1) {
            if (self.data.videoPHAsset) {
                annotationView.asset = self.data.videoPHAsset;
            } else {
                annotationView.countImageView.image = self.data.thumbImage;
            }
            
            annotationView.image = [[UIImage imageNamed:@"pick_map_marker"] resizedImageToSize:CGSizeMake(65, 65)];
        } else {
            annotationView.countImageView.image = nil;
            annotationView.image = nil;
        }
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    NSLog(@"大头针点击啦");
    [self showGpsMap];
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self showGpsMap];
}

- (void)showGpsMap {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowSingleMap" bundle:nil];
    XTCShowSingleMapViewController *showSingleMapVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowSingleMapViewController"];
    if (self.data.videoPHAsset) {
        showSingleMapVC.sourceAsset = self.data.videoPHAsset;
    } else {
        showSingleMapVC.privateImage = self.data.thumbImage;
    }
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_photoVideoInforModel.mapLat doubleValue], [_photoVideoInforModel.mapLng doubleValue]);
    showSingleMapVC.mapCoor = coor;
    XTCBaseNavigationController *baseNavi = [[XTCBaseNavigationController alloc] initWithRootViewController:showSingleMapVC];
    [[StaticCommonUtil app].topViewController presentViewController:baseNavi animated:YES completion:^{
        
    }];
}

- (void)loadSourceInforByVideoData:(YBIBVideoData *)flagSourcedata {
    _photoVideoInforModel = [[XTCPhotoVideoInforModel alloc] init];
    _photoVideoInforModel = [[XTCPhotoVideoInforModel alloc] init];
    _photoVideoInforModel.exposureProgramDesc = @"未知";
    _photoVideoInforModel.exposureBiasValue = @"未知";
    _photoVideoInforModel.ISO = @"未知";
    _photoVideoInforModel.exposureTime = @"未知";
    _photoVideoInforModel.focalLength = @"未知";
    _photoVideoInforModel.f_number = @"未知";
    _photoVideoInforModel.deviceName = @"未知品牌型号";
    _photoVideoInforModel.deviceModel = @"未知型号";
    _photoVideoInforModel.capacityStr = @"未知大小";
    _photoVideoInforModel.fileSizeStr = @"未知尺寸";
    _photoVideoInforModel.fileName = @"未知";
    _photoVideoInforModel.cameraInfoStr = @"未知镜头信息";
    
    
    NSMutableDictionary *weekDict = [[NSMutableDictionary alloc] init];
    [weekDict setObject:@"星期日" forKey:@"SUN"];
    [weekDict setObject:@"星期一" forKey:@"MON"];
    [weekDict setObject:@"星期二" forKey:@"TUE"];
    [weekDict setObject:@"星期三" forKey:@"WED"];
    [weekDict setObject:@"星期四" forKey:@"THU"];
    [weekDict setObject:@"星期五" forKey:@"FRI"];
    [weekDict setObject:@"星期六" forKey:@"SAT"];
    
    
    XTCDateFormatter *dateFomatter = [XTCDateFormatter shareDateFormatter];
    [dateFomatter setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
    
    __weak typeof(self) weakself = self;
    
    if (flagSourcedata.videoPHAsset) {
        
        NSString *dateString = [dateFomatter stringFromDate:flagSourcedata.videoPHAsset.creationDate];
        
        // 日期转换
        NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
        if (dateArray.count == 3) {
            _photoVideoInforModel.timeHeaderStr = dateArray.firstObject;
            NSString *weekStr = dateArray[1];
            NSString *timeStr = dateArray[2];
            NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
            NSString *hourStr = timeArray[0];
            if ([hourStr intValue] > 12) {
                _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@下午%d:%@", weekStr, [hourStr intValue]-12, timeArray[1]];
            } else {
                _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@上午%d:%@", weekStr, [hourStr intValue], timeArray[1]];
            }
            
            
        } else {
            _photoVideoInforModel.timeHeaderStr = @"未知";
            _photoVideoInforModel.timeDetailStr = @"";
        }
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:flagSourcedata.videoPHAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSLog(@"%@", info);
            NSString *inforStr = [info[@"PHImageFileSandboxExtensionTokenKey"] description];
            NSArray *inforArray = [inforStr componentsSeparatedByString:@"/"];
            // 名字
            if (inforArray && inforArray.count) {
                weakself.photoVideoInforModel.fileName = inforArray.lastObject;
            } else {
                weakself.photoVideoInforModel.fileName = @"未知";
            }
            // 像素 尺寸 大小
            NSInteger width = flagSourcedata.videoPHAsset.pixelWidth;
            NSInteger height = flagSourcedata.videoPHAsset.pixelHeight;
            // 尺寸
            NSString *sizeStr = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
            weakself.photoVideoInforModel.fileSizeStr = sizeStr;
            NSLog(@"%@", flagAsset.commonMetadata);
            
            // 大小
            if ([flagAsset isKindOfClass:[AVComposition class]]) {
                weakself.photoVideoInforModel.capacityStr = @"未知大小";
            } else {
                NSURL *URL = [(AVURLAsset *)flagAsset URL];
                NSNumber *fileSizeValue = nil;
                [URL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:nil];
                NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", [fileSizeValue longLongValue]/1024.0/1024.0];
                weakself.photoVideoInforModel.capacityStr = capacityStr;
            }
            
            
            // 经纬度 海拔
            weakself.photoVideoInforModel.isHaveGps = YES;
            NSString *lat = [NSString stringWithFormat:@"%f", flagSourcedata.videoPHAsset.location.coordinate.latitude];
            NSString *lng = [NSString stringWithFormat:@"%f", flagSourcedata.videoPHAsset.location.coordinate.longitude];
            if (lat && lat.length && flagSourcedata.videoPHAsset.location) {
                weakself.photoVideoInforModel.mapLat = lat;
                if (lat >= 0) {
                    weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:lat byLng:@"N"];
                } else {
                    weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:[lat
                                                                                          stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"S"];
                }
            } else {
                weakself.photoVideoInforModel.lat = @"纬度未知";
                weakself.photoVideoInforModel.isHaveGps = NO;
            }
            
            if (lng && lng.length && flagSourcedata.videoPHAsset.location) {
                weakself.photoVideoInforModel.mapLng = lng;
                if ([lng floatValue] > 0) {
                    weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:lng byLng:@"E"];
                } else {
                    weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:[lat
                                                                                          stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"W"];
                }
            } else {
                weakself.photoVideoInforModel.lng = @"经度未知";
                weakself.photoVideoInforModel.isHaveGps = NO;
            }
            weakself.photoVideoInforModel.altitude = @"海拔未知";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.inforTableView reloadData];
            });
            
        }];
        
        
        
        
        
        
    } else {
        NSData *videoData = [NSData dataWithContentsOfURL:flagSourcedata.videoURL];
        AVAsset *asset = [AVAsset assetWithURL:flagSourcedata.videoURL];
        NSArray *timeArray = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                            withKey:AVMetadataCommonKeyCreationDate
                                                           keySpace:AVMetadataKeySpaceCommon];
        NSString *flagDateStr;
        for (AVMetadataItem *item in timeArray) {
            if (item.value) {
                flagDateStr = (NSString *)item.value;
            } else {
                
            }
        }
        
        if (flagDateStr && flagDateStr.length) {
            NSString *dateTStr = [flagDateStr
                                  stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            NSArray *flagDateArray = [dateTStr componentsSeparatedByString:@"+"];
            if (flagDateArray.count) {
                [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *gainDate = [[XTCDateFormatter shareDateFormatter] dateFromString:flagDateArray[0]];
                [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
                NSString *dateString = [[XTCDateFormatter shareDateFormatter] stringFromDate:gainDate];
                
                // 日期转换
                NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
                if (dateArray.count == 3) {
                    _photoVideoInforModel.timeHeaderStr = dateArray.firstObject;
                    NSString *weekStr = dateArray[1];
                    NSString *timeStr = dateArray[2];
                    NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
                    NSString *hourStr = timeArray[0];
                    if ([hourStr intValue] > 12) {
                        _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@下午%d:%@", weekStr, [hourStr intValue]-12, timeArray[1]];
                    } else {
                        _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@上午%d:%@", weekStr, [hourStr intValue], timeArray[1]];
                    }
                    
                    
                } else {
                    _photoVideoInforModel.timeHeaderStr = @"未知";
                    _photoVideoInforModel.timeDetailStr = @"未知";
                }
            } else {
                _photoVideoInforModel.timeHeaderStr = @"未知";
                _photoVideoInforModel.timeDetailStr = @"";
            }
        } else {
            _photoVideoInforModel.timeHeaderStr = @"未知";
            _photoVideoInforModel.timeDetailStr = @"";
        }
        
        // 分辨率
        UIImage *image = [self thumbnailImageFromURL:flagSourcedata.videoURL];
        NSString *sizeStr = [NSString stringWithFormat:@"%.0fx%.0f", image.size.width, image.size.height];
        weakself.photoVideoInforModel.fileSizeStr = sizeStr;
        
        // 定位
        NSArray *gpsArray = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                           withKey:AVMetadataCommonKeyLocation
                                                          keySpace:AVMetadataKeySpaceCommon];
        NSString *gpsStr = @"";
        for (AVMetadataItem *item in gpsArray) {
            if (item.value) {
                gpsStr = (NSString *)item.value;
            } else {
                
            }
        }
        if (gpsStr && gpsStr.length) {
            NSString *gpsFlagStr = [gpsStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
            NSMutableArray *gpsMutableArray = [[NSMutableArray alloc] init];
            NSMutableString *normalstr;
            for(int i =0; i < [gpsFlagStr length]; i++)
            {
                NSString *flagStr = [NSString stringWithFormat:@"%c", [gpsFlagStr characterAtIndex:i]];
                if ([flagStr isEqualToString:@"+"] || [flagStr isEqualToString:@"-"] || (i == [gpsFlagStr length]-1)) {
                    if (normalstr && normalstr.length) {
                        [gpsMutableArray addObject:normalstr];
                    }
                    normalstr = [[NSMutableString alloc] initWithFormat:@""];
                } else {
                    
                }
                normalstr = [[normalstr stringByAppendingString:flagStr] copy];
            }
            if (gpsMutableArray.count >= 3) {
                weakself.photoVideoInforModel.mapLat = gpsMutableArray[0];
                if (weakself.photoVideoInforModel.mapLat >= 0) {
                    weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLat
                                                                                          stringByReplacingOccurrencesOfString:@"+" withString:@""] byLng:@"N"];
                } else {
                    weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLat
                                                                                          stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"S"];
                }
                
                weakself.photoVideoInforModel.mapLng = gpsMutableArray[1];
                if (weakself.photoVideoInforModel.mapLng >= 0) {
                    weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLng
                                                                                          stringByReplacingOccurrencesOfString:@"+" withString:@""] byLng:@"E"];
                } else {
                    weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLng
                                                                                          stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"W"];
                }
                weakself.photoVideoInforModel.altitude = @"海拔未知";
                weakself.photoVideoInforModel.isHaveGps = YES;
                
            } else {
                weakself.photoVideoInforModel.lng = @"经度未知";
                weakself.photoVideoInforModel.lat = @"纬度未知";
                weakself.photoVideoInforModel.isHaveGps = NO;
                weakself.photoVideoInforModel.altitude = @"海拔未知";
            }
        } else {
            weakself.photoVideoInforModel.lng = @"经度未知";
            weakself.photoVideoInforModel.lat = @"纬度未知";
            weakself.photoVideoInforModel.isHaveGps = NO;
            weakself.photoVideoInforModel.altitude = @"未知";
        }
        
        NSArray *inforArray = [[flagSourcedata.videoURL absoluteString] componentsSeparatedByString:@"/"];
        // 名字
        if (inforArray && inforArray.count) {
            weakself.photoVideoInforModel.fileName = inforArray.lastObject;
        } else {
            weakself.photoVideoInforModel.fileName = @"";
        }
        
        NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", videoData.length/1024.0/1024.0];
        weakself.photoVideoInforModel.capacityStr = capacityStr;
        [_inforTableView reloadData];
    }
}

- (NSString *)stringWithCoordinateString:(NSString *)coordinateString byLng:(NSString *)mapFlag {
    /** 将经度或纬度整数部分提取出来 */
    int latNumber = [coordinateString intValue];
    
    /** 取出小数点后面两位(为转化成'分'做准备) */
    NSArray *array = [coordinateString componentsSeparatedByString:@"."];
    /** 小数点后面部分 */
    NSString *lastCompnetString = [array lastObject];
    
    /** 拼接字字符串(将字符串转化为0.xxxx形式) */
    NSString *str1 = [NSString stringWithFormat:@"0.%@", lastCompnetString];
    
    /** 将字符串转换成float类型以便计算 */
    float minuteNum = [str1 floatValue];
    
    /** 将小数点后数字转化为'分'(minuteNum * 60) */
    float minuteNum1 = minuteNum * 60;
    
    /** 将转化后的float类型转化为字符串类型 */
    NSString *latStr = [NSString stringWithFormat:@"%f", minuteNum1];
    
    /** 取整数部分即为纬度或经度'分' */
    int latMinute = [latStr intValue];
    
    NSArray *array1 = [latStr componentsSeparatedByString:@"."];
    NSString *lastCompnetString1 = [array1 lastObject];
    NSString *str2 = [NSString stringWithFormat:@"0.%@", lastCompnetString1];
    float secNum = [str2 floatValue];
    float secNum1 = secNum * 60;
    NSString *secStr = [NSString stringWithFormat:@"%f", secNum1];
    
    
    /** 将经度或纬度字符串合并为(xx°xx')形式 */
    NSString *string = [NSString stringWithFormat:@"%@ %d°%d'%d\"", mapFlag, latNumber, latMinute, [secStr intValue]];
    
    return string;
}

- (NSDictionary*)metadataFromImageData:(NSData*)imageData {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    NSLog(@"Can't read metadata");
    return nil;
}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime requestedTime = CMTimeMake(1, 60);
    CGImageRef imgRef = nil;
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    if (imgRef != nil) {
        return [UIImage imageWithCGImage:imgRef];
    }else {
        return nil;
    }
}

@end
