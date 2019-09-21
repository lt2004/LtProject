//
//  PublishDraftAlertViewController.h
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void (^PublishDraftCallBack)(PublishNormalDraftType type);

@interface PublishDraftAlertViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) PublishDraftCallBack publishDraftCallBack;

@end
