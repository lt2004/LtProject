//
//  XTCTimeShowSelectMoreViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageMoreSelectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCTimeShowSelectMoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *selectTableView;
@property (weak, nonatomic) IBOutlet UIButton *dismisButton;
@property (nonatomic, strong) SelectShowTypeCallBack selectShowTypeCallBack;
@property (nonatomic, assign) BOOL isCanSelect;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;

@end

NS_ASSUME_NONNULL_END
