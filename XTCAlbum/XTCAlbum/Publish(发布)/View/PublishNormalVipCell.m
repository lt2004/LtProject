//
//  PublishNormalVipCell.m
//  vs
//
//  Created by Xie Shu on 2017/10/10.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishNormalVipCell.h"

@implementation PublishNormalVipCell
@synthesize openVipButton = _openVipButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    _openVipButton.layer.cornerRadius = 6;
    _openVipButton.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, kTableviewCellColor.CGColor);
    CGContextStrokeRect(context, CGRectMake(5, rect.size.height, rect.size.width - 10, 1));
}

@end
