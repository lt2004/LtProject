//
//  PostDetailPhotoViewController.m
//  vs
//
//  Created by Xie Shu on 2017/8/4.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PostDetailPhotoViewController.h"
#import "MAMapView+ZoomLevel.h"
#import "PostDetailLoadingView.h"
#import "UITableView+WebVideoCache.h"
#import "UIView+WebVideoCache.h"

#define TagFlagWidth 83

@interface PostDetailPhotoViewController () {
    float contentOffsetY;
    float oldContentOffsetY;
    UIImage *_shareImage;
    BOOL _isPlayAudioStatus;
    UIImageView *_crabTapImageView;
    BOOL _isShowDetailPostDesc;
    NSIndexPath *_videoIndexPath;
    BOOL _changeTileTypeFlag;
    UIView *_mapView;
    BOOL _isPullPresent;
    BOOL _isHideStatusBar; // 是否隐藏状态栏
    DeviceOrientation *_deviceOrientation;
}

@property (nonatomic, strong) PostDetailLoadingView *postDetailLoadingView;
@property (nonatomic, strong) XTCMapView *postDetailMapView;
@property (nonatomic, strong) XTCNoNetWorkingShowView *noNetWorkingShowView;
@property (nonatomic, assign) BOOL isVerticalPlay;// 视频播放横屏标示
@property (nonatomic, strong) UIImageView *businessBgImageView; // 用户背景图
@property (nonatomic, strong) PostDetailBottomTabView *postDetailBottomTabView;
@property (nonatomic, strong) UIView *footerView; // 底部到底容器view

@end

@implementation PostDetailPhotoViewController
@synthesize detailTableView = _detailTableView;
@synthesize postDetailId = _postDetailId;
@synthesize popHiddenNavFlag = _popHiddenNavFlag;
@synthesize postDetailModel = _postDetailModel;
@synthesize mediaPath = _mediaPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    _isPlayVideo = NO;
    _isHideStatusBar = NO;
    // 开启屏幕监听
    _deviceOrientation = [DeviceOrientation sharedDeviceOrientation];
    
    
    _isPlayAudioStatus = NO;
    _changeTileTypeFlag = NO;
    _isVerticalPlay = NO;
    _isShowCircle = NO;
    _arrDidLoadArray = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        _detailTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    _detailTableView.backgroundColor = [UIColor clearColor];
    _detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _detailTableView.rowHeight = UITableViewAutomaticDimension;
    _detailTableView.estimatedRowHeight = 50.0f;
    _detailTableView.showsVerticalScrollIndicator = NO;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostDetailBottomTabView" owner:self options:nil];
    _postDetailBottomTabView = [nib objectAtIndex:0];
    _postDetailBottomTabView.alpha = 0.9;
    [self.view addSubview:_postDetailBottomTabView];
    _postDetailBottomTabView.layer.cornerRadius = 25;
    _postDetailBottomTabView.layer.masksToBounds = YES;
    
    
    _businessBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _detailTableView.backgroundView = _businessBgImageView;
    
    [_postDetailBottomTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        if (kDevice_Is_iPhoneX) {
            make.bottom.equalTo(self.view).with.offset(-kBottom_iPhoneX-10);
        } else {
            make.bottom.equalTo(self.view).with.offset(-10);
        }
        
        make.height.mas_equalTo(50);
    }];
    [_postDetailBottomTabView.shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_postDetailBottomTabView.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [_postDetailBottomTabView.reportButton addTarget:self action:@selector(reportButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _detailTableView.hidden = YES;
    _noNetWorkingShowView = [[XTCNoNetWorkingShowView alloc] init];
    [self.view addSubview:_noNetWorkingShowView];
    _noNetWorkingShowView.backgroundColor = [UIColor clearColor];
    [_noNetWorkingShowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    [_noNetWorkingShowView.retryButton addTarget:self action:@selector(retryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _noNetWorkingShowView.hidden = YES;
    [self loadPostDetailData];
    
}

- (void)loadPostDetailData {
    // 加载详情页
    _postDetailLoadingView = [[PostDetailLoadingView alloc] init];
    [self.view addSubview:_postDetailLoadingView];
    [_postDetailLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.view bringSubviewToFront:_postDetailBottomTabView];
    __weak typeof(self) weakSelf = self;
    RequestGetdetailModel *getdetailModelRequest = [[RequestGetdetailModel alloc] init];
    getdetailModelRequest.user_id = [GlobalData sharedInstance].userModel.user_id;
    getdetailModelRequest.token = [GlobalData sharedInstance].userModel.token;
    getdetailModelRequest.post_id = _postDetailId;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestGetdetailv2Enum byRequestDict:getdetailModelRequest callBack:^(id object, RSResponseErrorModel *errorModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.postDetailLoadingView removeFromSuperview];
        });
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            weakSelf.noNetWorkingShowView.hidden = YES;
            weakSelf.detailTableView.hidden = NO;
            weakSelf.postDetailModel = object;
            if ([weakSelf.postDetailModel.level intValue] > 1) {
                if ([weakSelf.postDetailModel.level intValue] < 4) {
                    // 服务号用户
                    weakSelf.businessBgImageView.image = [UIImage imageNamed:@"home_page_company_bg"];
                } else {
                    // 商业用户
                    weakSelf.businessBgImageView.image = [UIImage imageNamed:@"home_page_business_bg"];
                }
            } else {
                
            }
            if ([weakSelf.postDetailModel.is_collect isEqualToString:@"Y"]) {
                [weakSelf.postDetailBottomTabView.collectButton setImage:[UIImage imageNamed:@"tool_tab_have_collection"] forState:UIControlStateNormal];
            } else {
                [weakSelf.postDetailBottomTabView.collectButton setImage:[UIImage imageNamed:@"tool_tab_collection"] forState:UIControlStateNormal];
            }
            if ([weakSelf.postDetailModel.is_good integerValue] == 1) {
                weakSelf.postDetailBottomTabView.upButton.selected = YES;
            } else {
                weakSelf.postDetailBottomTabView.upButton.selected = NO;
            }
            weakSelf.postDetailBottomTabView.goodCountLabel.text = weakSelf.postDetailModel.count_good;
            if ([weakSelf.postDetailModel.count_comments isEqualToString:@""] || [weakSelf.postDetailModel.count_comments isEqualToString:@"0"]) {
                weakSelf.postDetailBottomTabView.commentCountLabel.hidden = YES;
            } else {
                weakSelf.postDetailBottomTabView.commentCountLabel.text = weakSelf.postDetailModel.count_comments;
                weakSelf.postDetailBottomTabView.commentCountLabel.hidden = NO;
            }
            [weakSelf buildShareImage];
            if ([weakSelf.postDetailModel.lat isEqualToString:@""] || [weakSelf.postDetailModel.lng isEqualToString:@""] || weakSelf.postDetailModel.lat == nil || weakSelf.postDetailModel.lng == nil) {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kAppStatusBar)];
                headerView.backgroundColor = [UIColor clearColor];
                weakSelf.detailTableView.tableHeaderView = headerView;
            } else {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 130)];
                headerView.backgroundColor = [UIColor clearColor];
                weakSelf.detailTableView.tableHeaderView = headerView;
                
                weakSelf.postDetailMapView = [[XTCMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 130)];
                weakSelf.postDetailMapView.showsUserLocation = NO;
                weakSelf.postDetailMapView.delegate = weakSelf;
                weakSelf.postDetailMapView.userTrackingMode = MAUserTrackingModeNone;
                weakSelf.postDetailMapView.showsCompass = NO;
                weakSelf.postDetailMapView.showsScale = NO;
                weakSelf.postDetailMapView.maxZoomLevel = 17;
                weakSelf.postDetailMapView.showsWorldMap = @1;
                [weakSelf.view addSubview:weakSelf.postDetailMapView];
                
                // 自定义地图样式
                NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
                [weakSelf.postDetailMapView setCustomMapStyleWithWebData:data];
                [weakSelf.postDetailMapView setCustomMapStyleEnabled:YES];
                [weakSelf buildMap];
            }
            [weakSelf.detailTableView reloadData];
            
            if ([weakSelf getTableViewHeight] < kScreenHeight) {
                weakSelf.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
                weakSelf.footerView.backgroundColor = [UIColor clearColor];
                weakSelf.detailTableView.tableFooterView = weakSelf.footerView;
            } else {
                weakSelf.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
                weakSelf.footerView.backgroundColor = [UIColor clearColor];
                weakSelf.detailTableView.tableFooterView = weakSelf.footerView;
                
                UILabel *footerLabel = [[UILabel alloc] init];
                footerLabel.textColor = RGBCOLOR(74, 74, 74);
                footerLabel.font = [UIFont systemFontOfSize:10];
                footerLabel.text = @"别翻了，到底了";
                [weakSelf.footerView addSubview:footerLabel];
                [footerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(weakSelf.footerView);
                }];
                
                UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [topButton setImage:[UIImage imageNamed:@"detail_top"] forState:UIControlStateNormal];
                [topButton addTarget:weakSelf action:@selector(topButtonClick) forControlEvents:UIControlEventTouchUpInside];
                [weakSelf.footerView addSubview:topButton];
                
                [topButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(weakSelf.footerView).with.offset(-13);
                    make.centerY.equalTo(weakSelf.footerView);
                    make.size.mas_equalTo(CGSizeMake(30, 30));
                }];
            }
        } else {
            weakSelf.noNetWorkingShowView.hidden = NO;
            if ([errorModel.code isEqualToString:@"0"]) {
                weakSelf.noNetWorkingShowView.showMessageLabel.text = errorModel.errorString;
                weakSelf.noNetWorkingShowView.retryButton.hidden = YES;
                weakSelf.noNetWorkingShowView.noNetwork.hidden = YES;
            } else {
                weakSelf.noNetWorkingShowView.retryButton.hidden = NO;
                weakSelf.noNetWorkingShowView.noNetwork.hidden = NO;
            }
            weakSelf.detailTableView.hidden = YES;
        }
    }];
}

- (void)retryButtonClick {
    [self loadPostDetailData];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}


- (float)getTableViewHeight {
    @try {
        [_detailTableView layoutIfNeeded];
    }
    @catch (NSException *exception) {
        if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
            DDLogInfo(@"%@", exception);
        } else {
            @throw exception;
        }
    }
    return _detailTableView.contentSize.height;
}

- (void)loadAboutData {
    RequestGetdetailModel *getdetailModelRequest = [[RequestGetdetailModel alloc] init];
    getdetailModelRequest.user_id = [GlobalData sharedInstance].userModel.user_id;
    getdetailModelRequest.token = [GlobalData sharedInstance].userModel.token;
    getdetailModelRequest.post_id = _postDetailId;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestGetdetailv2Enum byRequestDict:getdetailModelRequest callBack:^(id object, RSResponseErrorModel *errorModel) {
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            self->_postDetailModel = object;
            [self->_detailTableView reloadData];
        } else {
            
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _deviceOrientation.delegate = self;
    [_deviceOrientation startMonitor];
    
    [self.navigationController.navigationBar setBackgroundImage:[NBZUtil createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayFinish) name:@"XTCVideoPlayFinish" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideStatusBar)
                                                 name:kVideoStatusBarHide
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showStatusBar)
                                                 name:kVideoStatusBarShow
                                               object:nil];
    
    
    
    [StaticCommonUtil app].allowRotation = NO;
    _isPullPresent = YES;
}


- (void)videoPlayFinish {
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.playingCell) {
        [self.playingCell.playBgView jp_gotoPortrait];
        [self.playingCell.playBgView jp_stopPlay];
        self.playingCell.playVideoButton.hidden = NO;
        self.playingCell.playBgView.hidden = YES;
    }
    self.isPlayVideo = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self videoPlayFinish];
    // 界面消失不监听屏幕方向
    _deviceOrientation.delegate = nil;
    [_deviceOrientation stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_postDetailModel) {
        if ([_postDetailModel.post_type isEqualToString:@"video"]) {
            return 2;
        } else {
            if ([_postDetailModel.post_type isEqualToString:@"multimedia"]) {
                return _postDetailModel.resource.count+2;
            } else {
                return _postDetailModel.headImgList.count+2;
            }
        }
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // 标题 时间位置 描述
        if (_postDetailModel.postDescript && _postDetailModel.postDescript.length) {
            return 4;
        } else {
            return 3;
        }
    } else if (section <= _postDetailModel.sourceArray.count) {
        return 3;
    } else {
        return 2;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                static NSString *cellName = @"XTCPostDetailTitleCellName";
                XTCPostDetailTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[XTCPostDetailTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.postTitleLabel.text = _postDetailModel.postName;
                cell.postTitleLabel.font = [UIFont fontWithName:kHelveticaBold size:23];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (_postDetailModel.voiceUrl && _postDetailModel.voiceUrl.length) {
                    cell.playAudioButton.hidden = NO;
                } else {
                    cell.playAudioButton.hidden = YES;
                }
                [cell.playAudioButton addTarget:self action:@selector(playAudioButtonClick) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
                break;
            case 1: {
                static NSString *cellName = @"XTCPublishSearchLinkCellName";
                XTCPublishSearchLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[XTCPublishSearchLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                if (_postDetailModel.art_link && _postDetailModel.art_link.length) {
                    cell.searchLinkButton.hidden = NO;
                } else {
                    cell.searchLinkButton.hidden = YES;
                }
                [cell.searchLinkButton addTarget:self action:@selector(searchLinkButtonClick) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
                break;
            case 2: {
                static NSString *cellName = @"NewPublishPostAboutCellName";
                NewPublishPostAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[NewPublishPostAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                [cell insertAbouData:_postDetailModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
                return cell;
            }
                break;
            case 3: {
                static NSString *cellName = @"DetailSelectCellName";
                DetailSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[DetailSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell insertAbouData:_postDetailModel];
                cell.descLabel.userInteractionEnabled = YES;
                if (_isShowDetailPostDesc) {
                    cell.descLabel.numberOfLines = 0;
                } else {
                    cell.descLabel.numberOfLines = 2;
                }
                return cell;
            }
                break;
                
                
            default:
                break;
        }
    } else if (indexPath.section <= _postDetailModel.sourceArray.count) {
        XTCPostDetailSourceModel *sourceModel = _postDetailModel.sourceArray[indexPath.section-1];
        if (indexPath.row == 0) {
            // 小标题
            static NSString *cellName = @"XTCPostTitleDescCellName";
            XTCPostTitleDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCPostTitleDescCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.showTitleLabel.font = [UIFont fontWithName:kHelveticaBold size:21];
            NSMutableAttributedString *textAttrStr = [NBZUtil createOCEmoji:sourceModel.imageTitle];
            if (sourceModel.imageTitle && sourceModel.imageTitle.length) {
                cell.bottomLayoutConstraint.constant = 10;
            } else {
                cell.bottomLayoutConstraint.constant = 0;
            }
            cell.showTitleLabel.attributedText = textAttrStr;
            cell.showTitleLabel.numberOfLines = 0;
            cell.showTitleLabel.textColor = RGBCOLOR(31, 31, 31);
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (indexPath.row == 1) {
            // 描述
            static NSString *cellName = @"XTCPostTitleDescCellName";
            XTCPostTitleDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCPostTitleDescCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.showTitleLabel.font = [UIFont fontWithName:kHelvetica size:19];
            
            cell.showTitleLabel.numberOfLines = 0;
            cell.showTitleLabel.textColor = RGBCOLOR(74, 74, 74);
            NSMutableAttributedString *textAttrStr = [NBZUtil createOCEmoji:sourceModel.imageDesc];
            if (sourceModel.imageDesc && sourceModel.imageDesc.length) {
                cell.bottomLayoutConstraint.constant = 10;
            } else {
                cell.bottomLayoutConstraint.constant = 0;
            }
            cell.showTitleLabel.attributedText = textAttrStr;
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            if (sourceModel.videoUrl && sourceModel.videoUrl.length) {
                static NSString *cellName = @"PostDetailShowVideoCellName";
                PostDetailShowVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[PostDetailShowVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                    
                }
                cell.showImageView.backgroundColor = kTableviewColor;
                [cell insertAboutData:sourceModel];
                [cell.playVideoButton addTarget:self action:@selector(playPostVideo) forControlEvents:UIControlEventTouchUpInside];
                _playingCell = cell;
                if ([sourceModel.width intValue] > [sourceModel.height intValue]) {
                    self.isVerticalPlay = NO;
                } else {
                    self.isVerticalPlay = YES;
                }
                if ( self.isPlayVideo) {
                    // 如果正在播放
                    cell.playBgView.hidden = NO;
                    cell.playVideoButton.hidden = YES;
                } else {
                    cell.playBgView.hidden = YES;
                    cell.playVideoButton.hidden = NO;
                }
                NSString *imageUrl = sourceModel.thumImage != nil ? sourceModel.thumImage : sourceModel.image;
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (error) {
                        
                    } else {
                        CGRect rectInTableView = [tableView rectForRowAtIndexPath: indexPath];
                        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
                        if ( rectInSuperview.origin.y > kScreenHeight || rectInSuperview.origin.y + rectInSuperview.size.height < 0 ) {
                            // 对已经移出屏幕的 Cell 做相应的处理
                            cell.showImageView.image = nil;
                        } else {
                            [cell.showImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed];
                        }
                    }
                }];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else {
                static NSString *cellName = @"PostDetailShowCellName";
                PostDetailShowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[PostDetailShowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                    
                }
                cell.showImageView.backgroundColor = kTableviewColor;
                [cell insertAboutData:sourceModel];
                cell.showImageView.image = nil;
                NSString *imageUrl = sourceModel.thumImage != nil ? sourceModel.thumImage : sourceModel.image;
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (error) {
                        
                    } else {
                        CGRect rectInTableView = [tableView rectForRowAtIndexPath: indexPath];
                        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
                        if ( rectInSuperview.origin.y > kScreenHeight || rectInSuperview.origin.y + rectInSuperview.size.height < 0 ) {
                            // 对已经移出屏幕的 Cell 做相应的处理
                            cell.showImageView.image = nil;
                        } else {
                            [cell.showImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed];
                        }
                    }
                }];
                
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
    } else {
        if (indexPath.row == 0) {
            static NSString *cellName = @"XTCPostTitleDescCellName";
            XTCPostTitleDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCPostTitleDescCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.showTitleLabel.font = [UIFont fontWithName:kHelveticaBold size:21];
            NSMutableAttributedString *textAttrStr = [NBZUtil createOCEmoji:_postDetailModel.ending_title];
            if (_postDetailModel.ending_title && _postDetailModel.ending_title.length) {
                cell.bottomLayoutConstraint.constant = 10;
            } else {
                cell.bottomLayoutConstraint.constant = 0;
            }
            cell.showTitleLabel.attributedText = textAttrStr;
            cell.showTitleLabel.numberOfLines = 0;
            cell.showTitleLabel.textColor = RGBCOLOR(31, 31, 31);
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            // 描述
            static NSString *cellName = @"XTCPostTitleDescCellName";
            XTCPostTitleDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCPostTitleDescCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.showTitleLabel.font = [UIFont fontWithName:kHelvetica size:19];
            
            cell.showTitleLabel.numberOfLines = 0;
            cell.showTitleLabel.textColor = RGBCOLOR(74, 74, 74);
            NSMutableAttributedString *textAttrStr = [NBZUtil createOCEmoji:_postDetailModel.ending_desc];
            if (_postDetailModel.ending_desc && _postDetailModel.ending_desc.length) {
                cell.bottomLayoutConstraint.constant = 10;
            } else {
                cell.bottomLayoutConstraint.constant = 0;
            }
            cell.showTitleLabel.attributedText = textAttrStr;
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    return cell;
    
}


- (void)playPostVideo {
    __weak typeof(self) weakSelf = self;
    _playingCell.playBgView.hidden = NO;
    _playingCell.playVideoButton.hidden = YES;
    [_playingCell.playBgView jp_playVideoWithURL:[NSURL URLWithString:self.postDetailModel.videoUrl]
                              bufferingIndicator:nil controlView:nil progressView:nil configurationCompletion:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                  weakSelf.isPlayVideo = YES;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (weakSelf.isVerticalPlay) {
                                          [weakSelf.playingCell.playBgView jp_gotoLandscape:NO byDeviceOrientation:UIInterfaceOrientationPortrait];
                                      } else {
                                          
                                      }
                                  });
                              }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            if (_postDetailModel.art_link && _postDetailModel.art_link.length) {
                return 30;
            } else {
                return 0.01f;
            }
        } else {
            return UITableViewAutomaticDimension;
        }
    } else if (indexPath.section > _postDetailModel.sourceArray.count) {
        if (indexPath.row == 0) {
            if (_postDetailModel.ending_title == nil || _postDetailModel.ending_title .length == 0) {
                return 0.01f;
            } else {
                return UITableViewAutomaticDimension;
            }
            return 0.01f;
        } else {
            if (_postDetailModel.ending_desc  == nil || _postDetailModel.ending_desc.length == 0) {
                return 0.01f;
            } else {
                return UITableViewAutomaticDimension;
            }
        }
    } else {
        XTCPostDetailSourceModel *sourceModel = _postDetailModel.sourceArray[indexPath.section-1];
        if (indexPath.row == 0) {
            if (sourceModel.imageTitle == nil || sourceModel.imageTitle.length == 0) {
                return 0.01f;
            } else {
                return UITableViewAutomaticDimension;
            }
            return 0.01f;
        } else if (indexPath.row == 1) {
            if (sourceModel.imageDesc == nil || sourceModel.imageDesc.length == 0) {
                return 0.01f;
            } else {
                return UITableViewAutomaticDimension;
            }
            
        } else {
            XTCPostDetailSourceModel *sourceModel = _postDetailModel.sourceArray[indexPath.section-1];
            CGFloat width = [sourceModel.width floatValue];
            CGFloat height = [sourceModel.height floatValue];
            
            CGFloat flagWidth = kScreenWidth - 34;
            if (height > width) {
                flagWidth = kScreenWidth - kScreenWidth * 0.3;
            }
            return height/width*flagWidth;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 15;
    } else if (section <= _postDetailModel.sourceArray.count)  {
        XTCPostDetailSourceModel *sourceModel = _postDetailModel.sourceArray[section-1];
        if ((sourceModel.imageTitle && sourceModel.imageTitle.length) || (sourceModel.imageDesc && sourceModel.imageDesc.length)) {
            return 35.0f;
        } else {
            if (section == 1) {
                return 25.0f;
            } else {
                return 20.0f;
            }
        }
    } else {
        return 35.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == _postDetailModel.sourceArray.count + 1) {
        if (TagFlagWidth *_postDetailModel.tag_list.count + 50 > kScreenWidth) {
            if ([_postDetailModel.level intValue] > 1 && _postDetailModel.is_bussiness == 1) {
                return 130.0f;
            } else {
                return 80.0f;
            }
        } else {
            if ([_postDetailModel.level intValue] > 1 && _postDetailModel.is_bussiness == 1) {
                return 80.0f;
            } else {
                return 50.0f;
            }
        }
    } else {
        return 0.01f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    if (section == _postDetailModel.sourceArray.count + 1) {
        UIView *flagView = [[UIView alloc] init];
        flagView.backgroundColor = [UIColor clearColor];
        [footerView addSubview:flagView];
        
        [flagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(footerView);
            make.bottom.equalTo(footerView).with.offset(-10);
        }];
        DetailTagFlowLayout *flowLayOut = [[DetailTagFlowLayout alloc] init];
        flowLayOut.minimumLineSpacing = 3;
        UICollectionView *tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayOut];
        [flagView addSubview:tagCollectionView];
        tagCollectionView.delegate = self;
        tagCollectionView.dataSource = self;
        tagCollectionView.backgroundColor = [UIColor clearColor];
        
        float flagWidth;
        if (TagFlagWidth *_postDetailModel.tag_list.count + 50 > kScreenWidth) {
            flagWidth = 60.0f;
        } else {
            flagWidth = 30.0f;
        }
        
        [tagCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(footerView).with.offset(10);
            make.right.equalTo(footerView).with.offset(-10);
            make.top.equalTo(footerView).with.offset(10);
            make.height.mas_equalTo(flagWidth);
        }];
        [tagCollectionView registerClass:[DetailTagCell class] forCellWithReuseIdentifier:@"UICollectionViewCellName"];
        [tagCollectionView reloadData];
        
        if ([_postDetailModel.level intValue] > 1 && _postDetailModel.is_bussiness == 1) {
            UIView *qrCodeView = [[UIView alloc] init];
            qrCodeView.backgroundColor = [UIColor clearColor];
            [footerView addSubview:qrCodeView];
            [qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(footerView);
                make.top.equalTo(tagCollectionView.mas_bottom).with.offset(10);
                make.size.mas_equalTo(CGSizeMake(kScreenWidth, 40));
            }];
            // 251 200 46
            UIButton *printCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            printCodeButton.backgroundColor = [UIColor orangeColor];
            [printCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [qrCodeView addSubview:printCodeButton];
            
            [printCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(qrCodeView.mas_centerX);
                make.centerY.equalTo(qrCodeView);
                make.size.mas_equalTo(CGSizeMake(120, 40));
            }];
            
            UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];
            printButton.backgroundColor = [UIColor clearColor];
            printButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
            [printButton setTitle:@"印刷二维码" forState:UIControlStateNormal];
            [printButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            printButton.tag = 101;
            [printButton addTarget:self action:@selector(qrCodeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [qrCodeView addSubview:printButton];
            
            [printButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(printCodeButton);
            }];
            
            UIBezierPath *printBezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 120, 40) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(20, 20)];
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.path = printBezierPath.CGPath;
            printCodeButton.layer.mask = mask;
            printCodeButton.clipsToBounds = YES;
            
            CAGradientLayer *printBgLayer = [CAGradientLayer layer];
            printBgLayer.frame = CGRectMake(0, 0, 120, 40);
            [printCodeButton.layer insertSublayer:printBgLayer below:mask];
            
            //设置渐变区域的起始和终止位置（范围为0-1）
            printBgLayer.startPoint = CGPointMake(0, 0);
            printBgLayer.endPoint = CGPointMake(1, 1);
            
            //设置颜色数组
            printBgLayer.colors = @[(__bridge id)RGBCOLOR(251, 200, 46).CGColor,
                                    (__bridge id)RGBACOLOR(251, 151, 39, 1).CGColor];
            //设置颜色分割点（范围：0-1）
            printBgLayer.locations = @[@(0.0f), @(1.0f)];
            
            
            // 251 77 31
            UIButton *interCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            interCodeButton.backgroundColor = RGBCOLOR(251, 77, 31);
            [interCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [qrCodeView addSubview:interCodeButton];
            
            [interCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(qrCodeView.mas_centerX);
                make.centerY.equalTo(qrCodeView);
                make.size.mas_equalTo(CGSizeMake(120, 40));
            }];
            
            UIButton *interButton = [UIButton buttonWithType:UIButtonTypeCustom];
            interButton.backgroundColor = [UIColor clearColor];
            interButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
            [interButton setTitle:@"互动二维码" forState:UIControlStateNormal];
            [interButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            interButton.tag = 102;
            [interButton addTarget:self action:@selector(qrCodeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [qrCodeView addSubview:interButton];
            
            [interButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(interCodeButton);
            }];
            
            UIBezierPath *interBezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 120, 40) byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(20, 20)];
            CAShapeLayer *interMask = [CAShapeLayer layer];
            interMask.path = interBezierPath.CGPath;
            interCodeButton.layer.mask = interMask;
            interCodeButton.clipsToBounds = YES;
            
            
            CAGradientLayer *interBgLayer = [CAGradientLayer layer];
            interBgLayer.frame = CGRectMake(0, 0, 120, 40);
            [interCodeButton.layer insertSublayer:interBgLayer below:mask];
            
            //设置渐变区域的起始和终止位置（范围为0-1）
            interBgLayer.startPoint = CGPointMake(0, 0);
            interBgLayer.endPoint = CGPointMake(1, 1);
            
            //设置颜色数组
            interBgLayer.colors = @[(__bridge id)RGBACOLOR(251, 117, 35, 1).CGColor,
                                    (__bridge id)RGBACOLOR(251, 77, 31, 1).CGColor];
            //设置颜色分割点（范围：0-1）
            interBgLayer.locations = @[@(0.0f), @(1.0f)];
            
            
            
        } else {
            
        }
        
    } else {
        
    }
    return footerView;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            // 描述展开与关闭
            if (_postDetailModel.postDescript && _postDetailModel.postDescript.length) {
                _isShowDetailPostDesc = !_isShowDetailPostDesc;
                [_detailTableView reloadData];
                /*
                 [_detailTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                 */
            } else {
                
            }
        } else {
            
        }
    }
    if (indexPath.section >= 1 && indexPath.section <= _postDetailModel.sourceArray.count) {
        if (indexPath.row == 2) {
            XTCPostDetailSourceModel *sourceModel = _postDetailModel.sourceArray[indexPath.section-1];
            if (sourceModel.videoUrl && sourceModel.videoUrl.length) {
                
            } else {
                MWPhotoBrowser *postDetailPhotoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                [postDetailPhotoBrowser setCurrentPhotoIndex:indexPath.section-1];
                postDetailPhotoBrowser.autoPlayOnAppear = NO;
                postDetailPhotoBrowser.displayActionButton = NO;
                postDetailPhotoBrowser.postUserId = _postDetailModel.userId;
                NSMutableArray *flagDescArray = [[NSMutableArray alloc] init];
                for (NSDictionary *flagUrlDict in _postDetailModel.headImgList) {
                    PublishSourceModel *sourceModel = [[PublishSourceModel alloc] init];
                    if ([_postDetailModel.post_type isEqualToString:@"multimedia"]) {
                        sourceModel.sourceDesc = flagUrlDict[@"text"];
                    } else {
                        sourceModel.sourceDesc = flagUrlDict[@"image_desc"];
                    }
                    sourceModel.dateTimeOriginal = flagUrlDict[@"DateTimeOriginal"];
                    sourceModel.make = flagUrlDict[@"make"];
                    sourceModel.model = flagUrlDict[@"model"];
                    sourceModel.apertureFNumber = flagUrlDict[@"ApertureFNumber"];
                    sourceModel.exposureTime = flagUrlDict[@"ExposureTime"];
                    sourceModel.focalLength = flagUrlDict[@"FocalLength"];
                    sourceModel.ISOSpeedRatings = flagUrlDict[@"ISOSpeedRatings"];
                    sourceModel.lensModel = flagUrlDict[@"lensModel"];
                    sourceModel.exposureProgram = [flagUrlDict[@"ExposureProgram"] description];
                    sourceModel.exposureBiasValue = [flagUrlDict[@"ExposureBiasValue"] description];
                    [flagDescArray addObject:sourceModel];
                }
                postDetailPhotoBrowser.publishSourceModelArray = flagDescArray;
                XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailPhotoBrowser];
                
                CATransition *transition = [CATransition animation];
                transition.duration = 1.0;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                transition.type = kCATransitionFade;
                transition.subtype = kCATransitionFromBottom;
                [self.view.window.layer addAnimation:transition forKey:@"animation"];
                [self presentViewController:nav animated:NO completion:nil];
            }
        } else {
            
        }
    }
    
}

- (void)topButtonClick {
    CGPoint position = CGPointMake(0, 0);
    [_detailTableView setContentOffset:position animated:YES];
}


#pragma mark - 点击抖动小动画
- (void)animationWithIndex:(UIButton *)flagButton {
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.08;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:0.85];
    pulse.toValue= [NSNumber numberWithFloat:1.15];
    [[flagButton layer] addAnimation:pulse forKey:nil];
}

#pragma mark - 举报按钮被点击
- (void)reportButtonClick {
    [self stopPLayAudio];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCReport" bundle:nil];
    XTCReportViewController *reportVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCReportViewController"];
    reportVC.reportId = _postDetailId;
    reportVC.isChatReport = false;
    [self.navigationController pushViewController:reportVC animated:YES];
}

#pragma mark - 分享按钮被点击
- (void)shareButtonClick:(UIButton *)button {
    NSString *shareText = _postDetailModel.postDescript;
    if (shareText == nil) {
        return;
    }
    [[XTCShareHelper sharedXTCShareHelper] shreDataByTitle:_postDetailModel.share[@"title"] byDesc:_postDetailModel.share[@"desc"] byThumbnailImage:_shareImage byMedia:_postDetailModel.share[@"url"] byVC:self byiPadView:button];
}


- (void)buildShareImage {
    NSString *urlString = _postDetailModel.share[@"prc_url"];
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image == nil) {
            return;
        }
        self->_shareImage = image;
    }];
}

#pragma mark - 下拉展示地图(需要展示动画)
- (void)presentMapVC {
    if (_isPullPresent == NO || _postDetailMapView == nil) {
        return;
    }
    [self stopPLayAudio];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _postDetailModel.lat.doubleValue;
    coordinate.longitude = _postDetailModel.lng.doubleValue;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"detail" bundle:nil];
    NavigateToViewController *mapVC = [storyBoard instantiateViewControllerWithIdentifier:@"NavigateToViewController"];
    mapVC.coordinate = coordinate;
    mapVC.mapList = _postDetailModel.headImgList;
    mapVC.title = _postDetailModel.postName;
    mapVC.userid = _postDetailModel.userId;
    mapVC.isVR = NO;
    if (_postDetailMapView.annotations.count == 1) {
        mapVC.onlyOne = YES;
    } else {
        
    }
    mapVC.isPull = YES;
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self presentViewController:mapVC animated:NO completion:nil];
    _isPullPresent = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0) {
        //        DDLogInfo(@"向上滚动");
        _postDetailMapView.frame = CGRectMake(0, -scrollView.contentOffset.y, kScreenWidth, 130);
    } else {
        _postDetailMapView.frame = CGRectMake(0, 0, kScreenWidth, 130);
    }
    
    if ([self getTableViewHeight]  < kScreenHeight) {
        [self show];
    } else {
        contentOffsetY = scrollView.contentOffset.y;
        if (contentOffsetY - oldContentOffsetY > 5  && contentOffsetY > 0) {
            oldContentOffsetY = contentOffsetY;
            if (_postDetailModel) {
                [self hidden];
            } else {
                [self show];
            }
            
        }
        else if ((oldContentOffsetY - contentOffsetY > 5) && (contentOffsetY <= scrollView.contentSize.height - scrollView.bounds.size.height - 5) )
            
        {
            oldContentOffsetY = contentOffsetY;
            [self show];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //    DDLogInfo(@"1_滑动停止");
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //    DDLogInfo(@"2_滑动停止");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    //    DDLogInfo(@"手指离开");
    if (scrollView.contentOffset.y < -80) {
        [self presentMapVC];
    } else {
        
    }
}


- (void)hidden{
    if (_postDetailBottomTabView.hidden) {
        
    } else {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.35;
        [_postDetailBottomTabView.layer addAnimation:animation forKey:nil];
        
        _postDetailBottomTabView.hidden = YES;
    }
    
}

- (void)show {
    if (_postDetailBottomTabView.hidden) {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.35;
        [_postDetailBottomTabView.layer addAnimation:animation forKey:nil];
        
        _postDetailBottomTabView.hidden = NO;
    } else {
        
    }
    
}

#pragma mark - 点击地图
- (void)tapMap {
    [self stopPLayAudio];
    /*
     CLLocationCoordinate2D coordinate;
     coordinate.latitude = _postDetailModel.lat.doubleValue;
     coordinate.longitude = _postDetailModel.lng.doubleValue;
     UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"detail" bundle:nil];
     NavigateToViewController *mapVC = [storyBoard instantiateViewControllerWithIdentifier:@"NavigateToViewController"];
     mapVC.coordinate = coordinate;
     mapVC.mapList = _postDetailModel.headImgList;
     mapVC.title = _postDetailModel.postName;
     mapVC.userid = _postDetailModel.userId;
     mapVC.isVR = NO;
     if (_postDetailMapView.annotations.count == 1) {
     mapVC.onlyOne = YES;
     } else {
     
     }
     mapVC.isPull = NO;
     [self.navigationController pushViewController:mapVC animated:YES];
     */
    [self presentMapVC];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if ([_postDetailModel.post_type isEqualToString:@"multimedia"]) {
        return _postDetailModel.resource.count;
    } else {
        return _postDetailModel.headImgList.count;
    }
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo;
    if ([_postDetailModel.post_type isEqualToString:@"photo"] || [_postDetailModel.post_type isEqualToString:@"multimedia"]) {
        NSDictionary *flagPostDict = _postDetailModel.headImgList[index];
        photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:flagPostDict[@"image"]]];
    }
    if ([_postDetailModel.post_type isEqualToString:@"multimedia"]) {
        NSDictionary *flagPostDict = _postDetailModel.resource[index];
        if ([flagPostDict[@"type"] isEqualToString:@"photo"]) {
            photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:flagPostDict[@"image"]]];
        } else {
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:flagPostDict[@"image"]]];
            photo.videoURL = [NSURL URLWithString:flagPostDict[@"video"]];
        }
    }
    
    
    return photo;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _postDetailModel.tag_list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellName" forIndexPath:indexPath];
    cell.tagLabel.text = _postDetailModel.tag_list[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 27);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}

#pragma mark - 推荐链接点击
- (void)searchLinkButtonClick {
    [self stopPLayAudio];
    CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
    commonWebViewVC.isPreventPanPop = NO;
    commonWebViewVC.titleString = @"查看网站";
    if ([_postDetailModel.art_link hasPrefix:@"http"] || [_postDetailModel.art_link hasPrefix:@"https"]) {
        commonWebViewVC.urlString = _postDetailModel.art_link;
    } else {
        commonWebViewVC.urlString = [NSString stringWithFormat:@"http://%@", _postDetailModel.art_link];
    }
    [self.navigationController pushViewController:commonWebViewVC animated:YES];
    
}

#pragma mark - 单击地图回调
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self presentMapVC];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[XTCPointAnnotation class]])
    {
        NSString * reusedId = @"NormalAnnotation";
        CustomAnnotationView *newAnnotation = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedId];
        if (!newAnnotation) {
            newAnnotation = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedId];
        }
        //        newAnnotation.portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        newAnnotation.portraitImageView.image = [UIImage imageNamed:@"imageIcon"];
        newAnnotation.isCanCallout = NO;
        return newAnnotation;
    }
    return nil;
}

- (void)buildMap {
    if (_postDetailModel == nil || _postDetailModel.headImgList.count == 0) {
        return;
    }
    NSDictionary *flagDict = [_postDetailModel.headImgList firstObject];
    Post *streamModel = [[Post alloc] initStreamModelWith:flagDict];
    for (int i = 0; i < _postDetailModel.headImgList.count; i++) {
        NSDictionary *dict = _postDetailModel.headImgList[i];
        Post *flagStreamModel = [[Post alloc] initStreamModelWith:dict];
        if ([flagStreamModel.lat isEqualToString:@""] && [flagStreamModel.lng isEqualToString:@""] ) {
            
        } else {
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(flagStreamModel.lat.doubleValue, flagStreamModel.lng.doubleValue);
            if (![TQLocationConverter isLocationOutOfChina:locationCoordinate]) {
                locationCoordinate = [TQLocationConverter transformFromWGSToGCJ:locationCoordinate];
                
            } else {
                
            }
            XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
            pointAnnotation.coordinate = locationCoordinate;
            pointAnnotation.title = streamModel.postTitle;
            //            pointAnnotation.subtitle = streamModel.user.user_name;
            [_postDetailMapView addAnnotation:pointAnnotation];
        }
    }
    if (_postDetailMapView.annotations.count == 0) {
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(_postDetailModel.lat.doubleValue, _postDetailModel.lng.doubleValue);
        
        if (![TQLocationConverter isLocationOutOfChina:locationCoordinate]) {
            locationCoordinate = [TQLocationConverter transformFromWGSToGCJ:locationCoordinate];
        } else {
            
        }
        XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
        pointAnnotation.coordinate = locationCoordinate;
        pointAnnotation.title = streamModel.postTitle;
        //        pointAnnotation.subtitle = streamModel.user.user_name;
        [_postDetailMapView addAnnotation:pointAnnotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_postDetailMapView setCenterCoordinate:locationCoordinate zoomLevel:12 animated:YES];
        });
        
    } else {
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.postDetailMapView.annotations.count == 1) {
            XTCPointAnnotation *pointAnnotation = self.postDetailMapView.annotations.firstObject;
            [self.postDetailMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:12 animated:NO];
        } else {
            if ([self checkCoordinateSame]) {
                XTCPointAnnotation *pointAnnotation = self.postDetailMapView.annotations.firstObject;
                [self.postDetailMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:12 animated:NO];
            } else {
                NSMutableArray *flagArray = [CoordinateHelper screenShowCoor:self.postDetailMapView.annotations];
                [self.postDetailMapView showAnnotations:flagArray animated:NO];
            }
            
        }
    });
}

#pragma mark - 返回操作
- (void)backAction {
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[PlayerManager sharedInstance].player pause];
}


- (void)labelTapGes:(UITapGestureRecognizer *) tapGes{
    UILabel *descLabel = (UILabel *)tapGes.view;
    if (descLabel.numberOfLines == 2) {
        descLabel.numberOfLines = 0;
    } else {
        descLabel.numberOfLines = 2;
    }
    [_detailTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)headerImageButtonClick {
    
}


- (void)controlAudioAnimation:(XTCPostDetailTitleCell *)cell {
    UIImageView *imageView = cell.playAudioButton.imageView;
    [imageView stopAnimating];
    if (_isPlayAudioStatus) {
        //设置动画帧
        imageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"detail_start_voice_1"],
                                     [UIImage imageNamed:@"detail_start_voice_2"],
                                     [UIImage imageNamed:@"detail_start_voice_3"],
                                     nil ];
        imageView.animationDuration = 1.5;
        imageView.animationRepeatCount = 0;
        if (!imageView.isAnimating) {
            [imageView startAnimating];
        }
    } else {
        
    }
}

#pragma mark - 音频播放完成或失败
- (void)playerManagerVideoFinish {
    [self hysteriaPlayerDidReachEnd];
}

- (void)dealloc {
    DDLogInfo(@"帖子详情页内存释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoStatusBarShow object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoStatusBarHide object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReloadCommentName" object:nil];
    [_postDetailLoadingView removeFromSuperview];
    _postDetailLoadingView = nil;
    [PlayerManager sharedInstance].finishDelegate = nil;
    if (_postDetailMapView) {
        [_postDetailMapView removeFromSuperview];
        _postDetailMapView = nil;
    } else {
        
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)playAudioButtonClick {
    XTCPostDetailTitleCell *cell = [_detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    _isPlayAudioStatus = !_isPlayAudioStatus;
    [[PlayerManager sharedInstance].player pause];
    if (_isPlayAudioStatus) {
        [[PlayerManager sharedInstance] play:[NSArray arrayWithObject: _postDetailModel.voiceUrl]];
        if ([PlayerManager sharedInstance].finishDelegate == nil) {
            [PlayerManager sharedInstance].finishDelegate = self;
        }
    } else {
        
    }
    [self controlAudioAnimation:cell];
}

- (void)hysteriaPlayerDidReachEnd {
    XTCPostDetailTitleCell *cell = [_detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.playAudioButton.imageView stopAnimating];
    _isPlayAudioStatus = NO;
    [self controlAudioAnimation:cell];
}


#pragma mark - 停止播放语音
- (void)stopPLayAudio {
    [[PlayerManager sharedInstance].player pause];
    [self hysteriaPlayerDidReachEnd];
}

- (BOOL)checkCoordinateSame {
    BOOL isFlag = YES;
    XTCPointAnnotation *pointAnnotation = _postDetailMapView.annotations.firstObject;
    CLLocationCoordinate2D coor = pointAnnotation.coordinate;
    for (XTCPointAnnotation *pointAnnotation in _postDetailMapView.annotations) {
        if (pointAnnotation.coordinate.latitude == coor.latitude && pointAnnotation.coordinate.longitude == coor.longitude) {
            
        } else {
            isFlag = NO;
            break;
        }
    }
    return isFlag;
}

#pragma mark - 印刷和互动二维码
- (void)qrCodeButtonClick:(UIButton *)codeButton {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PostQRCode" bundle:nil];
    PostQRCodeViewController *postQRCodeVC = [storyBoard instantiateViewControllerWithIdentifier:@"PostQRCodeViewController"];
    postQRCodeVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
    if (codeButton.tag == 101) {
        postQRCodeVC.isPrinting = YES;
        postQRCodeVC.codeCenterLayOutConstraint.constant = 0;
    } else {
        postQRCodeVC.isPrinting = NO;
    }
    
    postQRCodeVC.postDetailModel = _postDetailModel;
    postQRCodeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:postQRCodeVC animated:NO completion:^{
        [postQRCodeVC loadAboutData];
    }];
}

#pragma mark - 视频播放转屏
- (void)directionChange:(TgDirection)direction {
    if (_isVerticalPlay == NO && _playingCell && _playingCell.playBgView.hidden == NO) {
        if (direction == TgDirectionPortrait) {
            [self.playingCell.playBgView jp_gotoPortrait];
        }
        if (direction == TgDirectionRight) {
            [self.playingCell.playBgView jp_gotoLandscape:YES byDeviceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        if (direction == TgDirectionleft) {
            [self.playingCell.playBgView jp_gotoLandscape:YES byDeviceOrientation:UIInterfaceOrientationLandscapeLeft];
        }
    } else {
        
    }
}

- (void)hideStatusBar {
    _isHideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showStatusBar {
    _isHideStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return _isHideStatusBar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
