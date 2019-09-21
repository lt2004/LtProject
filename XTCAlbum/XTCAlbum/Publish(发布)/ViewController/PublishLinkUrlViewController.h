//
//  PublishLinkUrlViewController.h
//  vs
//
//  Created by Xie Shu on 2017/10/17.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LinkUrlCallabck)(NSString *linkUrlString);

@interface PublishLinkUrlViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *urlTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (nonatomic, strong) LinkUrlCallabck linkUrlCallabck;
@property (weak, nonatomic) IBOutlet UIView *tapBgView;
@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UIButton *showWebLinkButton;
@property (weak, nonatomic) IBOutlet UIView *linkUrlBgView;
@property (weak, nonatomic) IBOutlet UIButton *giveUpButton;
@property (nonatomic, assign) BOOL verifyFinish; // 网址验证是否完成

@end
