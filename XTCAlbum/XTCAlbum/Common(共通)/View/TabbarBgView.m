//
//  TabbarBgView.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TabbarBgView.h"
#import "XTCHomePageViewController.h"

@implementation TabbarBgView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createTabbarBgViewUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTabbarBgViewUI];
    }
    return self;
}

- (void)createTabbarBgViewUI {
    _selectIndex = 0;
    UICollectionViewFlowLayout *tabBarlayout = [[UICollectionViewFlowLayout alloc] init];
    tabBarlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    tabBarlayout.minimumLineSpacing = 0;
    tabBarlayout.minimumInteritemSpacing = 0;
    tabBarlayout.sectionInset = UIEdgeInsetsZero;
    _tabBarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 49) collectionViewLayout:tabBarlayout];
    _tabBarCollectionView.delegate = self;
    _tabBarCollectionView.dataSource = self;
    _tabBarCollectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_tabBarCollectionView];
    [_tabBarCollectionView registerClass:[TabBarCell class] forCellWithReuseIdentifier:@"TabBarCellName"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TabBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TabBarCellName" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    switch (indexPath.item) {
        case 0: {
            cell.statusLabel.text = XTCLocalizedString(@"Tabbar_All", nil);
            if (_selectIndex == 0) {
                cell.statusLabel.textColor = HEX_RGB(0x38880D);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_all_selelct"];
            } else {
                cell.statusLabel.textColor = HEX_RGB(0x1f1f1f);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_all_no_selelct"];
            }
        }
            break;
        case 1: {
            cell.statusLabel.text = XTCLocalizedString(@"Tabbar_Time", nil);
            if (_selectIndex == 1) {
                cell.statusLabel.textColor = HEX_RGB(0x38880D);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_time_selelct"];
            } else {
                cell.statusLabel.textColor = HEX_RGB(0x1f1f1f);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_time_no_selelct"];
            }
        }
            break;
        case 2: {
            cell.statusImageView.image = nil;
            cell.statusLabel.text = XTCLocalizedString(@"XTC_Publish", nil);
        }
            break;
        case 3: {
            cell.statusLabel.text = XTCLocalizedString(@"Tabbar_Footer", nil);
            if (_selectIndex == 3) {
                cell.statusLabel.textColor = HEX_RGB(0x38880D);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_footer_selelct"];
            } else {
                cell.statusLabel.textColor = HEX_RGB(0x1f1f1f);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_footer_no_selelct"];
            }
        }
            break;
        case 4: {
            cell.statusLabel.text = XTCLocalizedString(@"Tabbar_Album", nil);
            if (_selectIndex == 4) {
                cell.statusLabel.textColor = HEX_RGB(0x38880D);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_album_selelct"];
            } else {
                cell.statusLabel.textColor = HEX_RGB(0x1f1f1f);
                cell.statusLabel.font = [UIFont fontWithName:kHelvetica size:14];
                cell.statusImageView.image = [UIImage imageNamed:@"tabbar_album_no_selelct"];
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kScreenWidth*0.2, 49);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XTCHomePageViewController *homePageViewController = (XTCHomePageViewController *)[StaticCommonUtil rootNavigationController].viewControllers.firstObject;
    switch (indexPath.item) {
        case 0: {
            if (self.selectIndex == 0) {
                [homePageViewController.homePageStreamPhotoCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                 [homePageViewController.streamBackCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                 [homePageViewController.verticalCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
            } else {
                homePageViewController.timeLineVC.view.hidden = YES;
                homePageViewController.trackVC.view.hidden = YES;
                homePageViewController.ablumViewController.view.hidden = YES;
                self.selectIndex = 0;
                [collectionView reloadData];
            }
        }
            break;
        case 1: {
            if (self.selectIndex == 1) {
                
            } else {
                if (homePageViewController.timeLineVC == nil) {
                    UIStoryboard *timeLineStoryBoard = [UIStoryboard storyboardWithName:@"XTCTimeShow" bundle:nil];
                    homePageViewController.timeLineVC = [timeLineStoryBoard instantiateViewControllerWithIdentifier:@"XTCTimeShowViewController"];
                    [homePageViewController.view addSubview:homePageViewController.timeLineVC.view];
                    [homePageViewController.timeLineVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(homePageViewController.view);
                        make.top.equalTo(homePageViewController.view);
                        make.bottom.equalTo(homePageViewController.bottomBgView.mas_top);
                    }];
                } else {
                    
                }
                homePageViewController.timeLineVC.view.hidden = NO;
                homePageViewController.trackVC.view.hidden = YES;
                homePageViewController.ablumViewController.view.hidden = YES;
                self.selectIndex = 1;
                [collectionView reloadData];
            }
        }
            break;
        case 3: {
            if (self.selectIndex == 3) {
                
            } else {
                if (homePageViewController.trackVC == nil) {
                    UIStoryboard *trackStoryBoard = [UIStoryboard storyboardWithName:@"XTCFooter" bundle:nil];
                    homePageViewController.trackVC = [trackStoryBoard instantiateViewControllerWithIdentifier:@"XTCFooterViewController"];
                    [homePageViewController.view addSubview:homePageViewController.trackVC.view];
                    [homePageViewController.trackVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(homePageViewController.view);
                        make.top.equalTo(homePageViewController.view);
                        make.bottom.equalTo(homePageViewController.bottomBgView.mas_top);
                    }];
                } else {
                    
                }
                homePageViewController.timeLineVC.view.hidden = YES;
                homePageViewController.trackVC.view.hidden = NO;
                homePageViewController.ablumViewController.view.hidden = YES;
                self.selectIndex = 3;
                [collectionView reloadData];
            }
        }
            break;
        case 4: {
            if (self.selectIndex == 4) {
                
            } else {
                if (homePageViewController.ablumViewController == nil) {
                    UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"XTCAblum" bundle:nil];
                    homePageViewController.ablumViewController = [settingStoryBoard instantiateViewControllerWithIdentifier:@"XTCAblumViewController"];
                    [homePageViewController.view addSubview:homePageViewController.ablumViewController.view];
                    [homePageViewController.ablumViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(homePageViewController.view);
                        make.top.equalTo(homePageViewController.mas_topLayoutGuideBottom);
                        make.bottom.equalTo(homePageViewController.bottomBgView.mas_top);
                    }];
                } else {
                    
                }
                homePageViewController.timeLineVC.view.hidden = YES;
                homePageViewController.trackVC.view.hidden = YES;
                homePageViewController.ablumViewController.view.hidden = NO;
                self.selectIndex = 4;
                [collectionView reloadData];
            }
        }
            break;
            
        default:
            break;
    }
    [homePageViewController.view bringSubviewToFront:homePageViewController.publishButton];
    [homePageViewController.view bringSubviewToFront:homePageViewController.flagAdvertImageView];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
