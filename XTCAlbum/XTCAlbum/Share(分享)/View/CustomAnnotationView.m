//
//  CustomAnnotationView.m
//  loveSport
//
//  Created by mac on 2017/6/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CustomAnnotationView.h"

#define kCalloutWidth   70.0f
#define kCalloutHeight  70.0f
@interface CustomAnnotationView ()

@property (nonatomic, strong) UILabel *nameLabel;

@end
@implementation CustomAnnotationView
- (void)btnAction
{
    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
}

- (void)setSelected:(BOOL)selected
{
    if (_isCanCallout == NO) {
        return;
    }
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    if (_isCanCallout == NO) {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            /* Construct custom callout. */
            
            self.calloutView = [CustomCalloutView calloutView];
            self.calloutView.frame = CGRectMake(0, 0, kCalloutWidth, kCalloutHeight);
            self.calloutView.center = CGPointMake(self.calloutOffset.x+10,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f+8);
            self.calloutView.showImageView.layer.masksToBounds = YES;
            self.calloutView.showImageView.layer.cornerRadius = 22;
            self.calloutView.showImageView.backgroundColor = [UIColor lightGrayColor];
            if (self.showImage) {
                self.calloutView.showImageView.image = self.showImage;
            } else {
                 [self.calloutView.showImageView sd_setImageWithURL:[NSURL URLWithString:_showImageStr] placeholderImage:nil];
            }
           
        }
//        self.customCalloutView = self.calloutView;
        [self addSubview:self.calloutView];
    } else {
        [self.calloutView removeFromSuperview];
//        self.customCalloutView = nil;
    }
    
    [super setSelected:selected animated:animated];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, 30, 30);
        
        self.backgroundColor = [UIColor clearColor];
     
//        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 22)];
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 27)];
        self.portraitImageView.center = CGPointMake(9.5, 13.5);
        self.portraitImageView.image = [UIImage imageNamed:@"imageIcon"];
        self.portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.portraitImageView];
    }
    
    return self;
}
@end
