//
//  XTCUserHeaderCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCUserHeaderCell.h"

@implementation XTCUserHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIBezierPath *bzpath = [self roundedPolygonPathWithRect:_userHeaderButton.bounds lineWidth:1.0 sides:6 cornerRadius:10];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = bzpath.CGPath;
    mask.lineWidth = 1.0;
    mask.borderColor = [UIColor whiteColor].CGColor;
    mask.strokeColor = [UIColor clearColor].CGColor;
    mask.fillColor = [UIColor whiteColor].CGColor;
    _userHeaderButton.layer.mask = mask;
    _userHeaderButton.clipsToBounds = true;
    _userHeaderButton.backgroundColor = kTableviewColor;
}

- (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *bzpath  = [UIBezierPath bezierPath];
    
    CGFloat theta       = 2.0 * M_PI / sides;                           // how much to turn at every corner
    CGFloat offset      = cornerRadius * tanf(theta / 2.0);             // offset from which to start rounding corners
    CGFloat squareWidth = MIN(square.size.width, square.size.height);   // width of the square
    
    // calculate the length of the sides of the polygon
    
    CGFloat length      = squareWidth - lineWidth;
    if (sides % 4 != 0) {                                               // if not dealing with polygon which will be square with all sides ...
        length = length * cosf(theta / 2.0) + offset/2.0;               // ... offset it inside a circle inside the square
    }
    CGFloat sideLength = length * tanf(theta / 2.0);
    
    // start drawing at `point` in lower right corner
    
    CGPoint point = CGPointMake(squareWidth / 2.0 + sideLength / 2.0 - offset, squareWidth - (squareWidth - length) / 2.0);
    CGFloat angle = M_PI;
    [bzpath moveToPoint:point];
    
    // draw the sides and rounded corners of the polygon
    
    for (NSInteger side = 0; side < sides; side++) {
        point = CGPointMake(point.x + (sideLength - offset * 2.0) * cosf(angle), point.y + (sideLength - offset * 2.0) * sinf(angle));
        [bzpath addLineToPoint:point];
        
        CGPoint center = CGPointMake(point.x + cornerRadius * cosf(angle + M_PI_2), point.y + cornerRadius * sinf(angle + M_PI_2));
        [bzpath addArcWithCenter:center radius:cornerRadius startAngle:angle - M_PI_2 endAngle:angle + theta - M_PI_2 clockwise:YES];
        
        point = bzpath.currentPoint; // we don't have to calculate where the arc ended ... UIBezierPath did that for us
        angle += theta;
    }
    
    [bzpath closePath];
    
    // rotate it 90 degrees
    [bzpath applyTransform:CGAffineTransformMakeRotation(M_PI/2)];
    // now move it back so that the top left of its bounding box is (0,0)
    [bzpath applyTransform:CGAffineTransformMakeTranslation(squareWidth, 0)];
    
    return bzpath;
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
    CGContextSetStrokeColorWithColor(context, RGBCOLOR(231, 231, 231).CGColor);
    CGContextStrokeRect(context, CGRectMake(15, rect.size.height, rect.size.width-30, 1));
}

@end
