//
//  XTCCommonAnnotationView.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/5.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <Photos/Photos.h>

@interface XTCCommonAnnotationView : MAAnnotationView

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImageView *countImageView;
@property (nonatomic, strong) NSString *privateFileUrlStr;

@end
