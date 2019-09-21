//
//  PublishProVideoViewController.h
//  vs
//
//  Created by Xie Shu on 2017/11/4.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "PublishProVideoCell.h"
#import "PublishNormalTagCell.h"
#import "PublishNormalVipCell.h"
#import "NewPublishMakeTagViewController.h"
#import "PublishLinkUrlViewController.h"
#import "XLVideoPlayer.h"
#import "XTCPublishPickerViewController.h"
#import "XTCSourceCompressManager.h"

@class TPKeyboardAvoidingTableView;

@interface PublishProVideoViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSString *interactivePostId; // 互动帖子id
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView *publishProTableView;
@property (weak, nonatomic) IBOutlet UIButton *addTagButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBottomLayoutConstraint;

@property (nonatomic, strong) UIImage *videoCorverImage; // 视频封面
@property (nonatomic, strong) PHAsset *videoAsset; // 视频asset
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *chatType;
@property (nonatomic, strong) NSString *tk;
@property (nonatomic, assign) BOOL isPublishRoadBook; // 发布路书的帖子

@end
