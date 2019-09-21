//
//  CloudSaveViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "CloudSaveViewController.h"
#import "XTCAlbum-Swift.h"
#import "ProDetailShowViewController.h"

@interface CloudSaveViewController () {
    CGAffineTransform _transform; // 缩放时用到
    CGFloat _maxScale; // 最大缩放
    CGFloat _minScale; // 最小缩放
    NSIndexPath *_showFinalStreamIndex;
    BOOL _isHandle;
    BOOL _defaultShowFlag;
    BOOL _isZoomStatus;
}

@end

@implementation CloudSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isZoomStatus = NO;
    _defaultShowFlag = YES;
    _selectBottomIndex = 0;
    [self createXTCUserHomeFoldScreenBottomViewUI];
    [self loadUserInfor];
    [_searchButton addTarget:self action:@selector(showUserPageSearch) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    SideRefreshHeader *refreshHeader = [SideRefreshHeader refreshWithLoadAction:^{
        [weakSelf loadStreamData:YES];
    }];
    refreshHeader.hideMessage = YES;//隐藏提示
    NSMutableArray *loadingImages = [NSMutableArray array];
    for(int i = 1; i <= 8; i++) {
        UIImage *loadingImg = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%d", i]];
        if(loadingImg) {
            [loadingImages addObject:loadingImg];
        }
    }
    refreshHeader.loadingImages = loadingImages;
    self.streamCollectionView.sideRefreshHeader = refreshHeader;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"clear_image"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.shadowImage = [GlobalData createImageWithColor:[UIColor clearColor]];
    self.backButton.hidden = YES;
}

#pragma mark - 载入用户信息
- (void)loadUserInfor {
    __weak typeof(self) weakSelf = self;
    XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
    requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
    requestModel.token = [GlobalData sharedInstance].userModel.token;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestUserindexEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            weakSelf.userHomeIndexResponseModel = object;
            weakSelf.bottomTagArray = [[NSMutableArray alloc] init];
            // 全部
            weakSelf.allRequestModel = [[ScrollstreamRequestModel alloc] init];
            weakSelf.allRequestModel.token = [GlobalData sharedInstance].userModel.token;
            weakSelf.allRequestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
            weakSelf.allRequestModel.page = @"0";
            weakSelf.allRequestModel.type = @"";
            weakSelf.allRequestModel.showTitle = @"全部";
            weakSelf.allRequestModel.tags = @"";
            weakSelf.allRequestModel.keyword = @"";
            weakSelf.allRequestModel.streamingArray = [[NSMutableArray alloc] init];
            [weakSelf.bottomTagArray addObject:weakSelf.allRequestModel];
            for (NSString *flagStr in weakSelf.userHomeIndexResponseModel.userTagsResponseModel.show_tags) {
                ScrollstreamRequestModel *tagRequestModel = [[ScrollstreamRequestModel alloc] init];
                tagRequestModel.token = [GlobalData sharedInstance].userModel.token;
                tagRequestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
                tagRequestModel.page = @"0";
                tagRequestModel.type = weakSelf.userHomeIndexResponseModel.userTagsResponseModel.type;
                tagRequestModel.showTitle = flagStr;
                tagRequestModel.tags = flagStr;
                tagRequestModel.keyword = flagStr;
                tagRequestModel.streamingArray = [[NSMutableArray alloc] init];
                [weakSelf.bottomTagArray addObject:tagRequestModel];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tagCollectionView reloadData];
            });
            [weakSelf loadStreamData:YES];
        } else {
            
        }
    }];
    
}


#pragma mark - 获取卷轴流数据
- (void)loadStreamData:(BOOL)isHeader {
    __weak typeof(self) weakSelf = self;
    ScrollstreamRequestModel *requestModel;
    if (_selectBottomIndex == 0) {
        requestModel = _allRequestModel;
    } else {
        requestModel = _bottomTagArray[_selectBottomIndex];
    }
    if (isHeader) {
        requestModel.page = @"0";
    } else {
        int page = [requestModel.page intValue]+1;
        requestModel.page = [NSString stringWithFormat:@"%d", page];
    }
    _isLoading = YES;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestUserScrollStreamEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        weakSelf.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.streamCollectionView.sideRefreshHeader endLoading];
        });
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            ScrollstreamResponseModel *responseModel = object;
            requestModel.more_page = responseModel.morePage;
            if (isHeader) {
                requestModel.streamingArray = responseModel.list;
            } else {
                [requestModel.streamingArray addObjectsFromArray:responseModel.list];
            }
            [weakSelf.streamCollectionView reloadData];
            [weakSelf.streamBgCollectionView reloadData];
        } else {
            
        }
    }];
}


- (void)createXTCUserHomeFoldScreenBottomViewUI {
    // 前置collection
    _streamingScrollLayout = [[SStreamingScrollLayout alloc] init];
    _streamingScrollLayout.rowCount = [NBZUtil gainStringNumber];
    _streamingScrollLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _streamingScrollLayout.minimumInteritemSpacing = 2;
    _streamingScrollLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _streamingScrollLayout.containerHeight = kScreenHeight-44-kAppStatusBar-49-kBottom_iPhoneX;
    } else {
        _streamingScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    _streamCollectionView.collectionViewLayout = _streamingScrollLayout;
    [_streamCollectionView registerClass:[UserHomeStreamCell class] forCellWithReuseIdentifier:@"UserHomeStreamCellName"];
    _streamCollectionView.showsHorizontalScrollIndicator = NO;
    _streamCollectionView.backgroundColor = [UIColor whiteColor];
    
    // 后置collection
    _streamingBgScrollLayout = [[SStreamingScrollLayout alloc] init];
    _streamingBgScrollLayout.rowCount = [NBZUtil gainStringNumber];
    _streamingBgScrollLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _streamingBgScrollLayout.minimumInteritemSpacing = 2;
    _streamingBgScrollLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _streamingBgScrollLayout.containerHeight = kScreenHeight-44-kAppStatusBar-49-kBottom_iPhoneX;
    } else {
        _streamingBgScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    _streamBgCollectionView.collectionViewLayout = _streamingBgScrollLayout;
    [_streamBgCollectionView registerClass:[UserHomeStreamCell class] forCellWithReuseIdentifier:@"UserHomeStreamCellName"];
    _streamBgCollectionView.showsHorizontalScrollIndicator = NO;
    _streamBgCollectionView.backgroundColor = [UIColor whiteColor];
    
    [self addSystemLineNumTapGes];
    
    
    
    UICollectionViewFlowLayout *bottomFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    bottomFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _tagCollectionView.collectionViewLayout = bottomFlowLayout;
    _tagCollectionView.delegate = self;
    _tagCollectionView.dataSource = self;
    _tagCollectionView.showsHorizontalScrollIndicator = NO;
    _tagCollectionView.backgroundColor = [UIColor whiteColor];
    [_tagCollectionView registerClass:[UserHeaderTagCollectionViewCell class] forCellWithReuseIdentifier:@"UserHeaderTagCollectionViewCellName"];
    if (@available(iOS 11.0, *)) {
        _streamCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tagCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeStreamStreamingLineNum:)];
    [_streamCollectionView addGestureRecognizer:pinchGestureRecognizer];
    
    UIPinchGestureRecognizer *backPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackStreamStreamingLineNum:)];
    [_streamBgCollectionView addGestureRecognizer:backPinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeHomeStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isHandle = NO;
        _isZoomStatus = YES;
        _transform = _streamCollectionView.transform;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamCollectionView indexPathForItemAtPoint:flagPoint];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamingScrollLayout.rowCount <= kStreamSystemMin) {
                // 最小三行
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamingBgScrollLayout.rowCount == _streamingScrollLayout.rowCount-1) {
                    
                } else {
                    DDLogInfo(@"执行放大变换了");
                    _streamingBgScrollLayout.rowCount = _streamingScrollLayout.rowCount-1;
                    [_streamBgCollectionView reloadData];
                    [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamingScrollLayout.rowCount/(_streamingScrollLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _streamCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _streamCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _streamCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamingScrollLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamingBgScrollLayout.rowCount == _streamingScrollLayout.rowCount+1) {
                    
                } else {
                    _streamingBgScrollLayout.rowCount = _streamingScrollLayout.rowCount+1;
                    [_streamBgCollectionView reloadData];
                    [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*_streamingScrollLayout.rowCount/_streamingBgScrollLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _streamCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamCollectionView.transform = tr;
                }
                _streamCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _streamCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _contentBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _streamCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamCollectionView.frame = _contentBgView.bounds;
        _streamCollectionView.alpha = 1;
        
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = NO;
                [_contentBgView bringSubviewToFront:_streamBgCollectionView];
                [NBZUtil setStreamNumber:_streamingBgScrollLayout.rowCount];
                _streamingScrollLayout.rowCount = _streamingBgScrollLayout.rowCount;
                [_streamCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}

- (void)changeBackStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isHandle = NO;
        _isZoomStatus = YES;
        _transform = _streamBgCollectionView.transform;
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamBgCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamBgCollectionView];
        // 获取到要展示cell index
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamBgCollectionView indexPathForItemAtPoint:flagPoint];
        [_streamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamingBgScrollLayout.rowCount <= kStreamSystemMin) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamingScrollLayout.rowCount == _streamingBgScrollLayout.rowCount-1) {
                    
                } else {
                    _streamingScrollLayout.rowCount = _streamingBgScrollLayout.rowCount-1;
                    [_streamCollectionView reloadData];
                    [_streamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamingBgScrollLayout.rowCount/(_streamingBgScrollLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _streamBgCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamBgCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _streamBgCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _streamBgCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamingBgScrollLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamingScrollLayout.rowCount == _streamingBgScrollLayout.rowCount+1) {
                    
                } else {
                    _streamingScrollLayout.rowCount = _streamingBgScrollLayout.rowCount+1;
                    [_streamCollectionView reloadData];
                    [_streamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*(_streamingBgScrollLayout.rowCount-1)/_streamingBgScrollLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _streamBgCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamBgCollectionView.transform = tr;
                }
                _streamBgCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _streamBgCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _contentBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _streamCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamCollectionView.frame = _contentBgView.bounds;
        _streamCollectionView.alpha = 1;
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = YES;
                [_contentBgView bringSubviewToFront:_streamCollectionView];
                [NBZUtil setStreamNumber:_streamingScrollLayout.rowCount];
                _streamingBgScrollLayout.rowCount = _streamingScrollLayout.rowCount;
                [_streamBgCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _streamCollectionView) {
        if (_selectBottomIndex == 0) {
            return _allRequestModel.streamingArray.count;
        } else {
            ScrollstreamRequestModel *requestModel = _bottomTagArray[_selectBottomIndex];
            return requestModel.streamingArray.count;
        }
    } else if (collectionView == _streamBgCollectionView) {
        if (_selectBottomIndex == 0) {
            return _allRequestModel.streamingArray.count;
        } else {
            ScrollstreamRequestModel *requestModel = _bottomTagArray[_selectBottomIndex];
            return requestModel.streamingArray.count;
        }
    } else {
        return _bottomTagArray.count;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _streamCollectionView) {
        if (_selectBottomIndex == 0) {
            Post *postModel = _allRequestModel.streamingArray[indexPath.item];
            return CGSizeMake([postModel.postWidth floatValue], [postModel.postHeight floatValue]);
        } else {
            ScrollstreamRequestModel *requestModel = _bottomTagArray[_selectBottomIndex];
            Post *postModel = requestModel.streamingArray[indexPath.item];
            return CGSizeMake([postModel.postWidth floatValue], [postModel.postHeight floatValue]);
        }
    } else if (collectionView == _streamBgCollectionView) {
        if (_selectBottomIndex == 0) {
            Post *postModel = _allRequestModel.streamingArray[indexPath.item];
            return CGSizeMake([postModel.postWidth floatValue], [postModel.postHeight floatValue]);
        } else {
            ScrollstreamRequestModel *requestModel = _bottomTagArray[_selectBottomIndex];
            Post *postModel = requestModel.streamingArray[indexPath.item];
            return CGSizeMake([postModel.postWidth floatValue], [postModel.postHeight floatValue]);
        }
    } else {
        ScrollstreamRequestModel *requestModel = _bottomTagArray[indexPath.item];
        CGSize titleSize = [requestModel.showTitle sizeWithFont:[UIFont fontWithName:kHelvetica size:18] constrainedToSize:CGSizeMake(MAXFLOAT, 40)];
        return CGSizeMake(titleSize.width + 20, 40);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _streamCollectionView) {
        ScrollstreamRequestModel *requestModel;
        if (_selectBottomIndex == 0) {
            requestModel  = _allRequestModel;
        } else {
            requestModel  = _bottomTagArray[_selectBottomIndex];
        }
        Post *postModel = requestModel.streamingArray[indexPath.item];
        UserHomeStreamCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserHomeStreamCellName" forIndexPath:indexPath];
        [cell.postImageView sd_setImageWithURL:[NSURL URLWithString:postModel.postThumbnail] placeholderImage:nil options:SDWebImageRetryFailed];
        cell.titleLabel.text = postModel.postTitle;
        cell.typeImageView.hidden = NO;
        if ([postModel.postType isEqualToString:@"video"]) {
            cell.typeImageView.image = [UIImage imageNamed:@"stream_video_type"];
        } else if ([postModel.postType isEqualToString:@"vr"]) {
            cell.typeImageView.image = [UIImage imageNamed:@"stream_vr_type"];
        } else if ([postModel.postType isEqualToString:@"mix"]) {
            cell.typeImageView.image = [UIImage imageNamed:@"stream_pro_type"];
        } else {
            cell.typeImageView.hidden = YES;
        }
        return cell;
    } else if (collectionView == _streamBgCollectionView) {
        ScrollstreamRequestModel *requestModel;
        if (_selectBottomIndex == 0) {
            requestModel  = _allRequestModel;
        } else {
            requestModel  = _bottomTagArray[_selectBottomIndex];
        }
        Post *postModel = requestModel.streamingArray[indexPath.item];
        UserHomeStreamCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserHomeStreamCellName" forIndexPath:indexPath];
        [cell.postImageView sd_setImageWithURL:[NSURL URLWithString:postModel.postThumbnail] placeholderImage:nil options:SDWebImageRetryFailed];
        cell.titleLabel.text = postModel.postTitle;
        cell.typeImageView.hidden = NO;
        if ([postModel.postType isEqualToString:@"video"]) {
            cell.typeImageView.image = [UIImage imageNamed:@"stream_video_type"];
        } else if ([postModel.postType isEqualToString:@"vr"]) {
            cell.typeImageView.image = [UIImage imageNamed:@"stream_vr_type"];
        } else if ([postModel.postType isEqualToString:@"mix"]) {
            cell.typeImageView.image = [UIImage imageNamed:@"stream_pro_type"];
        } else {
            cell.typeImageView.hidden = NO;
        }
        return cell;
    } else {
        UserHeaderTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserHeaderTagCollectionViewCellName" forIndexPath:indexPath];
        
        ScrollstreamRequestModel *requestModel = _bottomTagArray[indexPath.item];
        cell.tagLabel.text = requestModel.showTitle;
        if (indexPath.item == _selectBottomIndex) {
            cell.selectImageView.hidden = NO;
            cell.tagLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
        } else {
            cell.selectImageView.hidden = YES;
            cell.tagLabel.font = [UIFont fontWithName:kHelvetica size:18];
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
}



- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 3, 0, 5);
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isZoomStatus) {
        return;
    }
    if (collectionView == _tagCollectionView) {
        // 标签切换
        if (indexPath.item == _selectBottomIndex) {
            
        } else {
            _selectBottomIndex = indexPath.item;
            [_tagCollectionView reloadData];
            ScrollstreamRequestModel *requestModel = _bottomTagArray[_selectBottomIndex];
            if (requestModel.streamingArray.count) {
                [_streamCollectionView reloadData];
            } else {
                [self loadStreamData:YES];
            }
        }
    } else {
        // 进入帖子详情
        ScrollstreamRequestModel *scrollstreamRequestModel;
        if (_selectBottomIndex == 0) {
            scrollstreamRequestModel = _allRequestModel;
        } else {
            scrollstreamRequestModel = _bottomTagArray[_selectBottomIndex];
        }
        Post *postModel = scrollstreamRequestModel.streamingArray[indexPath.item];
        if ([postModel.postType isEqualToString:@"photo"] || [postModel.postType isEqualToString:@"multimedia"]) {
            PostDetailPhotoViewController *postDetailPhotoVC = [[UIStoryboard storyboardWithName:@"PostDetailPhoto" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailPhotoViewController"];
            postDetailPhotoVC.postDetailId = postModel.postId;
            [self.navigationController pushViewController:postDetailPhotoVC animated:YES];
        } else if ([postModel.postType isEqualToString:@"video"]) {
            PostDetailPhotoViewController *postDetailVideoVC = [[UIStoryboard storyboardWithName:@"PostDetailPhoto" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailPhotoViewController"];
            postDetailVideoVC.postDetailId = postModel.postId;
            [self.navigationController pushViewController:postDetailVideoVC animated:YES];
        } else if ([postModel.postType isEqualToString:@"mix"]) {
            ProDetailShowViewController *postDetailVideoVC = [[UIStoryboard storyboardWithName:@"ProDetailShow" bundle:nil] instantiateViewControllerWithIdentifier:@"ProDetailShowViewController"];
            postDetailVideoVC.postId = postModel.postId;
            [self.navigationController pushViewController:postDetailVideoVC animated:YES];
        } else {
            // VR
            VRDetailViewController *postDetailVideoVC = [[UIStoryboard storyboardWithName:@"detail" bundle:nil] instantiateViewControllerWithIdentifier:@"VRDetailViewController"];
            postDetailVideoVC.postId = postModel.postId;
            [self.navigationController pushViewController:postDetailVideoVC animated:YES];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _streamCollectionView || collectionView == _streamBgCollectionView) {
        ScrollstreamRequestModel *scrollstreamRequestModel;
        if (_selectBottomIndex == 0) {
            scrollstreamRequestModel = _allRequestModel;
        } else {
            scrollstreamRequestModel = _bottomTagArray[_selectBottomIndex];
        }
        if (scrollstreamRequestModel.streamingArray.lastObject == nil) {
            return;
        }
        if (_isLoading) {
            return;
        }
        if (indexPath.item > scrollstreamRequestModel.streamingArray.count - 5) {
            if ([scrollstreamRequestModel.more_page intValue]) {
                [self loadStreamData:NO];
            } else {
                
            }
        }
    }
}

#pragma mark - 搜索页
- (void)showUserPageSearch {
    ScrollstreamRequestModel *bottomRequestModel;
    ScrollstreamRequestModel *postBottomRequestModel;
    if (_bottomTagArray.count) {
        if (self.selectBottomIndex >= 0) {
            bottomRequestModel = _bottomTagArray[self.selectBottomIndex];
        } else {
            
        }
        postBottomRequestModel = _bottomTagArray.lastObject;
    } else {
        
    }
    
    self.selectBottomIndex = 0;
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"UserHomePageSearch" bundle:nil];
    UserHomePageSearchViewController *homeSearchVC = [storyBoard instantiateViewControllerWithIdentifier:@"UserHomePageSearchViewController"];
    homeSearchVC.delegate = self;
    UserTagsResponseModel *userTagsResponseModel = _userHomeIndexResponseModel.userTagsResponseModel;
    UserTagsResponseModel *flagModel = [[UserTagsResponseModel alloc] init];
    flagModel.show_tags = userTagsResponseModel.show_tags;
    flagModel.hide_tags = userTagsResponseModel.hide_tags;
    homeSearchVC.userTagsResponseModel = flagModel;
    homeSearchVC.userHomeShowTagBlock = ^(NSMutableArray *showTagArray, NSMutableArray *hideTagArray) {
        weakSelf.userHomeIndexResponseModel.userTagsResponseModel.show_tags = showTagArray;
        weakSelf.userHomeIndexResponseModel.userTagsResponseModel.hide_tags = hideTagArray;
        weakSelf.bottomTagArray = [[NSMutableArray alloc] init];
        for (int i=0; i < showTagArray.count; i++) {
            NSString *flagStr = showTagArray[i];
            ScrollstreamRequestModel *requestModel = [[ScrollstreamRequestModel alloc] init];
            requestModel.token = [GlobalData sharedInstance].userModel.token;
            requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
            requestModel.page = @"0";
            requestModel.type = weakSelf.userHomeIndexResponseModel.userTagsResponseModel.type;
            requestModel.showTitle = flagStr;
            requestModel.tags = flagStr;
            requestModel.keyword = flagStr;
            if (bottomRequestModel) {
                if ([bottomRequestModel.tags isEqualToString:requestModel.tags]) {
                    requestModel.streamingArray = bottomRequestModel.streamingArray;
                    self.selectBottomIndex = i;
                } else {
                    requestModel.streamingArray = [[NSMutableArray alloc] init];
                }
            } else {
                requestModel.streamingArray = [[NSMutableArray alloc] init];
            }
            [weakSelf.bottomTagArray addObject:requestModel];
        }
        if ([postBottomRequestModel.type isEqualToString:@"post"]) {
            [weakSelf.bottomTagArray addObject:postBottomRequestModel];
            if ([bottomRequestModel.type isEqualToString:postBottomRequestModel.type]) {
                weakSelf.selectBottomIndex = weakSelf.bottomTagArray.count-1;
            } else {
                
            }
        } else {
            
        }
        [weakSelf.tagCollectionView reloadData];
        ScrollstreamRequestModel *selectBottomRequestModel = weakSelf.bottomTagArray[weakSelf.selectBottomIndex];
        if (selectBottomRequestModel.streamingArray.count) {
            [weakSelf.streamCollectionView reloadData];
             [weakSelf.streamBgCollectionView reloadData];
        } else {
            [weakSelf loadStreamData:YES];
        }
    };
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.7;
    transition.type = kCATransitionFade;
    transition.subtype = kCAAlignmentLeft;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self presentViewController:homeSearchVC animated:NO completion:nil];
}

- (void)userHomeSearchByKeyWord:(NSString *)keyWord {
    _selectBottomIndex = 0;
    for (int i = 0; i<_bottomTagArray.count; i++) {
        ScrollstreamRequestModel *requestModel = _bottomTagArray[i];
        if ([requestModel.tags isEqualToString:keyWord]) {
            _selectBottomIndex = i;
            [self.tagCollectionView reloadData];
            [self.tagCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            if (requestModel.streamingArray.count) {
                [_streamCollectionView reloadData];
            } else {
                [self loadStreamData:YES];
            }
            break;
        } else {
            
        }
    }
}

- (void)userHomeSearchPostByKeyWord:(NSString *)keyWord {
    ScrollstreamRequestModel *flagRequestModel = [[ScrollstreamRequestModel alloc] init];
    flagRequestModel.token = [GlobalData sharedInstance].userModel.token;
    flagRequestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
    flagRequestModel.page = @"0";
    flagRequestModel.type = @"post";
    flagRequestModel.showTitle = keyWord;
    flagRequestModel.tags = keyWord;
    flagRequestModel.keyword = keyWord;
    flagRequestModel.streamingArray = [[NSMutableArray alloc] init];
    if (_bottomTagArray.count) {
        ScrollstreamRequestModel *requestModel = _bottomTagArray.lastObject;
        if ([requestModel.type isEqualToString:@"post"]) {
            [_bottomTagArray removeLastObject];
        } else {
            
        }
        [_bottomTagArray addObject:flagRequestModel];
    } else {
        
    }
    _selectBottomIndex = _bottomTagArray.count-1;
    [_tagCollectionView reloadData];
    [_tagCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(_bottomTagArray.count-1) inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    [self loadStreamData:YES];
    
}

- (IBAction)popButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    DDLogInfo(@"云博内存释放");
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
