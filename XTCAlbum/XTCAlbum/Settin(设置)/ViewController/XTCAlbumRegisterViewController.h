//
//  XTCAlbumRegisterViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/20.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "AlbumRegisterCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCAlbumRegisterViewController : XTCBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *registerTableView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;

@end

NS_ASSUME_NONNULL_END
