//
//  HomeCollectionViewCell.h
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/5.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"
#import <PhotosUI/PhotosUI.h>
#import "TZImageManager.h"
#import <TZImagePickerController/UIView+Layout.h>

@interface HomeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;

@property (weak, nonatomic) IBOutlet UILabel *hdrLabel;
@property (weak, nonatomic) IBOutlet UIView *disableView;

@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) PHAsset *publishAsset;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) UIImage *priveteImage;
//@property (nonatomic, assign) BOOL isDetail;

- (void)insertPrivateData:(NSString *)sourcePath;


@end
