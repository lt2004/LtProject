//
//  XTCShowVRAlertViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/8.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VRAlertSelectCallBack)(BOOL isSelectVr);

NS_ASSUME_NONNULL_BEGIN

@interface XTCShowVRAlertViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *vrButton;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *selelctButton;
@property (weak, nonatomic) IBOutlet UIImageView *switchImageView;
@property (nonatomic, strong) VRAlertSelectCallBack alertSelectCallBack;

@end

NS_ASSUME_NONNULL_END
