//
//  XTCCreatePrivateAlbumViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/14.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCAlbumPrivateDetailViewController.h"

@interface XTCCreatePrivateAlbumViewController : XTCBaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *enterLabel;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (weak, nonatomic) IBOutlet UILabel *headerPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomPasswordLabel;

@end
