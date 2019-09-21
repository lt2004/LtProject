//
//  CustomButton.m
//  BakeGlobalVillage
//
//  Created by zzy on 15/7/4.
//  Copyright © 2015年 zzy. All rights reserved.
//

#import "TabBarButton.h"
#import <Masonry/Masonry.h>

@implementation TabBarButton

- (id)initWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)imageName selectedImage:(NSString *)selectedImage
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImage *normalImage = [[UIImage imageNamed:imageName] resizedImageToSize:CGSizeMake(25, 25)];
        UIImage *highlightImage = [[UIImage imageNamed:selectedImage] resizedImageToSize:CGSizeMake(25, 25)];
        self.imageView = [[UIImageView alloc] initWithImage:normalImage highlightedImage:highlightImage];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(3);
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.centerX.equalTo(self);
        }];

        self.label = [[UILabel alloc] init];
        self.label.text = title;
        self.label.font = [UIFont systemFontOfSize:12.0f];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = RGBCOLOR(74, 74, 74);
        [self addSubview:self.label];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).with.offset(0);
            make.centerX.equalTo(self.imageView);
            make.size.mas_equalTo(CGSizeMake(self.bounds.size.width, 20));
        }];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)imageName
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImage *normalImage = [UIImage imageNamed:imageName];
        self.imageView = [[UIImageView alloc] initWithImage:normalImage];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(3);
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.centerX.equalTo(self);
        }];
        self.label = [[UILabel alloc] init];
        self.label.text = title;
        self.label.font = [UIFont systemFontOfSize:12.0f];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).with.offset(1.5);
            make.centerX.equalTo(self.imageView);
            make.size.mas_equalTo(CGSizeMake(self.bounds.size.width, 20));
        }];
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
