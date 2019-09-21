//
//  ProDetailShowViewController.h
//  vs
//
//  Created by Mac on 2018/9/6.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "ZFPlayerCell.h"
#import "UIView+WebVideoCache.h"
#import "ProDetailVRCell.h"
#import "ProScrollAdvertView.h"
#import "ProDetail.h"
#import "ProBottomMenuView.h"
#import "PlayerManager.h"
#import "ProShowDetailUserInforCell.h"
#import "MWPhotoBrowser.h"
#import "DetailNormalCell.h"

@interface ProDetailShowViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource, PlayerManagerStopDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSString *postId;
@property (weak, nonatomic) IBOutlet UITableView *proTableView;
@property (nonatomic, strong) ProDetail *proDetail;
@property (nonatomic, strong) ZFPlayerCell *playingCell;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) ProBottomMenuView *proDetailBottomMenuView; // 底部菜单栏
@property (nonatomic, assign) BOOL isShowLocalMap;


@end
