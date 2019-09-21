//
//  NewPublishDescCell.m
//  vs
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "NewPublishDescCell.h"

@implementation NewPublishDescCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.postDescTextView.backgroundColor = [UIColor clearColor];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:_bottomLineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(_bottomLineView.frame) / 2, CGRectGetHeight(_bottomLineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:kTableviewCellColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(_bottomLineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(_bottomLineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [_bottomLineView.layer addSublayer:shapeLayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
