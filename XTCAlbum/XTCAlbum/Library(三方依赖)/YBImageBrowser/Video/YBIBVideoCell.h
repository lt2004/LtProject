//
//  YBIBVideoCell.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/10.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBCellProtocol.h"
#import "YBIBVideoView.h"


NS_ASSUME_NONNULL_BEGIN

@interface YBIBVideoCell : UICollectionViewCell <YBIBCellProtocol, UIScrollViewDelegate>

@property (nonatomic, strong) YBIBVideoView *videoView;


@end

NS_ASSUME_NONNULL_END
