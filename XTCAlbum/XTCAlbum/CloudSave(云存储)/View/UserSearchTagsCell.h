//
//  UserSearchTagsCell.h
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSearchTagCollectionViewCell.h"

typedef void (^DeleteUserTagCallabck)(NSString *tagString);
typedef void (^AddUserTagCallabck)(NSString *tagString);

@interface UserSearchTagsCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource> {
    UILongPressGestureRecognizer *_longPress;
}

@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (nonatomic, strong) NSMutableArray *tagArray;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) DeleteUserTagCallabck deleteUserTagCallabck;
@property (nonatomic, strong) AddUserTagCallabck addUserTagCallabck;
@property (nonatomic, assign) BOOL isMayAddTag;

- (void)insertDataToCell:(NSMutableArray *)tagArray;

@end
