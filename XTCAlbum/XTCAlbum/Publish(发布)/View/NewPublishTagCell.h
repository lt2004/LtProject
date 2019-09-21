//
//  NewPublishTagCell.h
//  vs
//
//  Created by Mac on 2018/11/27.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailTagFlowLayout.h"
#import "DetailTagCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewPublishTagCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *tagCollectionView;
@property (nonatomic, strong) NSArray *tagArray;
- (void)loadTagData:(NSArray *)flagTagArray;

@end

NS_ASSUME_NONNULL_END
