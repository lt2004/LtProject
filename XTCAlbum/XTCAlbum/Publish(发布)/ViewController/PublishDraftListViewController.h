//
//  PublishDraftListViewController.h
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCDraftPublishModel.h"
#import "XTCPublishManager.h"

@interface PublishDraftListViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *draftTableView;

@end
