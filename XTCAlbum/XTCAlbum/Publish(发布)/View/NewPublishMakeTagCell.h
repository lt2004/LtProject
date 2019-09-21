//
//  NewPublishMakeTagCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/3/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPublishMakeTagCollectionViewCell.h"

typedef void(^DeleteSelectTagCallback)(NSString * _Nullable deleteStr);
typedef void(^AddSelectTagCallback)(NSString * _Nullable addStr);



NS_ASSUME_NONNULL_BEGIN

@interface NewPublishMakeTagCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *tagCollectionView;
@property (nonatomic, strong) NSMutableArray *showArray;
@property (nonatomic, assign) NewPublishTagType publishTagType;
@property (nonatomic, strong) NSString *selectSystemStr;
@property (nonatomic, strong) DeleteSelectTagCallback deleteSelectTagCallback;
@property (nonatomic, strong) AddSelectTagCallback addSelectTagCallback;

- (void)loadAboutData:(NSMutableArray *)flagShowArray;

@end

NS_ASSUME_NONNULL_END
