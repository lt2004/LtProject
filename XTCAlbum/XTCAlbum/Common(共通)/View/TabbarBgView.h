//
//  TabbarBgView.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarCell.h"
#import "XTCTimeShowViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface TabbarBgView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *tabBarCollectionView;
@property (nonatomic, assign) NSInteger selectIndex;

@end

NS_ASSUME_NONNULL_END
