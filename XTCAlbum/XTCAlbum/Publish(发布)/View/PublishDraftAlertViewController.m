//
//  PublishDraftAlertViewController.m
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishDraftAlertViewController.h"

@interface PublishDraftAlertViewController ()

@end

@implementation PublishDraftAlertViewController
@synthesize saveButton =_saveButton;
@synthesize editButton = _editButton;
@synthesize exitButton = _exitButton;
@synthesize bgView = _bgView;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _bgView.layer.cornerRadius = 8;
    _bgView.layer.masksToBounds = YES;
    
    _saveButton.layer.cornerRadius = 25;
    _saveButton.layer.masksToBounds = YES;
    
    _editButton.layer.cornerRadius = 25;
    _editButton.layer.masksToBounds = YES;
    _editButton.layer.borderColor = HEX_RGB(0x979797).CGColor;
    _editButton.layer.borderWidth = 1;
    
    _exitButton.layer.cornerRadius = 25;
    _exitButton.layer.masksToBounds = YES;
    _exitButton.layer.borderColor = HEX_RGB(0x979797).CGColor;
    _exitButton.layer.borderWidth = 1;
}

- (IBAction)saveButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.publishDraftCallBack) {
            self.publishDraftCallBack(PublishNormalDraftSaveType);
        }
    }];
    
}

- (IBAction)editButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (self.publishDraftCallBack) {
        self.publishDraftCallBack(PublishNormalDraftEditType);
    }
}

- (IBAction)exitButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (self.publishDraftCallBack) {
        self.publishDraftCallBack(PublishNormalDraftExitType);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
