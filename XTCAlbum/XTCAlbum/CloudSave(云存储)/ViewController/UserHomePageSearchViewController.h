//
//  UserHomePageSearchViewController.h
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSearchTagsCell.h"
#import "HomePageSearchResponseModel.h"
#import "DoSearchRequestModel.h"
#import "SearchIdentResponseModel.h"
#import "PostDetailPhotoViewController.h"
#import "ProDetailShowViewController.h"
#import "XTCAlbum-Swift.h"

@protocol UserHomeSearchDelegate <NSObject>

- (void)userHomeSearchByKeyWord:(NSString *)keyWord;
- (void)userHomeSearchPostByKeyWord:(NSString *)keyWord;

@end

typedef void(^UserHomeShowTagBlock)(NSMutableArray *showTagArray, NSMutableArray *hideTagArray);

@interface UserHomePageSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) id<UserHomeSearchDelegate> delegate;
@property (nonatomic, strong) UserTagsResponseModel *userTagsResponseModel;
@property (nonatomic, strong) UserHomeShowTagBlock userHomeShowTagBlock;
@property (nonatomic, assign) BOOL isEditTag; // 是否处于排列删除状态
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (nonatomic, assign) BOOL isOwnSearch;

@end
