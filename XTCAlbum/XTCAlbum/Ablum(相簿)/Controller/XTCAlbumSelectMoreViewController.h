//
//  XTCAlbumSelectMoreViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/24.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "HomePageMoreSelectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCAlbumSelectMoreViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *selectTableView;
@property (nonatomic, strong) SelectShowTypeCallBack selectShowTypeCallBack;

@end

NS_ASSUME_NONNULL_END
