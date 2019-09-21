//
//  NewPublishMakeTagViewController.h
//  ViewSpeaker
//
//  Created by Mac on 2019/3/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPublishMakeTagCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ShowSelectPublishTagsCallback)(NSMutableArray *tagsArray);

@interface NewPublishMakeTagViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tagTableView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) NSMutableArray *systemTagArray;
@property (nonatomic, strong) NSMutableArray *historyTagArray;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSString *selectSystemStr; // 选中的系统标签
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;
@property (nonatomic, strong) ShowSelectPublishTagsCallback showSelectPublishTagsCallback;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyBottomLayoutContraint;

@end

NS_ASSUME_NONNULL_END
