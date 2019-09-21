//
//  PublishMapSelectCell.m
//  vs
//
//  Created by Xie Shu on 2018/4/3.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "PublishMapSelectCell.h"

@implementation PublishMapSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _photoImageView = [[UIImageView alloc] init];
    _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_photoImageView];
    [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).with.offset(-5);
    }];
    _photoImageView.layer.cornerRadius = 4;
    _photoImageView.layer.masksToBounds = YES;
    
    
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [_selectButton setImage:[UIImage imageNamed:@"publish_select_photo"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"publish_picker_photo_select"] forState:UIControlStateSelected];
    [self.contentView addSubview:_selectButton];
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.photoImageView).with.offset(-2);
        make.left.equalTo(self.photoImageView).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    _selectCountLabel = [[UILabel alloc] init];
    _selectCountLabel.layer.masksToBounds = YES;
    _selectCountLabel.layer.cornerRadius = 12.5;
    _selectCountLabel.backgroundColor = RGBCOLOR(0, 187, 59);
    _selectCountLabel.textColor = [UIColor whiteColor];
    _selectCountLabel.textAlignment = NSTextAlignmentCenter;
    _selectCountLabel.hidden = YES;
    [self.contentView addSubview:_selectCountLabel];
    [_selectCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.center.equalTo(self.selectButton);
    }];
}


- (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius byAsset:(PHAsset *)asset
{
    _shadowLayer = [CALayer layer];
     CGSize flagSize = CGSizeMake(asset.pixelWidth*1.0/asset.pixelHeight*86, 86);
    _shadowLayer.frame = CGRectMake(0, 0, flagSize.width, flagSize.height);
    
    _shadowLayer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;//shadowColor阴影颜色
    _shadowLayer.shadowOffset = CGSizeMake(1, 1);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    _shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    _shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = _shadowLayer.bounds.size.width;
    float height = _shadowLayer.bounds.size.height;
    float x = _shadowLayer.bounds.origin.x;
    float y = _shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = _shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    _shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [view.superview.layer insertSublayer:_shadowLayer below:view.layer];
}


@end
