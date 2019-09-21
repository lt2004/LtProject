//
//  SlideSettingViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/26.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideSettingCell.h"
#import "UIButton+WebCache.h"
#import "XTCAlbumPrivateViewController.h"
#import "XTCFeedbackViewController.h"
#import "CommonWebViewViewController.h"
#import "XTCRecommendViewController.h"
#import "XTCAboutUsViewController.h"
#import "XTCUserInforViewController.h"
#import "PublishDraftListViewController.h"
#import "XTCAlbumLoginViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlideSettingViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet UIButton *dismisButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UIButton *userHeadeButton;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UIImageView *levelImageView;

@property (nonatomic, assign) BOOL isCloseShowVR;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (nonatomic, strong) NSString *privateNickName;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

- (void)loadSettingAboutData;

@end

NS_ASSUME_NONNULL_END
