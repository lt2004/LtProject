//
//  SourceMoreSelectViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DetailSelectMoreCallBack)(NSInteger selectIndex);

NS_ASSUME_NONNULL_BEGIN

@interface SourceMoreSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *selectTableView;
@property (nonatomic, strong) DetailSelectMoreCallBack detailSelectMoreCallBack;
@property (nonatomic, assign) BOOL isLock;

@end

NS_ASSUME_NONNULL_END
