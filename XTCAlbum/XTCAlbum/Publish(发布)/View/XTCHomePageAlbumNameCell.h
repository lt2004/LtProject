//
//  XTCHomePageAlbumNameCell.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController/UIView+Layout.h>

@interface XTCHomePageAlbumNameCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *corverImageView;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) TZAlbumModel *albumModel;
@property (nonatomic, strong) UIView *selectCoverView;
@property (nonatomic, strong) UILabel *selectCountLabel;

@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, copy)   NSString *representedAssetIdentifier;

- (void)insertDataToCell:(TZAlbumModel *)flagAlbumModel;

@end
