//
//  XTCPublishViewController.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/5.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishViewController.h"

@interface XTCPublishViewController () {
    JZMp3RecordingClient *_recordClient;
    NSDateFormatter *_dateFormatter;
    BOOL _isHideStatusBar;
    DeviceOrientation *_deviceOrientation;
}

@end

@implementation XTCPublishViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.publishNavigationViewController = (XTCBaseNavigationController *)[StaticCommonUtil topViewController].navigationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 是否隐藏状态栏
    _isHideStatusBar = NO;
    // 开启屏幕监听
    _deviceOrientation = [DeviceOrientation sharedDeviceOrientation];
    //    _deviceOrientation.delegate = self;
    _isVerticalPlay = NO;
    
    [self checkCurrentPublishLocaltion];
    
    _sourceModelArray = [[NSMutableArray alloc] init];
    _postShowCity = @"";
    _countryCode = @"";
    _recordClient = [JZMp3RecordingClient sharedClient];
    _isPlayVideo = NO;
    
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    // 相关UI
    self.sortButton.hidden = YES;
    [self.sortButton addTarget:self action:@selector(sortSourceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self setupPublishTableViewUI];
    [self createBottomViewUI];
    
    [self buildPublishModel];
    
    if (_publishContentEnum == PublishContentSpotEnum) {
        [self addTagButtonClick];
    } else {
        [self selectSourceButtonClick];
    }
    
    //  文件时间唯一标识
    [_dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    _audioDateString = [_dateFormatter stringFromDate:[NSDate date]];
    
    // 屏蔽返回上一页手势
    UIPanGestureRecognizer *cancelFullScreenGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cancelFullScreenGes)];
    [self.view addGestureRecognizer:cancelFullScreenGes];
    
    // 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayFinish) name:@"XTCVideoPlayFinish" object:nil];
    // 旅行相机录制视频
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gainRecordVideo:) name:@"PhotoLibraryReloadVideoAgainName" object:nil];
    
}

- (void)gainRecordVideo:(NSNotification *)notification {
    NSArray *finishArray = notification.object;
    [self recodeVideoFinish:finishArray];
}

#pragma mark - 录制视频完成
- (void)recodeVideoFinish:(NSArray *)finishArray {
    [self loadPublishData:[[NSMutableArray alloc] initWithArray: finishArray] byPhoto:[[NSMutableArray alloc] init] byPublishType:SelectPublishTypeVideoEnum];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _deviceOrientation.delegate = self;
    [_deviceOrientation startMonitor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideStatusBar)
                                                 name:kVideoStatusBarHide
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showStatusBar)
                                                 name:kVideoStatusBarShow
                                               object:nil];
    //  键盘弹出处理
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 界面消失时停止视频播放
    [self videoPlayFinish];
    _deviceOrientation.delegate = nil;
    [_deviceOrientation stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoStatusBarHide object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoStatusBarShow object:nil];
}

#pragma makr - 设置tableview的相关样式
- (void)setupPublishTableViewUI {
    _publishTableView.backgroundColor = [UIColor whiteColor];
    _publishTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _publishTableView.estimatedRowHeight = 0;
    _publishTableView.estimatedSectionHeaderHeight = 0;
    _publishTableView.estimatedSectionFooterHeight = 0;
    _publishTableView.showsVerticalScrollIndicator = NO;
    
    _publishTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kAppStatusBar)];
    
    if (@available(iOS 11.0, *)) {
        if (kDevice_Is_iPhoneX) {
            _publishTableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
            self.edgesForExtendedLayout = UIRectEdgeNone;
        } else {
            _publishTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

#pragma mark - 创建底部菜单容器
- (void)createBottomViewUI {
    self.publishButton.layer.cornerRadius = 15;
    self.publishButton.layer.masksToBounds = YES;
    
    _addTagButton.layer.cornerRadius = 15;
    _addTagButton.layer.masksToBounds = YES;
    _addTagButton.layer.borderWidth = 1;
    _addTagButton.layer.borderColor = HEX_RGB(0x2B3857).CGColor;
    
    _moreButton.layer.cornerRadius = 15;
    _moreButton.layer.masksToBounds = YES;
    _moreButton.layer.borderWidth = 1;
    _moreButton.layer.borderColor = HEX_RGB(0x2B3857).CGColor;
    
    _selectBusinessTypeButton.layer.cornerRadius = 15;
    _selectBusinessTypeButton.layer.masksToBounds = YES;
    _selectBusinessTypeButton.layer.borderWidth = 1;
    _selectBusinessTypeButton.layer.borderColor = HEX_RGB(0x2B3857).CGColor;
    
    if (kScreenWidth == 320) {
        _moreWidthLayoutConstraint.constant = 60;
        _tagWidthConstraint.constant = 60;
        //        _moreLeftLayoutConstraint.constant = 8;
    } else {
        _moreWidthLayoutConstraint.constant = 75;
        //        _moreLeftLayoutConstraint.constant = 15;
        _tagWidthConstraint.constant = 75;
    }
    [self.popButton addTarget:self action:@selector(popButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_addTagButton addTarget:self action:@selector(addTagButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_publishButton addTarget:self action:@selector(publishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _addPhotoButton.tag = 101;
    [_addPhotoButton addTarget:self action:@selector(addPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    if (_publishContentEnum == PublishContentSpotEnum) {
        _selectBusinessTypeBgView.hidden = NO;
        _moreButton.hidden = YES;
        _addTagButton.hidden = YES;
    } else {
        _selectBusinessTypeBgView.hidden = YES;
        _moreButton.hidden = NO;
        _addTagButton.hidden = NO;
    }
    [_selectBusinessTypeButton addTarget:self action:@selector(addTagButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 创建初始化发布model
- (void)buildPublishModel {
    if (_publishNormalPostModel == nil) {
        _publishNormalPostModel = [[PublishNormalPostModel alloc] init];
        _publishNormalPostModel.tk = @"";
        _publishNormalPostModel.share_location = @"Y";
        _publishNormalPostModel.is_personal = @"N";
        _publishNormalPostModel.sub_post_id = _interactivePostId;
        _publishNormalPostModel.chatType = _chatType;
        _publishNormalPostModel.chatId = _chatId;
        _publishNormalPostModel.is_bus = @"0";
        _publishNormalPostModel.tourTime = @""; // 旅行时间
        if (_publishContentEnum == PublishRoadBookEnum) {
            _publishNormalPostModel.isBusShow = YES;
        } else {
            _publishNormalPostModel.isBusShow = NO;
        }
        // 发布日期
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        _publishNormalPostModel.dateString = [_dateFormatter stringFromDate:[NSDate date]];
        _publishNormalPostModel.artLinkVerifyFinish = NO;
    }
}

#pragma mark - 发布默认弹出资源选择
- (void)selectSourceButtonClick {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPublishPicker" bundle:nil];
    XTCPublishPickerViewController *publishPickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPublishPickerViewController"];
    publishPickerVC.isSinglePick = NO;
    publishPickerVC.publishCancelCallBack = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.publishNavigationViewController popViewControllerAnimated:NO];
        });
    };
    publishPickerVC.selectPublishSourceCallBack = ^(NSMutableArray * _Nullable assetArray, NSMutableArray * _Nullable photoArray, SelectPublishTypeEnum selectPublishTypeEnum) {
        [weakSelf loadPublishData:assetArray byPhoto:photoArray byPublishType:selectPublishTypeEnum];
    };
    XTCBaseNavigationController *pickerNav = [[XTCBaseNavigationController alloc] initWithRootViewController:publishPickerVC];
    pickerNav.transitioningDelegate = self;
    [self presentViewController:pickerNav animated:YES completion:^{
        
    }];
    if ([[GlobalData sharedInstance].userModel.level intValue] >= 4) {
        // 获取今天发布过商业帖子链接
        XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
        requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
        requestModel.token = [GlobalData sharedInstance].userModel.token;
        // 未完待续
        /*
         [[RSNetworkingManager shareRequestConnect] networkingCommonByRequestEnum:RequestCheckartlinkEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
         
         }];
         */
    } else {
        
    }
}

- (void)cancelFullScreenGes {
    
}


#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_publishNormalPostModel) {
        // 为标题 搜搜 日期 正文
        // 尾部小标题 尾部描述
        // tag
        return 3+_sourceModelArray.count;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else {
        if (section == _sourceModelArray.count+1) {
            // 尾部标题和描述
            if (_publishTypeEnum == PublishPhotoTypeEnum || _publishTypeEnum == PublishPhotoVideoTypeEnum) {
                return 2;
            } else {
                return 0;
            }
        } else if (section == _sourceModelArray.count+2) {
            // tag
            return 1;
        } else {
            if (_publishTypeEnum == PublishPhotoTypeEnum || _publishTypeEnum == PublishPhotoVideoTypeEnum) {
                return 3;
            } else {
                return 1;
            }
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                static NSString *cellName = @"XTCPublishTitleCellName";
                XTCPublishTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[XTCPublishTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (_publishNormalPostModel.posttitle && _publishNormalPostModel.posttitle.length) {
                    cell.defaultLabel.hidden = YES;
                } else {
                    cell.defaultLabel.hidden = NO;
                }
                cell.titleTextView.tag = 100;
                cell.titleTextView.text = _publishNormalPostModel.posttitle;
                cell.titleTextView.returnKeyType = UIReturnKeyDone;
                cell.titleTextView.delegate = self;
                if (self.publishTypeEnum == PublishVideoTypeEnum) {
                    cell.recordAudioButton.hidden = YES;
                } else {
                    cell.recordAudioButton.hidden = NO;
                }
                [cell.recordAudioButton addTarget:self action:@selector(recordAudioButtonClick) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
                break;
            case 1: {
                static NSString *cellName = @"XTCPublishSearchLinkCellName";
                XTCPublishSearchLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[XTCPublishSearchLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                [cell.searchLinkButton addTarget:self action:@selector(addLinkButtonClick) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case 2: {
                static NSString *cellName = @"NewPublishPostAboutCellName";
                NewPublishPostAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[NewPublishPostAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.timeLabel.text = _publishNormalPostModel.dateString;
                cell.cityLabel.text = _postShowCity;
                if (_postShowCity && _postShowCity.length) {
                    cell.localImageView.hidden = NO;
                } else {
                    cell.localImageView.hidden = YES;
                }
                if (_countryCode && _countryCode.length) {
                    cell.countryImageView.hidden = NO;
                    cell.countryImageView.image = [UIImage imageNamed:_countryCode];
                } else {
                    cell.countryImageView.hidden = YES;
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case 3: {
                static NSString *cellName = @"NewPublishDescCellName";
                NewPublishDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[NewPublishDescCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.defaultLabel.text = @"请输入正文";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.postDescTextView.delegate = self;
                cell.postDescTextView.tag = 200;
                cell.postDescTextView.text = _publishNormalPostModel.postcontent;
                if (_publishNormalPostModel.postcontent && _publishNormalPostModel.postcontent.length) {
                    cell.defaultLabel.hidden = YES;
                } else {
                    cell.defaultLabel.hidden = NO;
                }
                cell.postDescTextView.delegate = self;
                return cell;
            }
                break;
                
                
            default:
                break;
        }
    } else if (indexPath.section == _sourceModelArray.count+1) {
        // 尾部标题和描述
        static NSString *cellName = @"NewPublishDescCellName";
        NewPublishDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[NewPublishDescCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        if (indexPath.row == 0) {
            cell.defaultLabel.text = @"小标题";
            cell.postDescTextView.tag = 501;
            cell.postDescTextView.text = _publishNormalPostModel.endTitle;
            if (_publishNormalPostModel.endTitle && _publishNormalPostModel.endTitle.length) {
                cell.defaultLabel.hidden = YES;
            } else {
                cell.defaultLabel.hidden = NO;
            }
            cell.postDescTextView.returnKeyType = UIReturnKeyDone;
        } else {
            cell.postDescTextView.tag = 502;
            cell.defaultLabel.text = @"结语";
            cell.postDescTextView.text = _publishNormalPostModel.endDesc;
            if (_publishNormalPostModel.endDesc && _publishNormalPostModel.endDesc.length) {
                cell.defaultLabel.hidden = YES;
            } else {
                cell.defaultLabel.hidden = NO;
            }
            cell.postDescTextView.returnKeyType = UIReturnKeyDefault;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.postDescTextView.delegate = self;
        return cell;
    } else if (indexPath.section == _sourceModelArray.count+2) {
        // tag部分
        static NSString *cellName = @"NewPublishTagCellName";
        NewPublishTagCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[NewPublishTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.backgroundColor = [UIColor clearColor];
        if (_publishNormalPostModel.tags && _publishNormalPostModel.tags.length) {
            NSArray *tagArray = [_publishNormalPostModel.tags componentsSeparatedByString:@","];
            [cell loadTagData:tagArray];
        } else {
            [cell loadTagData:@[]];
        }
        return cell;
    } else {
        PublishSourceModel *flagSource = _sourceModelArray[indexPath.section-1];
        if (_publishTypeEnum == PublishPhotoTypeEnum || _publishTypeEnum == PublishPhotoVideoTypeEnum) {
            if (indexPath.row == 2) {
                
            } else {
                static NSString *cellName = @"NewPublishDescCellName";
                NewPublishDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[NewPublishDescCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                if (indexPath.row == 0) {
                    cell.defaultLabel.text = @"小标题";
                    cell.postDescTextView.tag = 300 + indexPath.section;
                    cell.postDescTextView.text = flagSource.sourceTitle;
                    if (flagSource.sourceTitle && flagSource.sourceTitle.length) {
                        cell.defaultLabel.hidden = YES;
                    } else {
                        cell.defaultLabel.hidden = NO;
                    }
                    cell.postDescTextView.returnKeyType = UIReturnKeyDone;
                } else {
                    cell.postDescTextView.tag = 400 + indexPath.section;
                    cell.defaultLabel.text = @"描述";
                    cell.postDescTextView.text = flagSource.sourceDesc;
                    if (flagSource.sourceDesc && flagSource.sourceDesc.length) {
                        cell.defaultLabel.hidden = YES;
                    } else {
                        cell.defaultLabel.hidden = NO;
                    }
                    cell.postDescTextView.returnKeyType = UIReturnKeyDefault;
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.postDescTextView.delegate = self;
                return cell;
            }
        } else {
            
        }
        static NSString *cellName = @"XTCPublishShowSourceCellName";
        XTCPublishShowSourceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[XTCPublishShowSourceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.deleteButton.tag = indexPath.section-1;
        [cell.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger w = flagSource.phAsset.pixelWidth;
        NSInteger h = flagSource.phAsset.pixelHeight;
        if (w <= 0) {
            w = kScreenWidth - 30;
        }
        if (h <= 0) {
            h = 0.5*kScreenWidth;
        }
        
        CGFloat width = kScreenWidth - 30;
        if (h > w) {
            width = kScreenWidth - kScreenWidth * 0.3;
        }
        cell.widthLayoutConstraint.constant = width;
        cell.heightLayoutConstraint.constant = 1.0*h/w * width;
        cell.showImageView.image = flagSource.sourceImage;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (flagSource.fileTypeEnum == PublishSourceFileVideoTypeEnum) {
            if (_isPlayVideo) {
                cell.playVideoButton.hidden = YES;
                cell.videoBgView.hidden = NO;
            } else {
                cell.playVideoButton.hidden = NO;
                cell.videoBgView.hidden = YES;
            }
        } else {
            cell.playVideoButton.hidden = YES;
            cell.videoBgView.hidden = YES;
            cell.showImageButton.tag = indexPath.section-1;
            [cell.showImageButton addTarget:self action:@selector(showImageButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.playVideoButton.tag = indexPath.section-1;
        [cell.playVideoButton addTarget:self action:@selector(playPostVideo:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor whiteColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 0;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                if (_publishNormalPostModel.posttitle && _publishNormalPostModel.posttitle.length) {
                    CGRect rect = [_publishNormalPostModel.posttitle boundingRectWithSize:CGSizeMake(kScreenWidth-35-100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:21]} context:nil];
                    if (rect.size.height + 20 < 35) {
                        rowHeight = 60;
                    } else {
                        rowHeight = rect.size.height+20+20;
                    }
                    
                } else {
                    rowHeight = 60;
                }
                break;
            case 1: {
                rowHeight = 40.0f;
            }
                break;
            case 2:
                rowHeight = 30;
                break;
            case 3: {
                if (_publishNormalPostModel.postcontent && _publishNormalPostModel.postcontent.length) {
                    CGRect rect = [_publishNormalPostModel.postcontent boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
                    if (rect.size.height + 20 < 50) {
                        rowHeight = 50;
                    } else {
                        rowHeight = rect.size.height+20;
                    }
                    
                } else {
                    rowHeight = 50;
                }
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == _sourceModelArray.count+1)  {
        if (indexPath.row == 0) {
            if (_publishNormalPostModel.endTitle && _publishNormalPostModel.endTitle.length) {
                CGRect rect = [_publishNormalPostModel.endTitle boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
                if (rect.size.height + 20 < 40) {
                    rowHeight = 40;
                } else {
                    rowHeight = rect.size.height + 20;
                }
                
            } else {
                rowHeight = 40;
            }
        } else {
            if (_publishNormalPostModel.endDesc && _publishNormalPostModel.endDesc.length) {
                CGRect rect = [_publishNormalPostModel.endDesc boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
                if (rect.size.height + 20 < 40) {
                    rowHeight = 40;
                } else {
                    rowHeight = rect.size.height + 20;
                }
                
            } else {
                rowHeight = 40;
            }
        }
    } else if (indexPath.section == _sourceModelArray.count+2) {
        NSArray *tagArray = [_publishNormalPostModel.tags componentsSeparatedByString:@","];
        if (tagArray.count) {
            if (83 *tagArray.count + 50 > kScreenWidth) {
                rowHeight = 70.0f;
            } else {
                rowHeight = 50.0f;
            }
        } else {
            rowHeight = 20.0f;
        }
    } else {
        if (_publishTypeEnum == PublishPhotoTypeEnum || _publishTypeEnum == PublishPhotoVideoTypeEnum) {
            if (indexPath.row == 0) {
                PublishSourceModel *flagSource = _sourceModelArray[indexPath.section-1];
                if (flagSource.sourceTitle && flagSource.sourceTitle.length) {
                    CGRect rect = [flagSource.sourceTitle boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
                    if (rect.size.height + 20 < 40) {
                        rowHeight = 40;
                    } else {
                        rowHeight = rect.size.height + 20;
                    }
                    
                } else {
                    rowHeight = 40;
                }
            } else if (indexPath.row == 1) {
                PublishSourceModel *flagSource = _sourceModelArray[indexPath.section-1];
                if (flagSource.sourceDesc && flagSource.sourceDesc.length) {
                    CGRect rect = [flagSource.sourceDesc boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
                    if (rect.size.height + 20 < 40) {
                        rowHeight = 40;
                    } else {
                        rowHeight = rect.size.height + 20;
                    }
                    
                } else {
                    rowHeight = 40;
                }
            } else {
                PublishSourceModel *flagSource = _sourceModelArray[indexPath.section-1];
                NSInteger w = flagSource.phAsset.pixelWidth;
                NSInteger h = flagSource.phAsset.pixelHeight;
                if (w <= 0) {
                    w = kScreenWidth - 30;
                }
                if (h <= 0) {
                    h = 0.5*kScreenWidth;
                }
                
                CGFloat width = kScreenWidth - 30;
                if (h > w) {
                    width = kScreenWidth - kScreenWidth * 0.3;
                }
                rowHeight = 1.0*h/w * width + 20; // 20为缝隙
            }
        } else {
            PublishSourceModel *flagSource = _sourceModelArray[indexPath.section-1];
            NSInteger w = flagSource.phAsset.pixelWidth;
            NSInteger h = flagSource.phAsset.pixelHeight;
            if (w <= 0) {
                w = kScreenWidth - 30;
            }
            if (h <= 0) {
                h = 0.5*kScreenWidth;
            }
            
            CGFloat width = kScreenWidth - 30;
            if (h > w) {
                width = kScreenWidth - kScreenWidth * 0.3;
            }
            rowHeight = 1.0*h/w * width + 20; // 20为缝隙
        }
    }
    return rowHeight;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)loadPublishData:(NSMutableArray *)sourceAssetArray byPhoto:(NSMutableArray *)sourcePhotoArray byPublishType:(SelectPublishTypeEnum)selectPublishTypeEnum {
    if (selectPublishTypeEnum == SelectPublishTypeVideoEnum || selectPublishTypeEnum == SelectPublishTypeProEnum) {
        PHAsset *flagAsset = sourceAssetArray.firstObject;
        BOOL isNeedLoadVideo = YES; // 选择同一视频不需要重新压缩载入
        for (PublishSourceModel *oldNewSourceModel in _sourceModelArray) {
            if (oldNewSourceModel.fileTypeEnum == PublishSourceFileVideoTypeEnum) {
                if ([flagAsset.localIdentifier isEqualToString:oldNewSourceModel.phAsset.localIdentifier]) {
                    isNeedLoadVideo = NO;
                    break;
                } else {
                    
                }
            } else {
                
            }
        }
        if (isNeedLoadVideo) {
            [self didFinishPickingVideoBySourceAssets:sourceAssetArray.firstObject byPublishType:selectPublishTypeEnum];
        } else {
            
        }
    } else {
        BOOL havePhoto = NO;
        BOOL haveVideo = NO;
        PublishSourceModel *flagVideoSource;
        for (PublishSourceModel *oldNewSourceModel in _sourceModelArray) {
            if (oldNewSourceModel.fileTypeEnum == PublishSourceFileVideoTypeEnum) {
                flagVideoSource = oldNewSourceModel;
            } else {
                
            }
        }
        // 新的资源图片数组
        NSMutableArray *flagSourceArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < sourceAssetArray.count; i++) {
            PHAsset *flagAsset = sourceAssetArray[i];
            if (flagAsset.mediaType == PHAssetMediaTypeVideo) {
                [flagSourceArray addObject:flagVideoSource];
                haveVideo = YES;
            } else {
                havePhoto = YES;
                PublishSourceModel *publishSourceModel = [[PublishSourceModel alloc] init];
                publishSourceModel.phAsset = flagAsset;
                publishSourceModel.sourceImage = sourcePhotoArray[i];
                publishSourceModel.fileTypeEnum = PublishSourceFilePhotoTypeEnum;
                [flagSourceArray addObject:publishSourceModel];
            }
        }
        _publishTypeEnum = PublishPhotoTypeEnum;
        for (PublishSourceModel *newSourceModel in flagSourceArray) {
            for (PublishSourceModel *oldNewSourceModel in _sourceModelArray) {
                if (oldNewSourceModel.fileTypeEnum == PublishSourceFilePhotoTypeEnum) {
                    if ([oldNewSourceModel.phAsset.localIdentifier isEqualToString:newSourceModel.phAsset.localIdentifier]) {
                        newSourceModel.sourceDesc = oldNewSourceModel.sourceDesc;
                        newSourceModel.sourceTitle = oldNewSourceModel.sourceTitle;
                        break;
                    } else {
                        
                    }
                } else {
                    
                }
                
            }
        }
        _sourceModelArray = flagSourceArray;
        if (selectPublishTypeEnum == SelectPublishType720VREnum) {
            _publishTypeEnum = PublishVRTypeEnum;
        } else {
            if (havePhoto && haveVideo) {
                _publishTypeEnum = PublishPhotoVideoTypeEnum;
            } else {
                if (havePhoto) {
                    _publishTypeEnum = PublishPhotoTypeEnum;
                }
                if (haveVideo) {
                    _publishTypeEnum = PublishVideoTypeEnum;
                }
            }
        }
        if (_sourceModelArray.count > 1) {
            self.sortButton.hidden = NO;
        } else {
            self.sortButton.hidden = YES;
        }
        [self gainTourTime];
        [_publishTableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self gainPostCityAboutInfor];
        });
    }
}


#pragma mark - 获取视频
- (void)didFinishPickingVideoBySourceAssets:(PHAsset *)asset byPublishType:(SelectPublishTypeEnum)selectPublishTypeEnum {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHubWithDescription:@"视频渲染中..."];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setNeedsStatusBarAppearanceUpdate];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.selectVideoPHAsset = asset;
        // 先获取视频的相关信息
        PublishSourceModel *publishSourceModel = [[PublishSourceModel alloc] init];
        publishSourceModel.phAsset = asset;
        publishSourceModel.fileTypeEnum = PublishSourceFileVideoTypeEnum;
        NSString *videoLngString = @"";
        NSString *videoLatString = @"";
        if (weakSelf.selectVideoPHAsset.location) {
            videoLngString = [NSString stringWithFormat:@"%lf", weakSelf.selectVideoPHAsset.location.coordinate.longitude];
            videoLatString = [NSString stringWithFormat:@"%lf", weakSelf.selectVideoPHAsset.location.coordinate.latitude];
        }
        
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = true;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:self.selectVideoPHAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            // 设备品牌
            NSArray *makeArray = [AVMetadataItem metadataItemsFromArray:flagAsset.commonMetadata
                                                                withKey:AVMetadataCommonKeyMake
                                                               keySpace:AVMetadataKeySpaceCommon];
            for (AVMetadataItem *item in makeArray) {
                if (item.value) {
                    publishSourceModel.make = (NSString *)item.value;
                } else {
                    
                }
            }
            // 设备型号
            NSArray *modelArray = [AVMetadataItem metadataItemsFromArray:flagAsset.commonMetadata
                                                                 withKey:AVMetadataCommonKeyModel
                                                                keySpace:AVMetadataKeySpaceCommon];
            for (AVMetadataItem *item in modelArray) {
                if (item.value) {
                    publishSourceModel.model = (NSString *)item.value;
                } else {
                    
                }
            }
            // 拍摄时间
            NSDate *createDate = weakSelf.selectVideoPHAsset.creationDate;
            NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
            NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
            NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:createDate];
            NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:createDate];
            NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
            NSDate *destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:createDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timeString = [dateFormatter stringFromDate:destinationDateNow];//转为字符型
            publishSourceModel.dateTimeOriginal = timeString;
            
            // VIP可以发布120s视频 其他用户可以发布60s的视频
            if (([[GlobalData sharedInstance].userModel.level intValue] < 4 && weakSelf.selectVideoPHAsset.duration > 60) || ([[GlobalData sharedInstance].userModel.level intValue] > 4 && weakSelf.selectVideoPHAsset.duration > 120)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideHub];
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishVideoTrimmer" bundle:nil];
                    PublishVideoTrimmerViewController *publishVideoTrimmerVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishVideoTrimmerViewController"];
                    publishVideoTrimmerVC.phAsset = weakSelf.selectVideoPHAsset;
                    publishVideoTrimmerVC.videoDateStr = self.audioDateString;
                    publishVideoTrimmerVC.trimmerVideoCallBack = ^(BOOL isSuccess) {
                        if (isSuccess) {
                            NSString *videoOutputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                            videoOutputURL =  [NSString stringWithFormat:@"%@/%@_video.mp4", videoOutputURL, weakSelf.audioDateString];
                            UIImage *corverImg = [weakSelf thumbnailImageFromURL:[NSURL fileURLWithPath:videoOutputURL]];
                            publishSourceModel.filePath = videoOutputURL;
                            publishSourceModel.sourceImage = corverImg;
                            [weakSelf checkPublishType:publishSourceModel];
                        } else {
                            
                        }
                    };
                    [self.navigationController pushViewController:publishVideoTrimmerVC animated:YES];
                });
            } else {
                weakSelf.selectVideoAsset = flagAsset;
                
                if (selectPublishTypeEnum == SelectPublishTypeProEnum) {
                    // Pro发布
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideHub];
                        PublishProVideoViewController *publishProVC = [[UIStoryboard storyboardWithName:@"PublishPro" bundle:nil] instantiateViewControllerWithIdentifier:@"PublishProVideoViewController"];
                        publishProVC.interactivePostId = self.interactivePostId;
                        //                        publishProVC.videoCorverImage = coverImage;
                        publishProVC.videoAsset = self.selectVideoPHAsset;
                        publishProVC.chatType = self.chatType;
                        publishProVC.chatId = self.chatId;
                        publishProVC.tk = self.tk;
                        if (self.publishContentEnum == PublishRoadBookEnum) {
                            publishProVC.isPublishRoadBook = YES;
                        } else {
                            publishProVC.isPublishRoadBook = NO;
                        }
                        
                        [self.navigationController pushViewController:publishProVC animated:YES];
                    });
                } else {
                    BOOL isNeeddCom = YES;
                    if ([flagAsset isKindOfClass:[AVComposition class]]) {
                        
                    } else {
                        AVURLAsset* avUrlAsset = (AVURLAsset*)flagAsset;
                        NSNumber *size;
                        [avUrlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                        if ([size floatValue]/1024.0/self.selectVideoPHAsset.duration < kSizeMaxSecond) {
                            isNeeddCom = NO;
                        } else {
                            isNeeddCom = YES;
                        }
                    }
                    NSString *videoOutputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    videoOutputURL =  [NSString stringWithFormat:@"%@/%@_video.mp4", videoOutputURL, self.audioDateString];
                    @try {
                        [[NSFileManager defaultManager] removeItemAtPath:videoOutputURL error:nil];
                    } @catch(NSException *exception) {
                        
                    }
                    if (isNeeddCom) {
                        // 视频码率压缩部分
                        weakSelf.encoder = [SDAVAssetExportSession.alloc initWithAsset:self->_selectVideoAsset];
                        NSURL * url = [NSURL fileURLWithPath:videoOutputURL];
                        weakSelf.encoder.outputURL = url;
                        weakSelf.encoder.outputFileType = AVFileTypeMPEG4;
                        weakSelf.encoder.shouldOptimizeForNetworkUse = YES;
                        NSInteger flagWidth = weakSelf.selectVideoPHAsset.pixelWidth;
                        NSInteger flagHeight = weakSelf.selectVideoPHAsset.pixelHeight;
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
                        NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @((isHightVideo?kVideoHighBitRateKey:kVideoBitRateKey)*1024),
                                                                 AVVideoExpectedSourceFrameRateKey : @(30),
                                                                 AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel };
                        //视频属性
                        weakSelf.encoder.videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                                            AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                                            AVVideoWidthKey : @(flagWidth),
                                                            AVVideoHeightKey : @(flagHeight),
                                                            AVVideoCompressionPropertiesKey : compressionProperties };
                        
                        
                        // 音频设置
                        weakSelf.encoder.audioSettings = @{ AVEncoderBitRatePerChannelKey : @(60000),
                                                            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                            AVNumberOfChannelsKey : @(2),
                                                            AVSampleRateKey : @(44100) };
                        
                        [weakSelf.encoder exportAsynchronouslyWithCompletionHandler:^ {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf hideHub];
                            });
                            int status = weakSelf.encoder.status;
                            
                            if (status == AVAssetExportSessionStatusCompleted) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf hideHub];
                                    UIImage *corverImg = [weakSelf thumbnailImageFromURL:[NSURL fileURLWithPath:videoOutputURL]];
                                    publishSourceModel.filePath = videoOutputURL;
                                    publishSourceModel.sourceImage = corverImg;
                                    [weakSelf checkPublishType:publishSourceModel];
                                    [weakSelf gainPostCityAboutInfor];
                                });
                            } else if (status == AVAssetExportSessionStatusCancelled) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf alertMessage:@"渲染失败"];
                                });
                            }else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf alertMessage:@"渲染失败"];
                                });
                            }
                        }];
                    } else {
                        // 直接导出
                        AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:self->_selectVideoAsset presetName:AVAssetExportPresetHighestQuality];
                        exportSession.shouldOptimizeForNetworkUse = YES;
                        exportSession.outputURL = [NSURL fileURLWithPath:videoOutputURL];
                        exportSession.outputFileType = AVFileTypeMPEG4;
                        [exportSession exportAsynchronouslyWithCompletionHandler:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self hideHub];
                            });
                            int exportStatus = exportSession.status;
                            switch (exportStatus)
                            {
                                case AVAssetExportSessionStatusFailed:
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self alertMessage:@"渲染失败"];
                                    });
                                    break;
                                }
                                case AVAssetExportSessionStatusCompleted:
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIImage *corverImg = [weakSelf thumbnailImageFromURL:[NSURL fileURLWithPath:videoOutputURL]];
                                        publishSourceModel.filePath = videoOutputURL;
                                        publishSourceModel.sourceImage = corverImg;
                                        [weakSelf checkPublishType:publishSourceModel];
                                        [weakSelf gainPostCityAboutInfor];
                                    });
                                    break;
                                }
                            }
                        }];
                    }
                }
            }
        }];
    });
}

#pragma mark - 检测发布类型
- (void)checkPublishType:(PublishSourceModel *)publishSourceModel {
    self.publishTypeEnum = PublishVideoTypeEnum;
    for (int i = 0; i < self.sourceModelArray.count; i++) {
        PublishSourceModel *oldNewSourceModel = self.sourceModelArray[i];
        if (oldNewSourceModel.fileTypeEnum == PublishSourceFilePhotoTypeEnum) {
            self.publishTypeEnum = PublishPhotoVideoTypeEnum;
        } else {
            [self.sourceModelArray replaceObjectAtIndex:i withObject:publishSourceModel];
        }
    }
    BOOL isHaveVideo = NO;
    for (PublishSourceModel *oldNewSourceModel in self.sourceModelArray) {
        if (oldNewSourceModel.fileTypeEnum == PublishSourceFileVideoTypeEnum) {
            isHaveVideo = YES;
        } else {
            
        }
    }
    if (isHaveVideo) {
        
    } else {
        [self.sourceModelArray addObject:publishSourceModel];
    }
    
    [self gainTourTime];
    
    // 获取旅行时间
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publishTableView reloadData];
    });
}

- (void)gainTourTime {
    if (self.sourceModelArray.count) {
        PublishSourceModel *sourceModel = self.sourceModelArray.firstObject;
        if (sourceModel.phAsset.creationDate) {
            _publishNormalPostModel.tourTime = [self getNowTimestamp:sourceModel.phAsset.creationDate];
        } else {
            _publishNormalPostModel.tourTime = @"";
        }
    } else {
        _publishNormalPostModel.tourTime = @"";
    }
}


#pragma mark - 获取视频截图
- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CGImageRef imgRef = nil;
    UIImage *flagImage = nil;
    CMTime requestedTime = (_selectVideoPHAsset.duration > 2) ? CMTimeMakeWithSeconds(2, 30) : CMTimeMake(1, 60);
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    flagImage = [UIImage imageWithCGImage:imgRef];
    return flagImage;
}

#pragma mark - 展示所选照片或视频
- (void)showImageButton:(UIButton *)showButton {
    __weak typeof(self) weakSelf = self;
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [photoBrowser setCurrentPhotoIndex:showButton.tag];
    photoBrowser.autoPlayOnAppear = false;
    photoBrowser.displayActionButton = false;
    photoBrowser.isEdit = true;
    photoBrowser.postUserId = [GlobalData sharedInstance].userModel.user_id;
    photoBrowser.imageDescArrayCallback = ^(NSMutableArray *descArray) {
        weakSelf.sourceModelArray = descArray;
    };
    photoBrowser.publishSourceModelArray = _sourceModelArray;
    photoBrowser.imageArrayDeleteCallback = ^(NSInteger selectIndex) {
        [weakSelf.sourceModelArray removeObjectAtIndex:selectIndex];
        [weakSelf.publishTableView reloadData];
        BOOL isHavePhoto = NO;
        BOOL isHaveVideo = NO;
        for (PublishSourceModel *sourceModel in weakSelf.sourceModelArray) {
            if (sourceModel.fileTypeEnum == PublishSourceFilePhotoTypeEnum) {
                isHavePhoto = YES;
            } else {
                isHaveVideo = YES;
            }
        }
        if (weakSelf.publishTypeEnum == PublishVRTypeEnum) {
            
        } else {
            if (isHavePhoto && isHaveVideo) {
                weakSelf.publishTypeEnum = PublishPhotoVideoTypeEnum;
            } else {
                if (isHaveVideo) {
                    weakSelf.publishTypeEnum = PublishVideoTypeEnum;
                } else {
                    weakSelf.publishTypeEnum = PublishPhotoTypeEnum;
                }
            }
        }
        [weakSelf gainPostCityAboutInfor];
    };
    [StaticCommonUtil app].allowRotation = YES;
    XTCBaseNavigationController *navVC = [[XTCBaseNavigationController alloc] initWithRootViewController:photoBrowser];
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

#pragma mark - MWPhotoBrower delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _sourceModelArray.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    PublishSourceModel *sourceModel = _sourceModelArray[index];
    MWPhoto *photo;
    if (sourceModel.fileTypeEnum == PublishSourceFilePhotoTypeEnum) {
        photo = [[MWPhoto alloc] initWithImage:sourceModel.sourceImage];
    } else {
        photo = [[MWPhoto alloc] initWithImage:sourceModel.sourceImage];
        photo.videoURL = [NSURL fileURLWithPath:sourceModel.filePath];
    }
    
    return photo;
}

#pragma mark - 视频播放
- (void)playPostVideo:(UIButton *)playVideoButton {
    __weak typeof(self) weakSelf = self;
    _isPlayVideo = YES;
    PublishSourceModel *flagSource = _sourceModelArray[playVideoButton.tag];
    if (_publishTypeEnum == PublishVideoTypeEnum) {
        _videoCell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:playVideoButton.tag+1]];
    } else {
        _videoCell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:playVideoButton.tag+1]];
    }
    
    _videoCell.videoBgView.hidden = NO;
    _videoCell.playVideoButton.hidden = YES;
    [_videoCell.videoBgView jp_playVideoWithURL:[NSURL fileURLWithPath:flagSource.filePath]
                             bufferingIndicator:nil controlView:nil progressView:nil configurationCompletion:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                 if (flagSource.phAsset.pixelWidth > flagSource.phAsset.pixelHeight) {
                                     //                                    [weakSelf.videoCell.videoBgView jp_gotoLandscape:YES];
                                 } else {
                                     weakSelf.isVerticalPlay = YES;
                                     [weakSelf.videoCell.videoBgView jp_gotoLandscape:NO byDeviceOrientation:UIInterfaceOrientationPortrait];
                                     //                                     [weakSelf.videoCell.videoBgView jp_gotoLandscape:NO];
                                 }
                             }];
}

- (void)videoPlayFinish {
    _isPlayVideo = NO;
    if (_videoCell) {
        [_videoCell.videoBgView jp_gotoPortrait];
        [_videoCell.videoBgView jp_stopPlay];
        _videoCell.videoBgView.hidden = YES;
        _videoCell.playVideoButton.hidden = NO;
    }
}


#pragma mark - 获取帖子定位城市
- (void)gainPostCityAboutInfor {
    [self showHubWithDescription:@"地图信息获取中"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *locationArray = [[NSMutableArray alloc] init];
        for (PublishSourceModel *flagSource in self.sourceModelArray) {
            if (flagSource.phAsset.location) {
                flagSource.latStr = [NSString stringWithFormat:@"%.8f", flagSource.phAsset.location.coordinate.latitude];
                flagSource.lngStr = [NSString stringWithFormat:@"%.8f", flagSource.phAsset.location.coordinate.longitude];
                [locationArray addObject:flagSource.phAsset.location];
            } else {
                
            }
        }
        CLLocation *firstLocation;
        if (locationArray.count) {
            firstLocation = locationArray.firstObject;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHub];
            if (locationArray.count && [self.publishNormalPostModel.share_location isEqualToString:@"Y"]) {
                if (kDevice_Is_iPhoneX) {
                    self.publishTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
                } else {
                    self.publishTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 130)];
                }
                if (self.postDetailMapView == nil) {
                    if (kDevice_Is_iPhoneX) {
                        self.postDetailMapView = [[XTCMapView alloc] initWithFrame:CGRectMake(0, -self.publishTableView.contentOffset.y, kScreenWidth, 150)];
                    } else {
                        self.postDetailMapView = [[XTCMapView alloc] initWithFrame:CGRectMake(0, -self.publishTableView.contentOffset.y, kScreenWidth, 130)];
                    }
                    self.postDetailMapView.showsUserLocation = NO;
                    self.postDetailMapView.delegate = self;
                    self.postDetailMapView.userTrackingMode = MAUserTrackingModeNone;
                    self.postDetailMapView.showsCompass = NO;
                    self.postDetailMapView.showsScale = NO;
                    self.postDetailMapView.maxZoomLevel = 17;
                    self.postDetailMapView.showsWorldMap = [NSNumber numberWithInt:1];
                    // 自定义地图样式
                    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
                    [self.postDetailMapView setCustomMapStyleWithWebData:data];
                    [self.postDetailMapView setCustomMapStyleEnabled:YES];
                    [self.view addSubview:self.postDetailMapView];
                } else {
                    
                }
                [self.postDetailMapView removeAnnotations:self.postDetailMapView.annotations];
                for (CLLocation *flagLocation in locationArray) {
                    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(flagLocation.coordinate.latitude, flagLocation.coordinate.longitude);
                    if (![TQLocationConverter isLocationOutOfChina:locationCoordinate]) {
                        locationCoordinate = [TQLocationConverter transformFromWGSToGCJ:locationCoordinate];
                        
                    } else {
                        
                    }
                    XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
                    pointAnnotation.coordinate = locationCoordinate;
                    pointAnnotation.title = @"";
                    pointAnnotation.subtitle = @"";
                    [self.postDetailMapView addAnnotation:pointAnnotation];
                }
                if (self.postDetailMapView.annotations.count == 1) {
                    XTCPointAnnotation *pointAnnotation = self.postDetailMapView.annotations.firstObject;
                    [self.postDetailMapView showAnnotations:self.postDetailMapView.annotations animated:NO];
                    [self.postDetailMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:12 animated:NO];
                    
                } else {
                    if ([self checkCoordinateSame]) {
                        XTCPointAnnotation *pointAnnotation = self.postDetailMapView.annotations.firstObject;
                        [self.postDetailMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:12 animated:NO];
                        [self.postDetailMapView showAnnotations:self.postDetailMapView.annotations animated:NO];
                    } else {
                        [self.postDetailMapView showAnnotations:self.postDetailMapView.annotations animated:NO];
                    }
                    
                }
            } else {
                self.publishTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kAppStatusBar)];
                [self.postDetailMapView removeFromSuperview];
                self.postDetailMapView = nil;
            }
            if (firstLocation) {
                self.search = [[AMapSearchAPI alloc] init];
                self.search.delegate = self;
                self.search.language = AMapSearchLanguageZhCN;
                
                AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
                
                regeo.location = [AMapGeoPoint locationWithLatitude:firstLocation.coordinate.latitude longitude:firstLocation.coordinate.longitude];
                regeo.requireExtension = YES;
                [self.search AMapReGoecodeSearch:regeo];
            } else {
                self.postShowCity = @"";
                self.countryCode = @"";
            }
        });
    });
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        NSString *cityStr = response.regeocode.addressComponent.city;
        self.postShowCity = cityStr;
        
        NSString *countryStr = response.regeocode.addressComponent.country;
        if ([countryStr isEqualToString:@"中国"]) {
            self.countryCode = @"";
        } else {
            NSArray *flagDictArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"country_area" ofType:@"plist"]];
            for (NSDictionary *flagDict in flagDictArray) {
                NSString *name = flagDict[@"nmae"];
                if ([name isEqualToString:countryStr]) {
                    int flagNo = [flagDict[@"flag_no"] intValue]+1000;
                    self.countryCode = [NSString stringWithFormat:@"%d", flagNo];
                    break;
                } else {
                    
                }
            }
        }
        [_publishTableView reloadData];
    }
    
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    DDLogInfo(@"获取地理信息失败了");
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

#pragma mark - 大头针显示
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[XTCPointAnnotation class]])
    {
        NSString * reusedId = @"NormalAnnotation";
        CustomAnnotationView *newAnnotation = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedId];
        if (!newAnnotation) {
            newAnnotation = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedId];
        }
        newAnnotation.portraitImageView.image = [UIImage imageNamed:@"imageIcon"];
        newAnnotation.isCanCallout = NO;
        return newAnnotation;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self presentMapVC];
}


- (NSString *)getNowTimestamp:(NSDate *)createDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSInteger timeSp = [[NSNumber numberWithDouble:[createDate timeIntervalSince1970]] integerValue];
    NSString *timeSpStr = [NSString stringWithFormat:@"%ld", (long)timeSp];
    return timeSpStr;
}

#pragma mark - 添加网址
- (void)addLinkButtonClick {
    __weak typeof(self) weakSelf = self;
    if ([[GlobalData sharedInstance].userModel.level intValue] >= 4) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishLinkUrl" bundle:nil];
        PublishLinkUrlViewController *publishLinkUrlVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishLinkUrlViewController"];
        publishLinkUrlVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        publishLinkUrlVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        if ([GlobalData sharedInstance].art_link && [GlobalData sharedInstance].art_link.length) {
            publishLinkUrlVC.urlTextView.editable = NO;
            publishLinkUrlVC.defaultLabel.hidden = YES;
        } else {
            publishLinkUrlVC.urlTextView.editable = YES;
        }
        if (_publishNormalPostModel.art_link && _publishNormalPostModel.art_link.length) {
            publishLinkUrlVC.defaultLabel.hidden = YES;
        } else {
            publishLinkUrlVC.defaultLabel.hidden = NO;
        }
        publishLinkUrlVC.verifyFinish = _publishNormalPostModel.artLinkVerifyFinish;
        if (publishLinkUrlVC.verifyFinish) {
            [publishLinkUrlVC.showWebLinkButton setTitle:@"确定" forState:UIControlStateNormal];
            [publishLinkUrlVC.showWebLinkButton setTitleColor:publishLinkUrlVC.giveUpButton.titleLabel.textColor forState:UIControlStateNormal];
        } else {
            [publishLinkUrlVC.showWebLinkButton setTitle:@"验证网站" forState:UIControlStateNormal];
            [publishLinkUrlVC.showWebLinkButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        publishLinkUrlVC.urlTextView.text = _publishNormalPostModel.art_link;
        publishLinkUrlVC.linkUrlCallabck = ^(NSString *linkUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
                weakSelf.publishNormalPostModel.art_link = linkUrl;
                weakSelf.publishNormalPostModel.artLinkVerifyFinish = YES;
                [weakSelf.publishTableView reloadData];
            });
        };
        [self presentViewController:publishLinkUrlVC animated:YES completion:^{
            
        }];
    } else {
        CommonWebViewViewController *commonWebView = [[CommonWebViewViewController alloc] init];
        commonWebView.titleString = @"了解服务号";
        commonWebView.urlString = @"http://show.viewspeaker.com/introduce";
        commonWebView.isPreventPanPop = NO;
        [self.navigationController pushViewController:commonWebView animated:YES];
    }
}

#pragma mark - 录音音频地址
- (NSString *)recordingMp3FilePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [NSString stringWithFormat:@"%@/recoder_%@.mp3", path, _audioDateString];
}

#pragma mark - 录音
- (void)recordAudioButtonClick {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"NewPublishRecordAudio" bundle:nil];
    NewPublishRecordAudioViewController *recordAudioVC = [storyBoard instantiateViewControllerWithIdentifier:@"NewPublishRecordAudioViewController"];
    recordAudioVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    recordAudioVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
    recordAudioVC.audioDatePathStr = _audioDateString;
    recordAudioVC.recoderTime = self.recoderTime;
    recordAudioVC.audioTimeCallabck = ^(int audioTime) {
        weakSelf.recoderTime = audioTime;
    };
    [self presentViewController:recordAudioVC animated:NO completion:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self recordingMp3FilePath]]) {
            recordAudioVC.playStopButton.hidden = NO;
            recordAudioVC.deleteButton.hidden = NO;
            recordAudioVC.recoderWidthLayoutConstraint.constant = self.recoderTime;
            recordAudioVC.recoderTimeLabel.text = [recordAudioVC gainShowTime:self.recoderTime];
        } else {
            recordAudioVC.playStopButton.hidden = YES;
            recordAudioVC.deleteButton.hidden = YES;
        }
    }];
}

#pragma mark - 模态过渡动画
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[PresentTransition alloc] init];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        [self.view endEditing:YES];
    } else {
        
    }
    if (_postDetailMapView) {
        CGFloat mapHeight = kDevice_Is_iPhoneX ? 150 : 130;
        if (self.publishTableView.contentOffset.y > mapHeight) {
            _postDetailMapView.frame = CGRectMake(0, -mapHeight, kScreenWidth, mapHeight);
        } else {
            if (self.publishTableView.contentOffset.y > 0) {
                _postDetailMapView.frame = CGRectMake(0, -self.publishTableView.contentOffset.y, kScreenWidth, mapHeight);
            } else {
                _postDetailMapView.frame = CGRectMake(0, 0, kScreenWidth, mapHeight);
            }
        }
    } else {
        
    }
    
}

#pragma mark - 下拉展示地图
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -80) {
        if (_postDetailMapView && _postDetailMapView.hidden == NO) {
            [self presentMapVC];
        } else {
            
        }
        
    } else {
        
    }
}

#pragma mark - 展示发布的地图详情
- (void)presentMapVC {
    NSMutableArray *gpsSourceArray = [[NSMutableArray alloc] init];
    for (PublishSourceModel *flagSource in _sourceModelArray) {
        if (flagSource.latStr && flagSource.latStr.length && flagSource.lngStr && flagSource.lngStr.length ) {
            [gpsSourceArray addObject:flagSource];
        } else {

        }
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"NewPublishShowMap" bundle:nil];
    NewPublishShowMapViewController *newPublishShowMapVC = [storyBoard instantiateViewControllerWithIdentifier:@"NewPublishShowMapViewController"];
    newPublishShowMapVC.postTitle = _publishNormalPostModel.posttitle;
    newPublishShowMapVC.showPostGpsArray = gpsSourceArray;
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self presentViewController:newPublishShowMapVC animated:NO completion:nil];
}


#pragma mark - 返回事件
- (void)popButtonClick {
    [self.view endEditing:YES];
    if (self.publishNormalPostModel.posttitle && self.publishNormalPostModel.posttitle.length) {
        if (self.sourceModelArray.count != 0) {
            // 弹出保存草稿箱的弹窗
            [self showDraftAlertView];
        } else {
            [self dimissUIAnimation];
        }
    } else {
        [self dimissUIAnimation];
    }
    
}

- (void)dimissUIAnimation {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 小秘书提示
- (void)showDraftAlertView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishDraftAlertView" bundle:nil];
        PublishDraftAlertViewController *publishDraftAlertVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishDraftAlertViewController"];
        publishDraftAlertVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        publishDraftAlertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        publishDraftAlertVC.publishDraftCallBack = ^(PublishNormalDraftType type) {
            if (type == PublishNormalDraftSaveType) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showHubWithDescription:@"保存中..."];
                });
                [self createPublishDataToDraftCallBack:^(NSMutableArray *flagArray) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[XTCPublishManager sharePublishManager] createPublishModel:self.publishNormalPostModel byUploadModel:flagArray byIsPublish:NO];
                        [self hideHub];
                        [KVNProgress showSuccessWithStatus:@"保存成功" completion:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self dimissUIAnimation];
                            });
                        }];
                    });
                }];
                
            }
            if (type == PublishNormalDraftEditType) {
                
            }
            if (type == PublishNormalDraftExitType) {
                [self dimissUIAnimation];
            }
        };
        [self presentViewController:publishDraftAlertVC animated:NO completion:^{
            
        }];
    });
}

#pragma mark - 生成发布数据到小秘书中
- (void)createPublishDataToDraftCallBack:(void (^)(NSMutableArray *flagArray))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *flagUploadArray = [[NSMutableArray alloc] init];
        // 照片或VR发布
        if (self.publishTypeEnum == PublishPhotoTypeEnum || self.publishTypeEnum == PublishVRTypeEnum) {
            // 纯图片或vr发布
            self.publishNormalPostModel.publishTypeEnum = self.publishTypeEnum;
            @autoreleasepool {
                for (PublishSourceModel *sourceModel in self.sourceModelArray) {
                    NSString *filePath;
                    NSArray *filePathArray = [[XTCPublishManager sharePublishManager] exportImages:@[sourceModel.phAsset]];
                    if (filePathArray.count) {
                        filePath = filePathArray[0];
                    } else {
                        // 生成图片路径失败
                    }
                    PublishUploadFileModel *uploadModel = [[PublishUploadFileModel alloc] init];
                    uploadModel.token = [GlobalData sharedInstance].userModel.token;
                    uploadModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                    uploadModel.file = filePath; // 无损保存到沙盒中，发布时异步压缩
                    uploadModel.file_desc = sourceModel.sourceDesc;
                    uploadModel.file_title = sourceModel.sourceTitle;
                    uploadModel.sourceAsset = sourceModel.phAsset;
                    if (self.publishTypeEnum == PublishVRTypeEnum) {
                        uploadModel.file_type = @"vr";
                        uploadModel.post_type = @"vr";
                    } else {
                        uploadModel.file_type = @"photo";
                        uploadModel.post_type = @"photo";
                        
                    }
                    [flagUploadArray addObject:uploadModel];
                }
            }
            // 是否有音频 视频帖子不带音频
            if (self.publishNormalPostModel.audioFilePath && self.publishTypeEnum != PublishVideoTypeEnum) {
                PublishUploadFileModel *sourceModel = [[PublishUploadFileModel alloc] init];
                sourceModel.token = [GlobalData sharedInstance].userModel.token;
                sourceModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                sourceModel.file_type = @"audio";
                sourceModel.file_desc = @"";
                sourceModel.file_title = @"";
                if (self.publishTypeEnum == PublishPhotoTypeEnum) {
                    sourceModel.post_type = @"photo";
                }
                if (self.publishTypeEnum == PublishVRTypeEnum) {
                    sourceModel.post_type = @"vr";
                }
                if (self.publishTypeEnum == PublishPhotoVideoTypeEnum) {
                    sourceModel.post_type = @"multimedia";
                }
                sourceModel.file = self.publishNormalPostModel.audioFilePath;
                [flagUploadArray addObject:sourceModel];
            } else {
                
            }
        }
        // 视频发布
        if (self.publishTypeEnum == PublishVideoTypeEnum) {
            self.publishNormalPostModel.publishTypeEnum = PublishVideoTypeEnum;
            for (PublishSourceModel *sourceModel in self.sourceModelArray) {
                PublishUploadFileModel *corverUploadModel = [[PublishUploadFileModel alloc] init];
                corverUploadModel.token = [GlobalData sharedInstance].userModel.token;
                corverUploadModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                
                
                NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
                NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
                NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
                NSData *imageData = UIImageJPEGRepresentation(sourceModel.sourceImage, 1);
                [imageData writeToFile:filePath atomically:NO];
                corverUploadModel.file = filePath;
                corverUploadModel.file_desc = sourceModel.sourceDesc;
                corverUploadModel.file_type = @"video_cover";
                corverUploadModel.post_type = @"video";
                corverUploadModel.lng = sourceModel.lngStr;
                corverUploadModel.lat = sourceModel.latStr;
                corverUploadModel.file_desc = sourceModel.sourceDesc;
                [flagUploadArray addObject:corverUploadModel];
                
                PublishUploadFileModel *uploadModel = [[PublishUploadFileModel alloc] init];
                uploadModel.token = [GlobalData sharedInstance].userModel.token;
                uploadModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                uploadModel.file_desc = sourceModel.sourceDesc;
                uploadModel.file = sourceModel.filePath;
                uploadModel.lng = sourceModel.lngStr;
                uploadModel.lat = sourceModel.latStr;
                uploadModel.dateTimeOriginal = sourceModel.dateTimeOriginal;
                uploadModel.make = sourceModel.make;
                uploadModel.model = sourceModel.model;
                uploadModel.file_type = @"video";
                uploadModel.post_type = @"video";
                uploadModel.sourceAsset = sourceModel.phAsset;
                [flagUploadArray addObject:uploadModel];
            }
        }
        // 多媒体发布
        if (self.publishTypeEnum == PublishPhotoVideoTypeEnum) {
            self.publishNormalPostModel.publishTypeEnum = PublishPhotoVideoTypeEnum;
            // 混编发布
            for (PublishSourceModel *sourceModel in self.sourceModelArray) {
                if (sourceModel.fileTypeEnum == PublishSourceFilePhotoTypeEnum) {
                    NSString *filePath;
                    NSArray *filePathArray = [[XTCPublishManager sharePublishManager] exportImages:@[sourceModel.phAsset]];
                    if (filePathArray.count) {
                        filePath = filePathArray[0];
                    } else {
                        // 生成图片路径失败
                    }
                    PublishUploadFileModel *uploadModel = [[PublishUploadFileModel alloc] init];
                    uploadModel.token = [GlobalData sharedInstance].userModel.token;
                    uploadModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                    uploadModel.file = filePath;
                    uploadModel.file_desc = sourceModel.sourceDesc;
                    uploadModel.file_title = sourceModel.sourceTitle;
                    uploadModel.file_type = @"photo";
                    uploadModel.post_type = @"multimedia";
                    uploadModel.sourceAsset = sourceModel.phAsset;
                    [flagUploadArray addObject:uploadModel];
                } else {
                    PublishUploadFileModel *corverUploadModel = [[PublishUploadFileModel alloc] init];
                    corverUploadModel.token = [GlobalData sharedInstance].userModel.token;
                    corverUploadModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                    NSArray *imagePaths =[[XTCPublishManager sharePublishManager] writeImageToFilePath:sourceModel.sourceImage];
                    corverUploadModel.file = imagePaths.count ? imagePaths[0] : @"";
                    corverUploadModel.file_desc = sourceModel.sourceDesc;
                    corverUploadModel.file_title = sourceModel.sourceTitle;
                    corverUploadModel.file_type = @"video_cover";
                    corverUploadModel.post_type = @"multimedia";
                    corverUploadModel.sourceAsset = sourceModel.phAsset;
                    [flagUploadArray addObject:corverUploadModel];
                    
                    PublishUploadFileModel *uploadModel = [[PublishUploadFileModel alloc] init];
                    uploadModel.token = [GlobalData sharedInstance].userModel.token;
                    uploadModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                    uploadModel.file_desc = sourceModel.sourceDesc;
                    uploadModel.file_title = sourceModel.sourceTitle;
                    uploadModel.file = sourceModel.filePath;
                    uploadModel.lng = sourceModel.lngStr;
                    uploadModel.lat = sourceModel.latStr;
                    uploadModel.dateTimeOriginal = sourceModel.dateTimeOriginal;
                    uploadModel.make = sourceModel.make;
                    uploadModel.model = sourceModel.model;
                    uploadModel.file_type = @"video";
                    uploadModel.post_type = @"multimedia";
                    uploadModel.sourceAsset = sourceModel.phAsset;
                    [flagUploadArray addObject:uploadModel];
                }
            }
            // 是否有音频 视频帖子不带音频
            if (self.publishNormalPostModel.audioFilePath && self.publishTypeEnum != PublishVideoTypeEnum) {
                PublishUploadFileModel *sourceModel = [[PublishUploadFileModel alloc] init];
                sourceModel.token = [GlobalData sharedInstance].userModel.token;
                sourceModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                sourceModel.file_type = @"audio";
                sourceModel.file_desc = @"";
                sourceModel.file_title = @"";
                sourceModel.post_type = @"multimedia";
                sourceModel.file = self.publishNormalPostModel.audioFilePath;
                [flagUploadArray addObject:sourceModel];
            } else {
                
            }
        }
        self.publishNormalPostModel.publishTypeEnum = self.publishTypeEnum;
        block(flagUploadArray);
    });
}


#pragma mark - 添加tags
- (void)addTagButtonClick {
    __weak typeof(self) weakSelf = self;
    // 发布标签
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"NewPublishMakeTag" bundle:nil];
    NewPublishMakeTagViewController *newPublishMakeTagVC = [storyBoard instantiateViewControllerWithIdentifier:@"NewPublishMakeTagViewController"];
    newPublishMakeTagVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    newPublishMakeTagVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
    if (self.publishNormalPostModel.tags && self.publishNormalPostModel.tags.length) {
        NSArray *flagTagArray = [weakSelf.publishNormalPostModel.tags componentsSeparatedByString:@","];
        if (flagTagArray.count) {
            newPublishMakeTagVC.selectArray = [[NSMutableArray alloc] initWithArray:flagTagArray copyItems:YES];
        } else {
            newPublishMakeTagVC.selectArray = [[NSMutableArray alloc] init];
        }
    } else {
        newPublishMakeTagVC.selectArray = [[NSMutableArray alloc] init];
    }
    newPublishMakeTagVC.showSelectPublishTagsCallback = ^(NSMutableArray * _Nonnull tagsArray) {
        [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
        weakSelf.publishNormalPostModel.tags = [tagsArray componentsJoinedByString:@","];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.publishNormalPostModel.tags && weakSelf.publishNormalPostModel.tags.length) {
                [weakSelf.publishTableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:weakSelf.sourceModelArray.count+2]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf scrollToBottom:YES];
            } else {
                
            }
        });
    };
    [self presentViewController:newPublishMakeTagVC animated:YES completion:^{
        for (NSString *systemStr in newPublishMakeTagVC.systemTagArray) {
            for (NSString *selectStr in newPublishMakeTagVC.selectArray) {
                if ([systemStr isEqualToString:selectStr]) {
                    newPublishMakeTagVC.selectSystemStr = selectStr;
                    [newPublishMakeTagVC.tagTableView reloadData];
                    break;
                } else {
                    
                }
            }
        }
    }];
}

#pragma mark - 显示标签滚动底部，如果已经显示就不再滚动
- (void)scrollToBottom:(BOOL)animated {
    BOOL isShowTag = NO;
    NSArray *showCells = _publishTableView.visibleCells;
    for (UITableViewCell *cell in showCells) {
        if ([cell isKindOfClass:[NewPublishTagCell class]]) {
            isShowTag = YES;
            break;
        } else {
            
        }
    }
    if (isShowTag) {
        
    } else {
        NSInteger s = [self.publishTableView numberOfSections];  //有多少组
        if (s<1) return;  //无数据时不执行 要不会crash
        NSInteger r = [self.publishTableView numberOfRowsInSection:s-1]; //最后一组有多少行
        if (r<1) return;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];  //取最后一行数据
        [self.publishTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
    }
}

#pragma mark - 更多
- (void)moreButtonClick {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishBottomSwitch" bundle:nil];
    _publishBottomSwitchVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishBottomSwitchViewController"];
    _publishBottomSwitchVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0);
    _publishBottomSwitchVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    if ([_publishNormalPostModel.is_personal isEqualToString:@"Y"]) {
        _publishBottomSwitchVC.friendSwitch.on = YES;
    } else {
        _publishBottomSwitchVC.friendSwitch.on = NO;
    }
    
    if ([_publishNormalPostModel.share_location isEqualToString:@"Y"]) {
        _publishBottomSwitchVC.mapSwitch.on = YES;
    } else {
        _publishBottomSwitchVC.mapSwitch.on = NO;
    }
    if ([_publishNormalPostModel.is_bus isEqualToString:@"0"]) {
        _publishBottomSwitchVC.businessSwitch.on = NO;
    } else {
        _publishBottomSwitchVC.businessSwitch.on = YES;
    }
    
    [_publishBottomSwitchVC.friendSwitch addTarget:self action:@selector(friendSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [_publishBottomSwitchVC.mapSwitch addTarget:self action:@selector(mapSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [_publishBottomSwitchVC.businessSwitch addTarget:self action:@selector(openBuinessClick:) forControlEvents:UIControlEventValueChanged];
    
    [self presentViewController:_publishBottomSwitchVC animated:NO completion:^{
        
    }];
}

#pragma mark - 是否仅对朋友圈可见
- (void)friendSwitchAction:(UISwitch *)friendSwitch {
    if (friendSwitch.isOn) {
        _publishNormalPostModel.is_personal = @"Y";
    } else {
        _publishNormalPostModel.is_personal = @"N";
    }
}

#pragma mark - 是否在地图上显示
- (void)mapSwitchAction:(UISwitch *)mapSwitch {
    if (mapSwitch.isOn) {
        _publishNormalPostModel.share_location = @"Y";
    } else {
        _publishNormalPostModel.share_location = @"N";
    }
    [self gainPostCityAboutInfor];
}

#pragma - mark - 是否打开商业信息发布
- (void)openBuinessClick:(UISwitch *)flagSwitch {
    if ([[GlobalData sharedInstance].userModel.level intValue] > 1) {
        if ([[GlobalData sharedInstance].bus_count intValue] == 0) {
            flagSwitch.on = NO;
            _publishNormalPostModel.is_bus = @"0";
        } else {
            if (flagSwitch.isOn) {
                _publishNormalPostModel.is_bus = @"1";
            } else {
                _publishNormalPostModel.is_bus = @"0";
            }
        }
    } else {
        [_publishBottomSwitchVC dismissViewControllerAnimated:NO completion:^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"商业用户才可以发布商业信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                flagSwitch.on = NO;
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去了解" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                flagSwitch.on = NO;
                CommonWebViewViewController *commonWebView = [[CommonWebViewViewController alloc] init];
                commonWebView.titleString = @"了解服务号";
                commonWebView.urlString = @"http://show.viewspeaker.com/introduce";
                commonWebView.isPreventPanPop = NO;
                [self.navigationController pushViewController:commonWebView animated:YES];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:sureAction];
            [self presentViewController:alertController animated:NO completion:^{
                
            }];
        }];
    }
    
}

#pragma mark -  添加照片或视频
- (void)addPhotoButtonClick:(UIButton *)button {
    if (button.tag == 101) {
        NSInteger photoCount;
        if (self.publishTypeEnum == PublishVRTypeEnum) {
            photoCount = maxUploadVRImageCount;
        } else {
            photoCount = ([[GlobalData sharedInstance].userModel.level intValue] > 1 ? maxBusinessUploadImageCount : maxNormalUploadImageCount);
        }
        SelectPublishTypeEnum flagEnum;
        switch (self.publishTypeEnum) {
            case PublishPhotoTypeEnum:
                flagEnum = SelectPublishTypePhotoEnum;
                break;
            case PublishVideoTypeEnum:
                flagEnum = SelectPublishTypeVideoEnum;
                break;
            case PublishVRTypeEnum:
                flagEnum = SelectPublishType720VREnum;
                break;
            default:
                flagEnum = SelectPublishTypePhotoEnum;
                break;
        }
        NSMutableArray *flagAssetArray = [[NSMutableArray alloc] init];
        for (PublishSourceModel *flagPublishSourceModel in self.sourceModelArray) {
            PHAsset *asset = flagPublishSourceModel.phAsset;
            if (asset) {
                [flagAssetArray addObject:asset];
            } else {
                
            }
            
        }
        __weak typeof(self) weakSelf = self;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPublishPicker" bundle:nil];
        XTCPublishPickerViewController *publishPickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPublishPickerViewController"];
        publishPickerVC.transitioningDelegate = self;
        publishPickerVC.isPublishSelect = NO;
        publishPickerVC.isSinglePick = NO;
        publishPickerVC.selectPublishTypeEnum = flagEnum;
        NSMutableArray *selectArray = [[NSMutableArray alloc] init];
        for (PublishSourceModel *flagSource in _sourceModelArray) {
            TZAssetModel *assetModel = [[TZAssetModel alloc] init];
            assetModel.asset = flagSource.phAsset;
            [selectArray addObject:assetModel];
        }
        if (flagEnum == SelectPublishType720VREnum) {
            // 传入VR选中model
            publishPickerVC.selectVRArray = selectArray;
        } else {
            // 传入普通照片选中model
            publishPickerVC.selectPhotoArray = selectArray;
        }
        publishPickerVC.selectPublishSourceCallBack = ^(NSMutableArray *assetArray, NSMutableArray *photoArray, SelectPublishTypeEnum selectPublishTypeEnum) {
            [weakSelf loadPublishData:assetArray byPhoto:photoArray byPublishType:selectPublishTypeEnum];
        };
        XTCBaseNavigationController *pickerNav = [[XTCBaseNavigationController alloc] initWithRootViewController:publishPickerVC];
        pickerNav.transitioningDelegate = self;
        [weakSelf presentViewController:pickerNav animated:YES completion:^{
            
        }];
    } else {
        
    }
}

#pragma mark - UITextView delegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.tag == 100) {
        if (textView.text.length > 50) {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 50)];
        }
        XTCPublishTitleCell *cell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        _publishNormalPostModel.posttitle = textView.text;
        if (_publishNormalPostModel.posttitle && _publishNormalPostModel.posttitle.length) {
            cell.defaultLabel.hidden = YES;
        } else {
            cell.defaultLabel.hidden = NO;
        }
        
        if (_publishNormalPostModel.posttitle && _publishNormalPostModel.posttitle.length) {
            CGRect rect = [_publishNormalPostModel.posttitle boundingRectWithSize:CGSizeMake(kScreenWidth-35-100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:21]} context:nil];
            if (rect.size.height + 20 < 35) {
                cell.heightLayoutConstraint.constant = 35;
            } else {
                cell.heightLayoutConstraint.constant = rect.size.height+20;
            }
            
        } else {
            cell.heightLayoutConstraint.constant = 35;
        }
        [_publishTableView beginUpdates];
        [_publishTableView endUpdates];
        [cell.titleTextView setContentOffset:CGPointZero animated:NO];
        
    }
    if (textView.tag >= 300 && textView.tag < 400) {
        // 小标题
        if (textView.text.length > 50) {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 50)];
        }
        NSInteger section = textView.tag-300;
        PublishSourceModel *flagSource = _sourceModelArray[section-1];
        flagSource.sourceTitle = textView.text;
        NewPublishDescCell *cell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        if (textView.text && textView.text.length) {
            cell.defaultLabel.hidden = YES;
        } else {
            cell.defaultLabel.hidden = NO;
        }
        CGFloat oldOffset = 0;
        if (flagSource.sourceTitle && flagSource.sourceTitle.length) {
            CGRect rect = [flagSource.sourceTitle boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
            if (rect.size.height + 20 < 40) {
                oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = 40;
            } else {
                oldOffset = rect.size.height+20 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = rect.size.height+20;
            }
            
        } else {
            oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
            cell.descHeightLayoutConstraint.constant = 40;
        }
        DDLogInfo(@"-----%f", oldOffset);
        if (oldOffset == 0) {
            
        } else {
            [_publishTableView beginUpdates];
            [_publishTableView endUpdates];
            [cell.postDescTextView setContentOffset:CGPointZero animated:NO];
            [_publishTableView setContentOffset:CGPointMake(0, _publishTableView.contentOffset.y+oldOffset) animated:NO];
        }
    }
    
    if (textView.tag >= 400 && textView.tag < 500) {
        // 照片描述
        if (textView.text.length > 1000) {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 1000)];
        }
        NSInteger section = textView.tag-400;
        PublishSourceModel *flagSource = _sourceModelArray[section-1];
        flagSource.sourceDesc = textView.text;
        NewPublishDescCell *cell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
        if (textView.text && textView.text.length) {
            cell.defaultLabel.hidden = YES;
        } else {
            cell.defaultLabel.hidden = NO;
        }
        CGFloat oldOffset = 0;
        if (flagSource.sourceDesc && flagSource.sourceDesc.length) {
            CGRect rect = [flagSource.sourceDesc boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
            if (rect.size.height + 20 < 40) {
                oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = 40;
            } else {
                oldOffset = rect.size.height+20 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = rect.size.height+20;
            }
            
        } else {
            oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
            cell.descHeightLayoutConstraint.constant = 40;
        }
        if (oldOffset == 0) {
            
        } else {
            [_publishTableView beginUpdates];
            [_publishTableView endUpdates];
            [cell.postDescTextView setContentOffset:CGPointZero animated:NO];
            [_publishTableView setContentOffset:CGPointMake(0, _publishTableView.contentOffset.y+oldOffset) animated:NO];
        }
    }
    
    if (textView.tag == 200) {
        if (textView.text.length > 1000) {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 1000)];
        }
        _publishNormalPostModel.postcontent = textView.text;
        NewPublishDescCell *cell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        if (textView.text && textView.text.length) {
            cell.defaultLabel.hidden = YES;
        } else {
            cell.defaultLabel.hidden = NO;
        }
        CGFloat oldOffset = 0;
        if (_publishNormalPostModel.postcontent && _publishNormalPostModel.postcontent.length) {
            CGRect rect = [_publishNormalPostModel.postcontent boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
            if (rect.size.height + 20 < 50) {
                oldOffset = 50 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = 50;
            } else {
                oldOffset = rect.size.height+20 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = rect.size.height+20;
            }
            
        } else {
            oldOffset = 50 - cell.descHeightLayoutConstraint.constant;
            cell.descHeightLayoutConstraint.constant = 50;
        }
        [_publishTableView beginUpdates];
        [_publishTableView endUpdates];
        [cell.postDescTextView setContentOffset:CGPointZero animated:NO];
        [_publishTableView setContentOffset:CGPointMake(0, _publishTableView.contentOffset.y+oldOffset) animated:NO];
    }
    
    if (textView.tag == 501) {
        if (textView.text.length > 1000) {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 1000)];
        }
        _publishNormalPostModel.endTitle = textView.text;
        NewPublishDescCell *cell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_sourceModelArray.count+1]];
        if (textView.text && textView.text.length) {
            cell.defaultLabel.hidden = YES;
        } else {
            cell.defaultLabel.hidden = NO;
        }
        CGFloat oldOffset = 0;
        if (_publishNormalPostModel.endTitle && _publishNormalPostModel.endTitle.length) {
            CGRect rect = [_publishNormalPostModel.endTitle boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
            if (rect.size.height + 20 < 40) {
                oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = 40;
            } else {
                oldOffset = rect.size.height+20 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = rect.size.height+20;
            }
            
        } else {
            oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
            cell.descHeightLayoutConstraint.constant = 40;
        }
        DDLogInfo(@"-----%f", oldOffset);
        if (oldOffset == 0) {
            
        } else {
            [_publishTableView beginUpdates];
            [_publishTableView endUpdates];
            [cell.postDescTextView setContentOffset:CGPointZero animated:NO];
            [_publishTableView setContentOffset:CGPointMake(0, _publishTableView.contentOffset.y+oldOffset) animated:NO];
        }
    }
    if (textView.tag == 502) {
        if (textView.text.length > 1000) {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 1000)];
        }
        _publishNormalPostModel.endDesc = textView.text;
        NewPublishDescCell *cell = [_publishTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:_sourceModelArray.count+1]];
        if (textView.text && textView.text.length) {
            cell.defaultLabel.hidden = YES;
        } else {
            cell.defaultLabel.hidden = NO;
        }
        CGFloat oldOffset = 0;
        if ( _publishNormalPostModel.endDesc &&  _publishNormalPostModel.endDesc.length) {
            CGRect rect = [ _publishNormalPostModel.endDesc boundingRectWithSize:CGSizeMake(kScreenWidth-35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
            if (rect.size.height + 20 < 40) {
                oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = 40;
            } else {
                oldOffset = rect.size.height+20 - cell.descHeightLayoutConstraint.constant;
                cell.descHeightLayoutConstraint.constant = rect.size.height+20;
            }
            
        } else {
            oldOffset = 40 - cell.descHeightLayoutConstraint.constant;
            cell.descHeightLayoutConstraint.constant = 40;
        }
        if (oldOffset == 0) {
            
        } else {
            [_publishTableView beginUpdates];
            [_publishTableView endUpdates];
            [cell.postDescTextView setContentOffset:CGPointZero animated:NO];
            [_publishTableView setContentOffset:CGPointMake(0, _publishTableView.contentOffset.y+oldOffset) animated:NO];
        }
    }
    
    [self scrollViewDidScroll:_publishTableView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] && (textView.tag == 100 || textView.tag == 501)) {
        [textView resignFirstResponder];
    }
    if ([text isEqualToString:@"\n"] && textView.tag >= 300 & textView.tag < 400) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - 删除资源照片或视频
- (void)deleteButtonClick:(UIButton *)deleteButton {
    NSInteger deleteIndex = deleteButton.tag;
    [_sourceModelArray removeObjectAtIndex:deleteIndex];
    [_publishTableView reloadData];
    if (_sourceModelArray.count > 1) {
        self.sortButton.hidden = NO;
    } else {
        self.sortButton.hidden = YES;
    }
    // 如果当前的是多媒体类型需要判断删除后是否还是多媒体类型
    if (_publishTypeEnum == PublishPhotoVideoTypeEnum) {
        [self checkPublishType];
    } else {
        
    }
    
    [self gainPostCityAboutInfor];
}

#pragma mark - 检测删除资源图片的发布类型
- (void)checkPublishType {
    BOOL havePhoto = NO;
    BOOL haveVideo = NO;
    for (PublishSourceModel *sourceModel in _sourceModelArray) {
        if (sourceModel.fileTypeEnum == PublishSourceFileVideoTypeEnum) {
            haveVideo = YES;
        }
        if (sourceModel.fileTypeEnum == PublishSourceFilePhotoTypeEnum) {
            havePhoto = YES;
        }
    }
    if (havePhoto && haveVideo) {
        // 还是多媒体
        _publishTypeEnum = PublishPhotoVideoTypeEnum;
    } else {
        if (haveVideo) {
            _publishTypeEnum = PublishVideoTypeEnum;
        } else {
            _publishTypeEnum = PublishPhotoTypeEnum;
        }
    }
}

#pragma mark - 照片视频排序
- (void)sortSourceButtonClick {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishMoveSource" bundle:nil];
    PublishMoveSourceViewController *publishMoveSourceVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishMoveSourceViewController"];
    publishMoveSourceVC.view.backgroundColor = RGBACOLOR(255, 255, 255, 0.8);
    publishMoveSourceVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    publishMoveSourceVC.publishSortCallBack = ^(NSMutableArray * _Nullable sourceArray) {
        weakSelf.sourceModelArray = sourceArray;
        [weakSelf.publishTableView reloadData];
    };
    [[StaticCommonUtil topViewController] presentViewController:publishMoveSourceVC animated:YES completion:^{
        publishMoveSourceVC.sourceArray = [[NSMutableArray alloc] initWithArray:self.sourceModelArray copyItems:YES];
        [publishMoveSourceVC.sourceCollectionView reloadData];
    }];
}

#pragma mark -  检测当前发布的坐标
- (void)checkCurrentPublishLocaltion {
    if ([INTULocationManager locationServicesState] == INTULocationServicesStateAvailable || [INTULocationManager locationServicesState] == INTULocationServicesStateNotDetermined) {
        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            if (status == INTULocationStatusSuccess) {
                if (currentLocation) {
                    CLLocationCoordinate2D coordinate = currentLocation.coordinate;
                    self.publishNormalPostModel.latStr = [NSString stringWithFormat:@"%.8f", coordinate.latitude];
                    self.publishNormalPostModel.lngStr = [NSString stringWithFormat:@"%.8f", coordinate.longitude];
                } else {
                    
                }
            } else {
                
            }
        }];
    } else {
        
    }
}

#pragma mark - 发布按钮被点击
- (void)publishButtonClick {
    [self.view endEditing:YES];
    [self showHubWithDescription:@"发布处理中..."];
    if ([GlobalData sharedInstance].publishErrorModel.errorEnum == ResponseServerErrorEnum) {
        [self hideHub];
        [self alertMessage:[GlobalData sharedInstance].publishErrorModel.errorString];
    } else if ([GlobalData sharedInstance].publishErrorModel.errorEnum == ResponseSuccessEnum) {
        [self checkSuccessRelease];
    } else {
        // 检测是否能发布帖子
        XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
        requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
        requestModel.token = [GlobalData sharedInstance].userModel.token;
        /*
         [[RSNetworkingManager shareRequestConnect] networkingCommonByRequestEnum:RequestCheckPublishEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
         [GlobalData sharedInstance].publishErrorModel = errorModel;
         dispatch_async(dispatch_get_main_queue(), ^{
         if (errorModel.errorEnum == ResponseServerErrorEnum) {
         [self hideHub];
         [self alertMessage:[GlobalData sharedInstance].publishErrorModel.errorString];
         } else {
         [self checkSuccessRelease];
         }
         });
         }];
         */
    }
}

#pragma mark - 发布帖子检测成功
- (void)checkSuccessRelease {
    // 保存历史标签
    if (self.publishContentEnum == PublishContentSpotEnum || self.publishNormalPostModel.tags == nil || self.publishNormalPostModel.tags.length == 0) {
        
    } else {
        [NBZUtil saveHistoryTag:self.publishNormalPostModel];
    }
    
    if (!self.publishNormalPostModel.posttitle || !self.publishNormalPostModel.posttitle.length) {
        [self hideHub];
        [self alertMessage:NSLocalizedString(@"The title cannot be empty", comment: @"")];
        return;
    }
    
    if (self.sourceModelArray.count == 0) {
        [self hideHub];
        [NBZUtil showMessage:NSLocalizedString(@"Please select at least a photo", comment: @"") withTitle:NSLocalizedString(@"Prompt", comment: @"") inVC:self];
        return;
    }
    
    if ([self.publishNormalPostModel.art_link hasPrefix:@"http"] || [self.publishNormalPostModel.art_link hasPrefix:@"https"]) {
        self.publishNormalPostModel.art_link = self.publishNormalPostModel.art_link;
    } else {
        if (self.publishNormalPostModel.art_link && self.publishNormalPostModel.art_link.length) {
            self.publishNormalPostModel.art_link = [NSString stringWithFormat:@"http://%@", self.publishNormalPostModel.art_link];
        } else {
            self.publishNormalPostModel.art_link = @"";
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self recordingMp3FilePath]]) {
        self.publishNormalPostModel.audioFilePath = [self recordingMp3FilePath];
    } else {
        
    }
    [self createPublishDataToDraftCallBack:^(NSMutableArray *flagArray) {
        if ([XTCPublishManager sharePublishManager].isPubishLoading) {
            // 直接放到草稿箱中
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHub];
                [self alertMessage:@"其他帖子上传中，已保存到小秘书"];
                [self dimissUIAnimation];
                [[XTCPublishManager sharePublishManager] createPublishModel:self.publishNormalPostModel byUploadModel:flagArray byIsPublish:YES];
            });
        } else {
            // 可以发布
            dispatch_async(dispatch_get_main_queue(), ^{
//                [[XTCPublishManager sharePublishManager] createPublishModel:self.publishNormalPostModel byUploadModel:flagArray byIsPublish:YES];
                [self hideHub];
                [KVNProgress showSuccessWithStatus:@"开始发布" completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dimissUIAnimation];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[XTCPublishManager sharePublishManager] createPublishModel:self.publishNormalPostModel byUploadModel:flagArray byIsPublish:YES];
                        });
                    });
                }];
            });
        }
    }];
}

#pragma mark - 视频播放转屏
- (void)directionChange:(TgDirection)direction {
    if (_isVerticalPlay == NO && _videoCell && _videoCell.videoBgView.hidden == NO) {
        if (direction == TgDirectionPortrait) {
            [self.videoCell.videoBgView jp_gotoPortrait];
        }
        if (direction == TgDirectionRight) {
            [self.videoCell.videoBgView jp_gotoLandscape:YES byDeviceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        if (direction == TgDirectionleft) {
            [self.videoCell.videoBgView jp_gotoLandscape:YES byDeviceOrientation:UIInterfaceOrientationLandscapeLeft];
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

- (void)dealloc {
    DDLogInfo(@"发布界面内存释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XTCVideoPlayFinish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PhotoLibraryReloadVideoAgainName" object:nil];
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
