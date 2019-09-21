//
//  PublishSelectMapAnnotationView.h
//  vs
//
//  Created by Xie Shu on 2018/4/3.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface PublishSelectMapAnnotationView : MAAnnotationView

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *countImageView;
@property (nonatomic, strong) UILabel *imageLabel;


@end
