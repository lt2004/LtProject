//
//  XTCUserInforViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCUserHeaderCell.h"
#import "XTCUserInforCell.h"
#import "XTCModifyPasswordViewController.h"
#import "XTCPermissionManager.h"
#import <VPImageCropper/VPImageCropperViewController.h>

typedef void(^ExitLoginCallBack)(BOOL isLogin);
typedef void(^ModifyNickNameCallBack)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XTCUserInforViewController : XTCBaseViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *userInforTableView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (nonatomic, strong) ExitLoginCallBack exitLoginCallBack;
@property (nonatomic, strong) ModifyNickNameCallBack modifyNickNameCallBack;

@end

NS_ASSUME_NONNULL_END
