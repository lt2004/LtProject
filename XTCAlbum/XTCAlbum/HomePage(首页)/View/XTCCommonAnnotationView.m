//
//  XTCCommonAnnotationView.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/5.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCCommonAnnotationView.h"

@implementation XTCCommonAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self createMapUI];
    }
    
    return self;
}

- (void)createMapUI {
    _countImageView = [[UIImageView alloc] init];
    _countImageView.layer.cornerRadius = 20;
//    _countImageView.backgroundColor = [UIColor redColor];
    _countImageView.layer.masksToBounds = YES;
    _countImageView.contentMode = UIViewContentModeScaleAspectFill;
    _countImageView.clipsToBounds = YES;
    [self addSubview:_countImageView];
    
    [_countImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(13);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerX.equalTo(self);
    }];
}

- (void)setAsset:(PHAsset *)asset {
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(80, 80) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.countImageView.image = result;
    }];
}

- (void)setPrivateFileUrlStr:(NSString *)fileUrl {
    if ([fileUrl containsString:@".mp4"]) {
        self.countImageView.image = [self thumbnailImageFromURL:[NSURL fileURLWithPath:fileUrl]];
    } else {
        UIImage *img = [UIImage imageWithContentsOfFile:fileUrl];
        CGFloat widthFlag = img.size.width;
        CGFloat heightFlag = img.size.height;
        if (widthFlag > heightFlag) {
            widthFlag = 480.0*widthFlag/heightFlag;
            heightFlag = 480.0;
        } else {
            heightFlag = 480.0*heightFlag/widthFlag;
            widthFlag = 480.0;
        }
        img = [img resizedImageToSize:CGSizeMake(widthFlag, heightFlag)];
        self.countImageView.image = img;
    }
}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime requestedTime = CMTimeMake(1, 60);
    CGImageRef imgRef = nil;
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    if (imgRef != nil) {
        return [UIImage imageWithCGImage:imgRef];
    }else {
        return nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
