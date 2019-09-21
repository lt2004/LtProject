//
//  ChoicenessSelectMoreViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/24.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCAlbumSelectMoreViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChoicenessSelectMoreViewController : UIViewController

@property (nonatomic, strong) SelectShowTypeCallBack selectShowTypeCallBack;
@property (weak, nonatomic) IBOutlet UITableView *selectTableView;

@end

NS_ASSUME_NONNULL_END
