//
//  XTCModifyPasswordViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCModifyPasswordCell.h"
#import <TPKeyboardAvoiding/TPKeyboardAvoidingTableView.h>

typedef void (^ModifyPasswordSuccessBlock)(void);

@interface XTCModifyPasswordViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView *modifyPasswordTableView;
@property (nonatomic, strong) ModifyPasswordSuccessBlock modifyPasswordSuccessBlock;

@end
