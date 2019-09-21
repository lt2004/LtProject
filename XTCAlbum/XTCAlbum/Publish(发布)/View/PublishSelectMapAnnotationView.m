//
//  PublishSelectMapAnnotationView.m
//  vs
//
//  Created by Xie Shu on 2018/4/3.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "PublishSelectMapAnnotationView.h"

@implementation PublishSelectMapAnnotationView

#pragma mark Initialization

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
    _countImageView.layer.cornerRadius = 5;
    _countImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _countImageView.layer.borderWidth = 2;
    _countImageView.layer.masksToBounds = YES;
    _countImageView.contentMode = UIViewContentModeScaleAspectFill;
    _countImageView.clipsToBounds = YES;
    [self addSubview:_countImageView];
    
    [_countImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.center.equalTo(self);
    }];
    
    _imageLabel = [[UILabel alloc] init];
    _imageLabel.textAlignment = NSTextAlignmentCenter;
    _imageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _imageLabel.textColor = [UIColor whiteColor];
    _imageLabel.adjustsFontSizeToFitWidth = YES;
    [_imageLabel sizeToFit];
    _imageLabel.backgroundColor = HEX_RGB(0x38880D);
    _imageLabel.layer.cornerRadius = 13;
    _imageLabel.layer.masksToBounds = YES;
    [self addSubview:_imageLabel];
    [_imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.countImageView.mas_right);
        make.centerY.equalTo(self.countImageView.mas_top);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
}

- (void)setAsset:(PHAsset *)asset {
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.countImageView.image = result;
    }];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    _imageLabel.text = [@(_count) stringValue];
    [self setNeedsDisplay];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
