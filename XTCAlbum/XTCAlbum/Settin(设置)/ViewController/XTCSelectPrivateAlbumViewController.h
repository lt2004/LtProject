//
//  XTCSelectPrivateAlbumViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/15.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCPrivateAlbumForgetPwdViewController.h"

@interface XTCSelectPrivateAlbumViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *privateFirstAlbumButton;
@property (weak, nonatomic) IBOutlet UIButton *privateSecondAlbumButton;
@property (nonatomic, strong) NSMutableArray *privateArray;
@property (weak, nonatomic) IBOutlet UITableView *selelctTableView;

@end
