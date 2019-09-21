//
//  XTCAlbumLoginViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/19.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCAlbumRegisterViewController.h"


NS_ASSUME_NONNULL_BEGIN

typedef void (^LoginSuccessBlock)(void);

@interface XTCAlbumLoginViewController : XTCBaseViewController

@property (nonatomic, strong) LoginSuccessBlock loginSuccessBlock;

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UILabel *registerLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *travelButton;

@end

NS_ASSUME_NONNULL_END
