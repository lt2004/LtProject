//
//  XTCAboutUsViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "CommonWebViewViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCAboutUsViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *aboutUsTableView;

@end

NS_ASSUME_NONNULL_END
