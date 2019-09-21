//
//  AblumHeaderReusableView.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AblumHeaderReusableView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *createButton;

- (void)createAblumHeaderReusableViewUI;

@end

NS_ASSUME_NONNULL_END
