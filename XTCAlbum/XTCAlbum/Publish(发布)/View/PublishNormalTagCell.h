//
//  PublishNormalTagCell.h
//  vs
//
//  Created by Xie Shu on 2017/10/17.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublishTagView.h"

typedef void (^PublishNormalDelTagCallBack)(NSString *tagString);

@interface PublishNormalTagCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, strong) PublishNormalDelTagCallBack publishNormalDelTagCallBack;
@property (nonatomic, assign) BOOL deleteFlag;

- (void)insertAboutTagView:(NSString *)tagString byDeleteFlag:(BOOL)deleteFlag;

@end
