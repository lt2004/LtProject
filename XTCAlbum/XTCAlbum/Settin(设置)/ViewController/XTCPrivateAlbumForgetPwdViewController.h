//
//  XTCPrivateAlbumForgetPwdViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/15.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCModifyPasswordCell.h"

@interface XTCPrivateAlbumForgetPwdViewController : XTCBaseViewController

@property (nonatomic, strong) XTCPrivateAlbumModel *albumModel;
@property (weak, nonatomic) IBOutlet UITableView *resetTableView;

@end
