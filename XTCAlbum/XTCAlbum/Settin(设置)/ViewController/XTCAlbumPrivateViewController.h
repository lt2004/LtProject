//
//  XTCAlbumPrivateViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/14.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCCreatePrivateAlbumViewController.h"
#import "XTCAlbumPrivateDetailViewController.h"
#import "XTCSelectPrivateAlbumViewController.h"

@interface XTCAlbumPrivateViewController : XTCBaseViewController

@property (nonatomic, strong) NSMutableArray *privateArray;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@end
