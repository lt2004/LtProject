//
//  VRDetailShowMenuView.h
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRDetailShowMenuView : UIView

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) UIButton *companyInforButton;
@property (nonatomic, strong) UIButton *linkUrlButton;
@property (nonatomic, strong) UIButton *soundButton;
@property (nonatomic, strong) UIButton *eyeButton;
@property (nonatomic, strong) UIButton *mapInforButton;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UIButton *crabButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
- (void)createCompanyInforMenuUI;
- (void)createPersonalInforMenuUI;



@end
