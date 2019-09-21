//
//  ProDetailShowViewController.m
//  vs
//
//  Created by Mac on 2018/9/6.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "ProDetailShowViewController.h"
#import "XTCAlbum-Swift.h"
#import "PublishTagView.h"
#import "XTCShareHelper.h"

@interface ProDetailShowViewController () {
    BOOL _isShowDesc;
    float oldContentOffsetY;
    float contentOffsetY;
    NSInteger _playAudioIndex;
    NSIndexPath *_selectIndex;
    UIView *_topView;
    UIView *_bottomView;
}

@end

@implementation ProDetailShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    _isEnterMap = NO;
    self.view.backgroundColor = [UIColor blackColor];
    _playAudioIndex = 0;
    _proTableView.rowHeight = UITableViewAutomaticDimension;
    _proTableView.estimatedRowHeight = 50.0f;
    _proTableView.estimatedSectionHeaderHeight = 0;
    _proTableView.estimatedSectionFooterHeight = 0;
    _proTableView.backgroundColor = [UIColor clearColor];
    _proTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _proTableView.showsVerticalScrollIndicator = NO;
    
    
    
    if (@available(iOS 11.0, *)) {
        _proTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.frame = _proTableView.bounds;
    _proTableView.backgroundView = _bgImageView;
    
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor blackColor];
    [_proTableView.backgroundView addSubview:_topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self->_bgImageView);
        make.height.mas_equalTo(0.1);
    }];
    
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor blackColor];
    [_proTableView.backgroundView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self->_bgImageView);
        make.height.mas_equalTo(0.1);
    }];
    
    _isShowDesc = NO;
    
    [self createProShowDetailBottomView];
    [self loadProDetailAboutData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.playingCell) {
        [self.playingCell.picView jp_stopPlay];
    }
    [self playerManagerVideoFinish];
}

#pragma mare - 载入数据
- (void)loadProDetailAboutData {
    __weak typeof(self) weakSelf = self;
    RequestGetdetailModel *getdetailModelRequest = [[RequestGetdetailModel alloc] init];
    getdetailModelRequest.user_id = [GlobalData sharedInstance].userModel.user_id;
    getdetailModelRequest.token = [GlobalData sharedInstance].userModel.token;
    getdetailModelRequest.post_id = _postId;
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestProDetailEnum byRequestDict:getdetailModelRequest callBack:^(id object, RSResponseErrorModel *errorModel) {
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            weakSelf.proDetail = object;
            if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
                [weakSelf.bgImageView sd_setImageWithURL:[NSURL URLWithString:weakSelf.proDetail.advert[@"url_for_pad"]] placeholderImage:nil options:SDWebImageRetryFailed];
            } else {
                [weakSelf.bgImageView sd_setImageWithURL:[NSURL URLWithString:weakSelf.proDetail.advert[@"url"]] placeholderImage:nil options:SDWebImageRetryFailed];
            }
            
            weakSelf.navigationItem.title = weakSelf.proDetail.posttitle;
            
            [GlobalData sharedInstance].proFlagScrollIndexArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < self->_proDetail.detailed.count; i++) {
                [[GlobalData sharedInstance].proFlagScrollIndexArray addObject:@"0"];
            }
            self.isShowLocalMap = NO;
            if (self.proDetail.lat.length && self.proDetail.lat && self.proDetail.lng.length && self.proDetail.lng) {
                self.isShowLocalMap = YES;
            } else {
                
            }
            [self createFooterTagView];
            
            [weakSelf.proTableView reloadData];
        } else {
            [weakSelf alertMessage:errorModel.errorString];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.proDetail ? self.proDetail.detailed.count+1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        NSDictionary *flagUrlDict = _proDetail.detailed[section-1];
        NSArray *images = flagUrlDict[@"images"];
        return  images.count + 2;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        return kScreenWidth*9.0/16;
    } else {
        if (indexPath.row != 0 && indexPath.section > 0) {
            NSDictionary *flagUrlDict = _proDetail.detailed[indexPath.section-1];
            NSArray *images = flagUrlDict[@"images"];
            if (indexPath.row <= images.count) {
                
            } else {
                return 10.0f;
            }
        } else {
            
        }
        
        return UITableViewAutomaticDimension;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *identifier = @"playerCell";
            ZFPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[ZFPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.backgroundColor = [UIColor blackColor];
            cell.picView.contentMode = UIViewContentModeScaleAspectFill;
            cell.picView.clipsToBounds = YES;
            [cell.picView sd_setImageWithURL:[NSURL URLWithString:self.proDetail.videophoto_url] placeholderImage:nil options:SDWebImageRetryFailed];
            __weak typeof(self) weakSelf = self;
            cell.playBlock = ^(UIButton *btn){
                [weakSelf playPostVideo:indexPath];
            };
            [cell.picView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell.contentView);
            }];
            
            [cell.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.picView);
                make.right.equalTo(cell.picView);
                make.bottom.equalTo(cell.contentView);
                make.height.mas_equalTo(0);
            }];
            _playingCell = cell;
            cell.backgroundColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (indexPath.row == 1) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.proDetail.desc];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:7];
            paragraphStyle.alignment = NSTextAlignmentLeft;
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.string.length)];
            [attrStr addAttribute:NSFontAttributeName value:kSystemNormalFont range:NSMakeRange(0, attrStr.string.length)];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrStr.string.length)];
            static NSString *cellName = @"videoDescCellName";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
            }
            cell.textLabel.attributedText = attrStr;
            cell.backgroundColor = [UIColor blackColor];
            if (_isShowDesc) {
                cell.textLabel.numberOfLines = 0;
            } else {
                cell.textLabel.numberOfLines = 2;
            }
            cell.backgroundColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            static NSString *cellName = @"ProShowDetailUserInforCellName";
            ProShowDetailUserInforCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[ProShowDetailUserInforCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell insertDataToUserInforCell:self.proDetail];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor blackColor];
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            static NSString *cellName = @"ProDetailVRCellName";
            ProDetailVRCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[ProDetailVRCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
            }
            [cell insertDataToVRCell:_proDetail.detailed[indexPath.section-1]];
            NSDictionary *dict = _proDetail.detailed[indexPath.section-1];
            [cell.vrBgImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"vr_thumbnail"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                [cell.panoramaView setImageWithName:image];
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            cell.vrBgImageView.hidden = YES;
            cell.tag = indexPath.section-1;
            cell.vrBgView.backgroundColor = [UIColor clearColor];
            cell.audioButton.tag = indexPath.section;
            [cell.audioButton addTarget:self action:@selector(playAudioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.layer.cornerRadius = 6;
            cell.layer.masksToBounds = YES;
            cell.backgroundColor = [UIColor whiteColor];
            
            UITapGestureRecognizer *vrTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vrTapGesClick:)];
            cell.vrBgView.tag = indexPath.section-1;
            [cell.vrBgView addGestureRecognizer:vrTapGes];
            if (cell.audioButton.hidden) {
                
            } else {
                [self controlAudioAnimationByButton:cell.audioButton];
            }
            cell.audioButton.adjustsImageWhenHighlighted = NO;
            
            return cell;
        } else {
            NSDictionary *flagUrlDict = _proDetail.detailed[indexPath.section-1];
            NSArray *images = flagUrlDict[@"images"];
            if (indexPath.row <= images.count) {
                static NSString *cellName = @"DetailNormalCellName";
                DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[DetailNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                    
                }
                NSDictionary *flagImageDict = images[indexPath.row-1];
                if (indexPath.row == images.count) {
                    [cell imageObjectByImageDict:flagImageDict byLast:YES];
                    cell.backgroundColor = [UIColor redColor];
                } else {
                    [cell imageObjectByImageDict:flagImageDict byLast:NO];
                    cell.backgroundColor = [UIColor redColor];
                }
                cell.imageDescLabel.textColor = [UIColor whiteColor];
                NSString *imageUrl = flagImageDict[@"thumbnail_image"] != nil ? flagImageDict[@"thumbnail_image"] : flagImageDict[@"image"];
                 [cell.photoView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (indexPath.row == 1) {
                    cell.topLayoutConstraint.constant = 15;
                } else {
                    cell.topLayoutConstraint.constant = 5;
                }
                cell.backgroundColor = [UIColor blackColor];
                return cell;
            } else {
                static NSString *cellName = @"cellName";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                }
                cell.textLabel.text = @"";
                cell.backgroundColor = [UIColor blackColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ProDetailVRCell class]]) {
        ProDetailVRCell *panoCell = (ProDetailVRCell *)cell;
        [panoCell willBeDisplayed:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ProDetailVRCell class]]) {
        ProDetailVRCell *panoCell = (ProDetailVRCell *)cell;
        [panoCell didStopDisplayed:indexPath.row];
    }
}

- (void)playPostVideo:(NSIndexPath *)indexPath {
    [self.playingCell.picView jp_playVideoWithURL:[NSURL URLWithString:self.proDetail.video_url]
                               bufferingIndicator:nil controlView:nil progressView:nil configurationCompletion:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                   
                               }];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        if (self.proDetail.advert[@"url"] == nil || [self.proDetail.advert[@"url"] isEqualToString:@""]) {
            return 6.0f;
        } else {
            return 33+kScreenWidth*0.4+10+15;
        }
    } else {
        return 6.0f;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor blackColor];
    if (section == 2) {
        if (self.proDetail.advert[@"url"] == nil || [self.proDetail.advert[@"url"] isEqualToString:@""]) {
            
        } else {
            headerView.backgroundColor = [UIColor clearColor];
            headerView.frame = CGRectMake(0, 0, kScreenWidth, 33+kScreenWidth*0.4+10+15);
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProScrollAdvertView" owner:self options:nil];
            ProScrollAdvertView *discoverUserHeaderView = [nib objectAtIndex:0];
            discoverUserHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 33+kScreenWidth*0.4+10);
            discoverUserHeaderView.backgroundColor = [UIColor whiteColor];
            discoverUserHeaderView.titleLabel.text = self.proDetail.advert[@"title"];
            [headerView addSubview:discoverUserHeaderView];
            
            UITapGestureRecognizer *tapAdverTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAdverTapClick)];
            [discoverUserHeaderView addGestureRecognizer:tapAdverTap];
            
            CGRect myRect = CGRectMake(5, 33, kScreenWidth-10, kScreenWidth*0.4);
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:discoverUserHeaderView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(6,6)];
            
            UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:myRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(20, 20)];
            [maskPath appendPath:circlePath];
            [maskPath setUsesEvenOddFillRule:YES];
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = discoverUserHeaderView.bounds;
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillRule = kCAFillRuleEvenOdd;
            discoverUserHeaderView.layer.mask = maskLayer;
            
            UIView *leftView = [[UIView alloc] init];
            leftView.backgroundColor = [UIColor blackColor];
            [headerView addSubview:leftView];
            [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.top.equalTo(headerView);
                make.right.equalTo(discoverUserHeaderView.mas_left).with.offset(5);
            }];
            
            UIView *rightView = [[UIView alloc] init];
            rightView.backgroundColor = [UIColor blackColor];
            [headerView addSubview:rightView];
            [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.top.equalTo(headerView);
                make.left.equalTo(discoverUserHeaderView.mas_right).with.offset(-5);
            }];
            
            UIView *bottomView = [[UIView alloc] init];
            bottomView.backgroundColor = [UIColor blackColor];
            [headerView addSubview:bottomView];
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(discoverUserHeaderView.mas_bottom).with.offset(-6);
                make.left.right.bottom.equalTo(headerView);
            }];
            [headerView bringSubviewToFront:discoverUserHeaderView];
        }
    } else {
        
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        if (_proDetail.art_link && _proDetail.art_link.length) {
            return 130.0f;
        } else {
            return 70.0f;
        }
        
    } else {
        
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    if (section == 1) {
        headerView.backgroundColor = [UIColor blackColor];
        UIView *buinessView;
        if (_proDetail.art_link && _proDetail.art_link.length) {
            buinessView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, kScreenWidth-20, 100)];
        } else {
            buinessView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, kScreenWidth-20, 45)];
        }
        buinessView.clipsToBounds = YES;
        buinessView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:buinessView];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:buinessView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(20,20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = buinessView.bounds;
        maskLayer.path = maskPath.CGPath;
        buinessView.layer.mask = maskLayer;
        
        UIButton *buinessInforButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [buinessInforButton setImage:[UIImage imageNamed:@"company_infor"] forState:UIControlStateNormal];
        [buinessInforButton setTitle:@"商情信息" forState:UIControlStateNormal];
        [buinessInforButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
        buinessInforButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [buinessInforButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
        [buinessView addSubview:buinessInforButton];
        buinessInforButton.hidden = YES;
        [buinessInforButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(buinessView).with.offset(15);
            make.top.equalTo(buinessView).with.offset(8);
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        
        if (_proDetail.lat && _proDetail.lat.length) {
            UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [locationButton setImage:[UIImage imageNamed:@"pro_show_local"] forState:UIControlStateNormal];
            [locationButton setTitle:@"Get Directions >" forState:UIControlStateNormal];
            [locationButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
            locationButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [locationButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
            [locationButton addTarget:self action:@selector(getMapButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [buinessView addSubview:locationButton];
            
            [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(buinessView).with.offset(-15);
                make.top.equalTo(buinessView).with.offset(8);
                make.size.mas_equalTo(CGSizeMake(130, 30));
            }];
            UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [linkButton setImage:[UIImage imageNamed:@"publish_link"] forState:UIControlStateNormal];
            [linkButton setTitle:@"VIP用户推荐链接" forState:UIControlStateNormal];
            [linkButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
            linkButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [linkButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
            [buinessView addSubview:linkButton];
            [linkButton addTarget:self action:@selector(vipLinkUrlButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(buinessView).with.offset(-15);
                make.left.equalTo(buinessView).with.offset(15);
                make.top.equalTo(buinessInforButton.mas_bottom).with.offset(8);
                make.height.mas_equalTo(38);
            }];
            
            linkButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            linkButton.layer.borderWidth = 0.5;
            linkButton.layer.cornerRadius = 6;
            linkButton.layer.masksToBounds = YES;
        } else {
            UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [linkButton setImage:[UIImage imageNamed:@"publish_link"] forState:UIControlStateNormal];
            [linkButton setTitle:@"VIP用户推荐链接" forState:UIControlStateNormal];
            [linkButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
            linkButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [linkButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
            [buinessView addSubview:linkButton];
            [linkButton addTarget:self action:@selector(vipLinkUrlButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(buinessView).with.offset(-15);
                make.left.equalTo(buinessView).with.offset(15);
                make.centerY.equalTo(buinessView);
                make.height.mas_equalTo(38);
            }];
            
            linkButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            linkButton.layer.borderWidth = 0.5;
            linkButton.layer.cornerRadius = 6;
            linkButton.layer.masksToBounds = YES;
        }
        
    } else {
        headerView.backgroundColor = [UIColor blackColor];
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        _isShowDesc = !_isShowDesc;
        [_proTableView reloadData];
    } else {
        if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[DetailNormalCell class]]) {
            _selectIndex = indexPath;
            NSArray *selectArray = _proDetail.detailed[indexPath.section-1][@"images"];
            NSMutableArray *flagMutableArray = [[NSMutableArray alloc] init];
            for (NSDictionary *flagDict in selectArray) {
                PublishSourceModel *sourceModel = [[PublishSourceModel alloc] init];
                sourceModel.sourceDesc = flagDict[@"photodesc"];
                sourceModel.sourceImage = flagDict[@"url"];
                [flagMutableArray addObject:sourceModel];
            }
            MWPhotoBrowser *postDetailPhotoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            [postDetailPhotoBrowser setCurrentPhotoIndex:indexPath.row-1];
            postDetailPhotoBrowser.autoPlayOnAppear = YES;
            postDetailPhotoBrowser.displayActionButton = NO;
            postDetailPhotoBrowser.publishSourceModelArray = flagMutableArray;
            postDetailPhotoBrowser.isLS = YES;
            postDetailPhotoBrowser.postUserId = _proDetail.userId;
            XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailPhotoBrowser];
            
            CATransition *transition = [CATransition animation];
            transition.duration = 1.0;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromBottom;
            [self.view.window.layer addAnimation:transition forKey:@"animation"];
            [self presentViewController:nav animated:NO completion:nil];
        } else if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[ProDetailVRCell class]]) {
            /*
             UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"detail" bundle:nil];
             ProDetailViewController *proDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProDetailViewController"];
             proDetailVC.detail = _proDetail;
             proDetailVC.page = indexPath.section-1;
             [self.navigationController pushViewController:proDetailVC animated:YES];
             */
        } else {
            
        }
        
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    NSArray *selectArray = _proDetail.detailed[_selectIndex.section-1][@"images"];
    return selectArray.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSArray *selectArray = _proDetail.detailed[_selectIndex.section-1][@"images"];
    NSDictionary *flagDict = selectArray[index];
    MWPhoto *photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:flagDict[@"url"]]];
    return photo;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"clear_image"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItems = @[];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 创建底部菜单
- (void)createProShowDetailBottomView {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProBottomMenuView" owner:self options:nil];
    _proDetailBottomMenuView = [nib objectAtIndex:0];
    
    [self.view addSubview:_proDetailBottomMenuView];
    [_proDetailBottomMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (kDevice_Is_iPhoneX) {
            make.bottom.equalTo(self.view).with.offset(-kBottom_iPhoneX);
        } else {
            make.bottom.equalTo(self.view);
        }
        
        make.height.mas_equalTo(50);
    }];
    [_proDetailBottomMenuView.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [_proDetailBottomMenuView.reportButton addTarget:self action:@selector(reportButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 返回上一层
- (void)backAction {
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_proDetail == nil) {
        [self show];
    } else {
        contentOffsetY = scrollView.contentOffset.y;
        if (contentOffsetY - oldContentOffsetY > 5  && contentOffsetY > 0) {
            oldContentOffsetY = contentOffsetY;
            if (_proDetail) {
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
    if (scrollView.contentOffset.y < 0) {
        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(-scrollView.contentOffset.y);
        }];
    } else {
        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.1);
        }];
    }
    if (scrollView.contentOffset.y > 0) {
        float flagViewOffset = scrollView.contentOffset.y-scrollView.contentSize.height + scrollView.frame.size.height;
        if (flagViewOffset > 0) {
            [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(flagViewOffset);
            }];
        } else {
            [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.1);
            }];
        }
    } else {
        [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.1);
        }];
    }
    
}

- (void)hidden{
    if (_proDetailBottomMenuView.hidden) {
        
    } else {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [_proDetailBottomMenuView.layer addAnimation:animation forKey:nil];
        _proDetailBottomMenuView.hidden = YES;
    }
    
}

- (void)show {
    if (_proDetailBottomMenuView.hidden) {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [_proDetailBottomMenuView.layer addAnimation:animation forKey:nil];
        
        _proDetailBottomMenuView.hidden = NO;
    } else {
        
    }
    
}

#pragma mark - 帖子举报
- (void)reportButtonClick {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCReport" bundle:nil];
    XTCReportViewController *reportVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCReportViewController"];
    reportVC.reportId = _postId;
    reportVC.isChatReport = NO;
    [self.navigationController pushViewController:reportVC animated:YES];
}

- (void)createFooterTagView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenHeight, 50)];
    footerView.backgroundColor = [UIColor blackColor];
    _proTableView.tableFooterView = footerView;
    NSArray *tagArray = _proDetail.tags_list;
    float flagWidth = 20;
    float flagTop = 0;
    for (NSString *tag in tagArray) {
        CGSize titleSize = [tag sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:12.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        titleSize = CGSizeMake(titleSize.width+15, 30);
        
        if (flagWidth + titleSize.width + 10 > kScreenWidth) {
            flagTop = flagTop + 35;
            flagWidth = 20;
            footerView.frame = CGRectMake(0, 0, kScreenHeight, 80);
        } else {
            
        }
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PublishTagView" owner:self options:nil];
        PublishTagView *publishTagView = [nib objectAtIndex:0];
        [footerView addSubview:publishTagView];
        publishTagView.layer.cornerRadius = 15;
        publishTagView.layer.masksToBounds = YES;
        publishTagView.backgroundColor = [UIColor blackColor];
        publishTagView.layer.borderWidth = 1;
        publishTagView.layer.borderColor = [UIColor whiteColor].CGColor;
        publishTagView.tagLabel.text = tag;
        publishTagView.tagLabel.textColor = [UIColor whiteColor];
        [publishTagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footerView).with.offset(flagTop);
            make.left.equalTo(footerView).with.offset(flagWidth);
            make.size.mas_equalTo(CGSizeMake(titleSize.width, 30));
        }];
        flagWidth = flagWidth + titleSize.width + 10;
        publishTagView.delButton.hidden = YES;
        publishTagView.tagLabel.textAlignment = NSTextAlignmentCenter;
        
    }
}

- (void)dealloc {
    DDLogInfo(@"pro详情贴子内存释放");
}

#pragma mark - 播放音频
- (void)playAudioButtonClick:(UIButton *)button {
    [[PlayerManager sharedInstance].player pause];
    if (_playAudioIndex == button.tag) {
        _playAudioIndex = 0;
    } else {
        _playAudioIndex = button.tag;
        NSDictionary *dict = _proDetail.detailed[_playAudioIndex-1];
        [[PlayerManager sharedInstance] play:@[dict[@"audio_url"]]];
        if ([PlayerManager sharedInstance].finishDelegate == nil) {
            [PlayerManager sharedInstance].finishDelegate = self;
        }
    }
    [self controlAudioAnimationByButton:button];
}

- (void)controlAudioAnimationByButton:(UIButton *)flagButton {
    UIImageView *imageView = flagButton.imageView;
    [imageView stopAnimating];
    if (_playAudioIndex == flagButton.tag) {
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
        imageView = nil;
    }
}

- (void)playerManagerVideoFinish {
    [[PlayerManager sharedInstance].player pause];
    _playAudioIndex = 0;
    NSArray *dismisArray = [_proTableView visibleCells];
    for (UITableViewCell *cell in dismisArray) {
        if ([cell isKindOfClass:[ProDetailVRCell class]]) {
            ProDetailVRCell *flagCell = (ProDetailVRCell *)cell;
            [self controlAudioAnimationByButton:flagCell.audioButton];
        } else {
            
        }
    }
}


#pragma mark - 进入地图
- (void)getMapButtonClick {
    [self playerManagerVideoFinish];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        NSMutableArray *mapList = [[NSMutableArray alloc] init];
        NSArray *vrDictArray = weakSelf.proDetail.detailed;
        for (NSDictionary *vrDict in vrDictArray) {
            for (NSDictionary *imageDict in vrDict[@"images"]) {
                [mapList addObject:imageDict];
            }
        }
        
        CLLocationCoordinate2D coor2D = CLLocationCoordinate2DMake(weakSelf.proDetail.lat.doubleValue, weakSelf.proDetail.lng.doubleValue);
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"detail" bundle:nil];
        NavigateToViewController *navigateToVC = [storyBoard instantiateViewControllerWithIdentifier:@"NavigateToViewController"];
        navigateToVC.coordinate = coor2D;
        navigateToVC.isVR = NO;
        navigateToVC.mapList = mapList;
        navigateToVC.isPro = YES;
        navigateToVC.userid = weakSelf.proDetail.userId;
        navigateToVC.title = weakSelf.proDetail.posttitle;
        navigateToVC.isPull = NO;
        [self.navigationController pushViewController:navigateToVC animated:YES];
    });
}

#pragma mark 进入用户推荐链接
- (void)vipLinkUrlButtonClick {
    CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
    commonWebViewVC.titleString = @"推荐链接";
    commonWebViewVC.urlString = _proDetail.art_link;
    commonWebViewVC.isPreventPanPop = NO;
    [self.navigationController pushViewController:commonWebViewVC animated:YES];
    
}

#pragma mark - 点击vr
- (void)vrTapGesClick:(UITapGestureRecognizer *)tapges {
    UIView *vrView = tapges.view;
    NSInteger tapFlag = vrView.tag;
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"detail" bundle:nil];
    ProDetailViewController *proDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProDetailViewController"];
    proDetailVC.detail = _proDetail;
    proDetailVC.page = tapFlag;
    [self.navigationController pushViewController:proDetailVC animated:YES];
}

- (void)tapAdverTapClick {
    NSDictionary *flagDict = self.proDetail.advert;
    CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
    commonWebViewVC.titleString = flagDict[@"title"];
    commonWebViewVC.urlString = flagDict[@"link"];
    commonWebViewVC.isPreventPanPop = NO;
    [self.navigationController pushViewController:commonWebViewVC animated:YES];
}

- (void)vrShowClick:(UIButton *)button {
    if (_proDetail) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"detail" bundle:nil];
        ProDetailViewController *proDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProDetailViewController"];
        proDetailVC.detail = _proDetail;
        proDetailVC.page = button.tag-101;
        [self.navigationController pushViewController:proDetailVC animated:YES];
    } else {
        
    }
    
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
