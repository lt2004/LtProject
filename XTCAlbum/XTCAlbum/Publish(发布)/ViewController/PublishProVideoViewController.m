//
//  PublishProVideoViewController.m
//  vs
//
//  Created by Xie Shu on 2017/11/4.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishProVideoViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SDAVAssetExportSession.h"
#import "PublishNormalPostModel.h"
#import "XTCAlbum-Swift.h"

@interface PublishProVideoViewController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
    BOOL _isEditTag; // 是否编辑删除标签
    XLVideoPlayer *_xlVideoPlayer;
    
    NSString *_proPublishNumber; // 发布pro唯一码
    SDAVAssetExportSession *_encoder;
}

@property (nonatomic, strong) PublishNormalPostModel *publishNormalPostModel;
@property (nonatomic, strong) UIImage *corverProImage;
@property (nonatomic, strong) UIImageView *corverImageView;
@property (nonatomic, strong) UILabel *corverTitleChinaLabel;
@property (nonatomic, strong) UILabel *corverTitleEnglishLabel;

@end

@implementation PublishProVideoViewController
@synthesize menuBottomLayoutConstraint = _menuBottomLayoutConstraint;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPanGestureRecognizer *cancelFullScreenGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cancelFullScreenGes)];
    [self.view addGestureRecognizer:cancelFullScreenGes];
    
    // 草稿箱数据模型初始化
    _publishNormalPostModel = [[PublishNormalPostModel alloc] init];
    _publishNormalPostModel.publishTypeEnum = PublishProTypeEnum;
    _publishNormalPostModel.proPage = 1;
    _publishNormalPostModel.proFirstDetailModel = [[ProDetailModel alloc] init];
    _publishNormalPostModel.proSecondDetailModel = [[ProDetailModel alloc] init];
    _publishNormalPostModel.proThirdDetailModel = [[ProDetailModel alloc] init];
    _publishNormalPostModel.sub_post_id = _interactivePostId;
    _publishNormalPostModel.is_personal = @"N";
    _publishNormalPostModel.share_location = @"Y";
    _publishNormalPostModel.chatType = _chatType;
    _publishNormalPostModel.chatId = _chatId;
    _publishNormalPostModel.tk = _tk;
    _publishNormalPostModel.artLinkVerifyFinish = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _publishNormalPostModel.dateString = [dateFormatter stringFromDate:[NSDate date]];
    /*
    if ([GlobalData sharedInstance].art_link && [GlobalData sharedInstance].art_link.length) {
        _publishNormalPostModel.art_link = [GlobalData sharedInstance].art_link;
    } else {
        
    }
     */
    NSString* outputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    outputURL = [NSString stringWithFormat:@"%@/%@_video.mp4", outputURL, _proPublishNumber];
    
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmSS"];
    _proPublishNumber =  [dateFormatter stringFromDate:[NSDate date]];
    
    [self outPutAboutVideoInfor];
    [self loadTableViewAboutUI];
    [_addTagButton addTarget:self action:@selector(addTagButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)cancelFullScreenGes {
    
}

- (void)outPutAboutVideoInfor {
    PHAsset *phAsset = self.videoAsset;
    [self showHubWithDescription:@"正在渲染"];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = true;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *videoOutputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        videoOutputURL = [NSString stringWithFormat:@"%@/%@_video.mp4", videoOutputURL, self->_proPublishNumber];
            @try {
                [[NSFileManager defaultManager] removeItemAtPath:videoOutputURL error:nil];
            } @catch(NSException *exception) {
                
            }
            
            // 获取本地视频大小如果小于210kb/s不用压缩直接上传
            BOOL isNeeddCom = YES;
        if ([flagAsset isKindOfClass:[AVComposition class]]) {
            
        } else {
            NSURL *URL = [(AVURLAsset *)flagAsset URL];
            NSNumber *fileSizeValue = nil;
            [URL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:nil];
            AVURLAsset* avUrlAsset = (AVURLAsset*)flagAsset;
            NSNumber *size;
            [avUrlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            if ([fileSizeValue floatValue]/1024.0/self->_videoAsset.duration < kSizeMaxSecond) {
                isNeeddCom = NO;
            } else {
                isNeeddCom = YES;
            }
        }
        
            if (isNeeddCom) {
                // 视频码率压缩部分
                self->_encoder = [SDAVAssetExportSession.alloc initWithAsset:flagAsset];
                NSURL * url = [NSURL fileURLWithPath:videoOutputURL];
                self->_encoder.outputURL = url;
                self->_encoder.outputFileType = AVFileTypeMPEG4;
                self->_encoder.shouldOptimizeForNetworkUse = YES;
                
                NSInteger flagWidth = self.videoAsset.pixelWidth;
                NSInteger flagHeight = self.videoAsset.pixelHeight;
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
                self->_encoder.videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                            AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                            AVVideoWidthKey : @(flagWidth),
                                            AVVideoHeightKey : @(flagHeight),
                                            AVVideoCompressionPropertiesKey : compressionProperties };
                
                
                // 音频设置
                self->_encoder.audioSettings = @{ AVEncoderBitRatePerChannelKey : @(60000),
                                            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                            AVNumberOfChannelsKey : @(2),
                                            AVSampleRateKey : @(44100) };
                
                [self->_encoder exportAsynchronouslyWithCompletionHandler:^ {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideHub];
                    });
                    int status = self->_encoder.status;
                    
                    if (status == AVAssetExportSessionStatusCompleted) {
                        self->_publishNormalPostModel.proVideoFilePath = videoOutputURL;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self->_videoCorverImage = [self thumbnailImageFromURL:[NSURL fileURLWithPath:videoOutputURL]];
                            [self->_publishProTableView reloadData];
                        });
                    } else if (status == AVAssetExportSessionStatusCancelled) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self->_videoCorverImage = nil;
                            [self->_publishProTableView reloadData];
                            [self alertMessage:@"渲染失败"];
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self->_videoCorverImage = nil;
                            [self->_publishProTableView reloadData];
                            [self alertMessage:@"渲染失败"];
                        });
                    }
                }];
            } else {
                // 直接导出
                AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:flagAsset presetName:AVAssetExportPresetHighestQuality];
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
                            self->_publishNormalPostModel.proVideoFilePath = videoOutputURL;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self->_videoCorverImage = [self thumbnailImageFromURL:[NSURL fileURLWithPath:videoOutputURL]];
                                [self->_publishProTableView reloadData];
                            });
                            break;
                        }
                    }
                }];
            }
            
//        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_xlVideoPlayer destroyPlayer];
    _xlVideoPlayer = nil;
    self.navigationItem.leftBarButtonItems = @[];
    self.navigationItem.hidesBackButton = YES;
    [self createNaviAboutView];
    //监听当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_xlVideoPlayer destroyPlayer];
    _xlVideoPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//当键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self->_menuBottomLayoutConstraint.constant = height;
        [self.view layoutIfNeeded];
    }];
    
}

//当键退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘的高度
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self->_menuBottomLayoutConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)createAboutUI {
    _addTagButton.layer.borderColor = RGBCOLOR(31, 31, 31).CGColor;
    _addTagButton.layer.borderWidth = 0.5;
    _addTagButton.layer.cornerRadius = 15;
    _addTagButton.layer.masksToBounds = YES;
}

#pragma mark - 创建tableview
- (void)loadTableViewAboutUI {
    _publishProTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _publishProTableView.rowHeight = UITableViewAutomaticDimension;
    _publishProTableView.estimatedRowHeight = 50.0f;
    _publishProTableView.backgroundColor = kTableviewColor;
    _publishProTableView.showsVerticalScrollIndicator = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 187)];
    _publishProTableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    _publishProTableView.tableFooterView = footerView;
    
    _corverImageView = [[UIImageView alloc] init];
    _corverImageView.image = [UIImage imageNamed:@"pro_grid"];
    _corverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _corverImageView.clipsToBounds = YES;
    _corverImageView.userInteractionEnabled = YES;
    [headerView addSubview:_corverImageView];
    [_corverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerView);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesCorverImage)];
    tapGes.delegate = self;
    [_corverImageView addGestureRecognizer:tapGes];
    
    _corverTitleChinaLabel = [[UILabel alloc] init];
    _corverTitleChinaLabel.text = @"添加封面";
    _corverTitleChinaLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    _corverTitleChinaLabel.textColor = [UIColor darkGrayColor];
    [headerView addSubview:_corverTitleChinaLabel];
    
    [_corverTitleChinaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView);
        make.top.equalTo(headerView).with.offset(48);
    }];
    
    _corverTitleEnglishLabel = [[UILabel alloc] init];
    _corverTitleEnglishLabel.text = @"change cover";
    _corverTitleEnglishLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    _corverTitleEnglishLabel.textColor = [UIColor darkGrayColor];
    [headerView addSubview:_corverTitleEnglishLabel];
    
    [_corverTitleEnglishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_corverTitleChinaLabel).with.offset(20);
        make.top.equalTo(self->_corverTitleChinaLabel.mas_bottom).with.offset(2);
    }];
    
    UITextField *descTextField = [[UITextField alloc] init];
    descTextField.placeholder = @"添加标题 title";
    descTextField.backgroundColor = RGBCOLOR(251, 251, 251);
    descTextField.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    descTextField.returnKeyType = UIReturnKeyDone;
    descTextField.delegate = self;
    descTextField.tag = 101;
    [descTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [headerView addSubview:descTextField];
    
    descTextField.layer.cornerRadius = 19;
    descTextField.layer.masksToBounds = YES;
    descTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    descTextField.layer.borderWidth = 0.5;
    
    UIButton *writeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeButton setImage:[UIImage imageNamed:@"pro_write"] forState:UIControlStateNormal];
    writeButton.frame = CGRectMake(0, 0, 30, 30);
    descTextField.leftView = writeButton;
    descTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [descTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).with.offset(18);
        make.right.equalTo(headerView).with.offset(-18);
        make.height.mas_equalTo(38);
        make.bottom.equalTo(headerView.mas_bottom).with.offset(-16);
    }];
    
}

#pragma mark - 创建导航栏相关
- (void)createNaviAboutView {
    self.navigationItem.leftBarButtonItems = @[];
    UIImageView *titleImageView = [[UIImageView alloc] init];
    titleImageView.image = [UIImage imageNamed:@"pro_1"];
    [titleImageView sizeToFit];
    self.navigationItem.titleView = titleImageView;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"pro_exit"] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelButton sizeToFit];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSeperator.width = -10;
    
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItems = @[leftSeperator, cancelBarItem];
}

#pragma mark - 退出发布
- (void)cancelButtonClick {
    [[NSFileManager defaultManager] removeItemAtPath:_publishNormalPostModel.proVideoFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:_publishNormalPostModel.proCorverVideoImageFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:_publishNormalPostModel.proCorverImageFilePath error:nil];
//    [self.navigationController popViewControllerAnimated:YES];
    [[StaticCommonUtil topViewController].navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - tableview datasource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        if (_publishNormalPostModel.tags && _publishNormalPostModel.tags.length) {
            return 1;
        } else {
            return 0;
        }
    }
    if (section == 2) {
        if (_publishNormalPostModel.art_link && _publishNormalPostModel.art_link.length) {
            return 1;
        } else {
            return 0;
        }
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (_publishNormalPostModel.art_link && _publishNormalPostModel.art_link.length) {
                CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
                commonWebViewVC.titleString = @"查看网站";
                commonWebViewVC.urlString = _publishNormalPostModel.art_link;
            commonWebViewVC.isPreventPanPop = NO;
                [self.navigationController pushViewController:commonWebViewVC animated:YES];
        } else {
            [self alertMessage:@"请添加网址"];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellName = @"PublishProVideoCellName";
        PublishProVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[PublishProVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.selectVideoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (_videoCorverImage) {
            [cell.selectVideoButton setImage:_videoCorverImage forState:UIControlStateNormal];
            [cell.selectVideoButton setBackgroundImage:nil forState:UIControlStateNormal];
            //            if (_xlVideoPlayer.player.rate == 1.0) {
            //                cell.playVideoButton.hidden = YES;
            //            } else {
            //               cell.playVideoButton.hidden = NO;
            //            }
            cell.playVideoButton.hidden = NO;
        } else {
            [cell.selectVideoButton setImage:nil forState:UIControlStateNormal];
            [cell.selectVideoButton setBackgroundImage:[UIImage imageNamed:@"pro_video"] forState:UIControlStateNormal];
            cell.playVideoButton.hidden = YES;
        }
        [cell.selectVideoButton addTarget:self action:@selector(selectVideoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteVideoButton addTarget:self action:@selector(deleteVideoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        cell.addDescTextField.tag = 102;
        [cell.addDescTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.addDescTextField.delegate = self;
        cell.addDescTextField.returnKeyType = UIReturnKeyDone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *cellName = @"PublishNormalTagCellName";
        PublishNormalTagCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[PublishNormalTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        [cell insertAboutTagView:_publishNormalPostModel.tags byDeleteFlag:_isEditTag];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.editButton addTarget:self action:@selector(editTagTapGes) forControlEvents:UIControlEventTouchUpInside];
        if (_isEditTag) {
            [cell.editButton setTitle:@"取消编辑" forState:UIControlStateNormal];
        } else {
            [cell.editButton setTitle:@"编辑标签" forState:UIControlStateNormal];
        }
        cell.publishNormalDelTagCallBack = ^(NSString *tagString) {
            NSArray *tagArray = [self->_publishNormalPostModel.tags componentsSeparatedByString:@","];
            NSMutableArray *flagTagArray = [[NSMutableArray alloc] initWithArray:tagArray];
            [flagTagArray removeObject:tagString];
            self->_publishNormalPostModel.tags = [flagTagArray componentsJoinedByString:@","];
            [self->_publishProTableView reloadData];
        };
        return cell;
    } else {
        static NSString *cellName = @"PublishNormalVipCellName";
        PublishNormalVipCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[PublishNormalVipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.urlTextField.delegate = self;
        cell.urlTextField.returnKeyType = UIReturnKeyDone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - 添加标签
- (void)addTagButtonClick {
    __weak typeof(self) weakSelf = self;
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
        [weakSelf.publishProTableView reloadData];
    };
    [self presentViewController:newPublishMakeTagVC animated:YES completion:^{
        
    }];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == 101) {
        _publishNormalPostModel.posttitle = textField.text;
    } else {
        _publishNormalPostModel.postcontent = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 编辑标签
- (void)editTagTapGes {
    _isEditTag = !_isEditTag;
    [_publishProTableView reloadData];
}

- (void)selectVideoButtonClick {
    if (_videoCorverImage) {
        [self playVieoButtonClick];
    } else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPublishPicker" bundle:nil];
        XTCPublishPickerViewController *publishPickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPublishPickerViewController"];
        publishPickerVC.isPublishSelect = NO;
        publishPickerVC.isProSingleSelect = YES;
        publishPickerVC.selectPublishTypeEnum = SelectPublishTypeVideoEnum;
        publishPickerVC.selectPublishSourceCallBack = ^(NSMutableArray *assetArray, NSMutableArray *photoArray, SelectPublishTypeEnum selectPublishTypeEnum) {
            PHAsset *phAsset = assetArray.firstObject;
            if (phAsset.duration > 120) {
                [self alertMessage:@"视频不能大于120s哦"];
            } else {
                [self showHubWithDescription:@"正在渲染"];
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionCurrent;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                PHImageManager *manager = [PHImageManager defaultManager];
                [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    // 设备品牌
                    NSArray *makeArray = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                        withKey:AVMetadataCommonKeyMake
                                                                       keySpace:AVMetadataKeySpaceCommon];
                    for (AVMetadataItem *item in makeArray) {
                        if (item.value) {
                            //                        [metaDict setObject:item.value forKey:@"Make"];
                            self->_publishNormalPostModel.make = (NSString *)item.value;
                        } else {
                            
                        }
                    }
                    // 设备型号
                    NSArray *modelArray = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                         withKey:AVMetadataCommonKeyModel
                                                                        keySpace:AVMetadataKeySpaceCommon];
                    for (AVMetadataItem *item in modelArray) {
                        if (item.value) {
                            //                        [metaDict setObject:item.value forKey:@"Model"];
                            self->_publishNormalPostModel.model = (NSString *)item.value;
                        } else {
                            
                        }
                    }
                    // 拍摄时间
                    NSDate *createDate = phAsset.creationDate;
                    
                    //设置源日期时区
                    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
                    //设置转换后的目标日期时区
                    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
                    //得到源日期与世界标准时间的偏移量
                    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:createDate];
                    //目标日期与本地时区的偏移量
                    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:createDate];
                    //得到时间偏移量的差值
                    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
                    //转为现在时间
                    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:createDate];
                    NSTimeInterval timeInterval = [destinationDateNow timeIntervalSince1970];
                    NSString *timeString = [NSString stringWithFormat:@"%0.f", timeInterval];//转为字符型
                    self.publishNormalPostModel.dateTimeOriginal = timeString;
                    
                    // 移除无用视频
                    NSString* outputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSFileManager *man = [NSFileManager defaultManager];
                    
                    @try {
                        [man createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    @catch (NSException *exception) {
                        if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
                            DDLogInfo(@"%@", exception);
                        } else {
                            @throw exception;
                        }
                    }
                    @finally {
                        DDLogInfo(@"finally");
                    }
                    outputURL = [NSString stringWithFormat:@"%@/%@_video.mp4", outputURL, self->_proPublishNumber];
                    if (self->_publishNormalPostModel.proVideoFilePath  && self->_publishNormalPostModel.proVideoFilePath.length) {
                        [man removeItemAtPath:self->_publishNormalPostModel.proVideoFilePath  error:nil];
                    }
                    
                    
                    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset1280x720];
                    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
                    
                    float totalTime = asset.duration.value / asset.duration.timescale;
                    float time = totalTime*15/60*1024*1024;
                    exportSession.fileLengthLimit = time;
                    
                    //导出格式
                    exportSession.outputFileType = AVFileTypeMPEG4;
                    //开始异步导出
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                            self->_publishNormalPostModel.proVideoFilePath = outputURL;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self hideHub];
                                self->_videoCorverImage = [self thumbnailImageFromURL:[NSURL fileURLWithPath:outputURL]];
                                [self->_publishProTableView reloadData];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self->_videoCorverImage = nil;
                                [self->_publishProTableView reloadData];
                                [self hideHub];
                            });
                        }
                        
                        
                    }];
                }];
            }
        };
        XTCBaseNavigationController *pickerNav = [[XTCBaseNavigationController alloc] initWithRootViewController:publishPickerVC];
        [self presentViewController:pickerNav animated:YES completion:^{
            
        }];
    }
    
}

#pragma mark - 生成视频缩略
- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    if (_publishNormalPostModel.proCorverVideoImageFilePath && _publishNormalPostModel.proCorverVideoImageFilePath.length) {
        NSFileManager *man = [NSFileManager defaultManager];
        [man removeItemAtPath:_publishNormalPostModel.proCorverVideoImageFilePath error:nil];
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime requestedTime = CMTimeMake(1, 60);
    CGImageRef imgRef = nil;
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    if (imgRef != nil) {
        UIImage *flagImage = [UIImage imageWithCGImage:imgRef];
        _publishNormalPostModel.proCorverVideoImageFilePath = [XTCSourceCompressManager compressImagesByImage:@[flagImage]].firstObject;
//        _publishNormalPostModel.proCorverVideoImageFilePath = [Post compressed:@[flagImage] isVr:NO][0];
        return flagImage;
    }else {
        return nil;
    }
    
}

- (void)playVieoButtonClick {
    [_xlVideoPlayer destroyPlayer];
    _xlVideoPlayer = nil;
    PublishProVideoCell *cell = [_publishProTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    _xlVideoPlayer = [[XLVideoPlayer alloc] init];
    _xlVideoPlayer.frame = cell.selectVideoButton.bounds;
    _xlVideoPlayer.videoUrl = _publishNormalPostModel.proVideoFilePath;
    _xlVideoPlayer.userInteractionEnabled = true;
    _xlVideoPlayer.currentView = cell.selectVideoButton;
    [cell.selectVideoButton addSubview:_xlVideoPlayer];
    cell.playVideoButton.hidden = YES;
}

#pragma mark - 更换pro封皮
- (void)tapGesCorverImage {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPublishPicker" bundle:nil];
    XTCPublishPickerViewController *publishPickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPublishPickerViewController"];
    // 不是发布，直接选择
    publishPickerVC.isPublishSelect = NO;
    publishPickerVC.isSinglePick = YES;
    publishPickerVC.isProSingleSelect = YES;
    publishPickerVC.selectPublishSourceCallBack = ^(NSMutableArray *assetArray, NSMutableArray *photoArray, SelectPublishTypeEnum selectPublishTypeEnum) {
        if (photoArray.count) {
            self.corverProImage = photoArray[0];
            self.corverTitleChinaLabel.hidden = YES;
            self.corverTitleEnglishLabel.hidden = YES;
            NSFileManager *man = [NSFileManager defaultManager];
            if (self.publishNormalPostModel.proCorverImageFilePath && self.publishNormalPostModel.proCorverImageFilePath.length) {
                [man removeItemAtPath:self.publishNormalPostModel.proCorverImageFilePath error:nil];
            }
            self.publishNormalPostModel.proCorverImageFilePath  = [XTCSourceCompressManager compressImagesByImage:@[photoArray[0]]].firstObject;
        } else {
            
        }
        self.corverImageView.image = photoArray.count ? self.corverProImage : [UIImage imageNamed:@"pro_grid"];
    };
    XTCBaseNavigationController *pickerNav = [[XTCBaseNavigationController alloc] initWithRootViewController:publishPickerVC];
    [self presentViewController:pickerNav animated:YES completion:^{
        
    }];
}

#pragma mark -  进入下一页
- (void)nextButtonClick {
    [self.view endEditing:YES];
    if (_corverProImage == nil) {
        [self alertMessage:@"请选择封面照片"];
        return;
    }
    if (_publishNormalPostModel.posttitle.length && _publishNormalPostModel.posttitle) {
        
    } else {
        [self alertMessage:@"请输入标题"];
        return;
    }
    if (_videoCorverImage == nil) {
        [self alertMessage:@"请选择视频"];
    } else {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"publish" bundle:nil];
        ProPushSecViewController *proPushSecVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProPushSecViewController"];
        proPushSecVC.hidesBottomBarWhenPushed = YES;
        proPushSecVC.proDetailModel = _publishNormalPostModel;
        proPushSecVC.proPublishNumber = _proPublishNumber;
        proPushSecVC.isRoadBook = _isPublishRoadBook;
        [self.navigationController pushViewController:proPushSecVC animated:YES];
    }
    
}

#pragma mark - 删除视频
- (void)deleteVideoButtonClick {
    NSFileManager *man = [NSFileManager defaultManager];
    if (_publishNormalPostModel.proVideoFilePath && _publishNormalPostModel.proVideoFilePath.length) {
        [man removeItemAtPath:_publishNormalPostModel.proVideoFilePath error:nil];
    }
    if (_publishNormalPostModel.proCorverVideoImageFilePath && _publishNormalPostModel.proCorverVideoImageFilePath.length) {
        [man removeItemAtPath:_publishNormalPostModel.proCorverVideoImageFilePath error:nil];
    }
    [_xlVideoPlayer destroyPlayer];
    _xlVideoPlayer = nil;
    [_xlVideoPlayer removeFromSuperview];
    _videoCorverImage = nil;
    [_publishProTableView reloadData];
}
- (IBAction)addLinkWebAddressClick:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishLinkUrl" bundle:nil];
    PublishLinkUrlViewController *publishLinkUrlVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishLinkUrlViewController"];
    publishLinkUrlVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
    publishLinkUrlVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    if ([GlobalData sharedInstance].art_link && [GlobalData sharedInstance].art_link.length) {
        publishLinkUrlVC.urlTextView.editable = NO;
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
        self.publishNormalPostModel.artLinkVerifyFinish = YES;
        self.publishNormalPostModel.art_link = linkUrl;
        [self.publishProTableView reloadData];
    };
    [self presentViewController:publishLinkUrlVC animated:YES completion:^{
        
    }];
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
