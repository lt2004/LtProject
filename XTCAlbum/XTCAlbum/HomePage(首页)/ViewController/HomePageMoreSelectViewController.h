//
//  HomePageMoreSelectViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/20.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectShowTypeCallBack)(NSInteger selectIndex);

@interface HomePageMoreSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *dismisButton;
@property (weak, nonatomic) IBOutlet UITableView *selectTableView;
@property (nonatomic, strong) SelectShowTypeCallBack selectShowTypeCallBack;

@end

NS_ASSUME_NONNULL_END
