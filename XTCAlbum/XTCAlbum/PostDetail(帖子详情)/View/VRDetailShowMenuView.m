//
//  VRDetailShowMenuView.m
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "VRDetailShowMenuView.h"

@interface VRDetailShowMenuView () {
    double flagCir;
    double circleR;
    double centerX;
    BOOL _isPerson;
}

@end

@implementation VRDetailShowMenuView
@synthesize companyInforButton = _companyInforButton;
@synthesize moreButton = _moreButton;
@synthesize linkUrlButton = _linkUrlButton;
@synthesize soundButton = _soundButton;
@synthesize eyeButton = _eyeButton;
@synthesize messageButton = _messageButton;
@synthesize mapInforButton = _mapInforButton;
@synthesize crabButton = _crabButton;
@synthesize isOpen = _isOpen;

- (void)createCompanyInforMenuUI {
    _isPerson = NO;
    circleR = self.bounds.size.height*0.5-25;
    centerX = self.moreButton.center.x;
    flagCir = self.bounds.size.height*0.5;
    
    _crabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_crabButton setImage:[UIImage imageNamed:@"vr_detail_menu_crab"] forState:UIControlStateNormal];
    [self addSubview:_crabButton];
    [_crabButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _companyInforButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_companyInforButton setImage:[UIImage imageNamed:@"vr_detail_menu_company_infor"] forState:UIControlStateNormal];
    [self addSubview:_companyInforButton];
    [_companyInforButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _linkUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_linkUrlButton setImage:[UIImage imageNamed:@"vr_detail_menu_link"] forState:UIControlStateNormal];
    [self addSubview:_linkUrlButton];
    [_linkUrlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_soundButton setImage:[UIImage imageNamed:@"vr_detail_menu_sound"] forState:UIControlStateNormal];
    [_soundButton setImage:[UIImage imageNamed:@"vr_detail_menu_stop_sound"] forState:UIControlStateSelected];
    [self addSubview:_soundButton];
    [_soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_eyeButton setImage:[UIImage imageNamed:@"vr_detail_menu_eye"] forState:UIControlStateNormal];
    [self addSubview:_eyeButton];
    [_eyeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageButton setImage:[UIImage imageNamed:@"vr_detail_menu_message"] forState:UIControlStateNormal];
    [self addSubview:_messageButton];
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _mapInforButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mapInforButton setImage:[UIImage imageNamed:@"vr_detail_menu_map"] forState:UIControlStateNormal];
    [self addSubview:_mapInforButton];
    [_mapInforButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    [_moreButton addTarget:self action:@selector(menuButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:_moreButton];
    [self hidenButton];
}

- (void)createPersonalInforMenuUI {
    self.backgroundColor = [UIColor clearColor];
    _isPerson = YES;
    circleR = self.bounds.size.height*0.5-25;
    centerX = self.moreButton.center.x;
    flagCir = self.bounds.size.height*0.5;
    _soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_soundButton setImage:[UIImage imageNamed:@"vr_detail_menu_sound"] forState:UIControlStateNormal];
    [_soundButton setImage:[UIImage imageNamed:@"vr_detail_menu_stop_sound"] forState:UIControlStateSelected];
    [self addSubview:_soundButton];
    [_soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_eyeButton setImage:[UIImage imageNamed:@"vr_detail_menu_eye"] forState:UIControlStateNormal];
    [self addSubview:_eyeButton];
    [_eyeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageButton setImage:[UIImage imageNamed:@"vr_detail_menu_message"] forState:UIControlStateNormal];
    [self addSubview:_messageButton];
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _mapInforButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mapInforButton setImage:[UIImage imageNamed:@"vr_detail_menu_map"] forState:UIControlStateNormal];
    [self addSubview:_mapInforButton];
    [_mapInforButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    _crabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_crabButton setImage:[UIImage imageNamed:@"vr_detail_menu_link"] forState:UIControlStateNormal];
    [self addSubview:_crabButton];
    [_crabButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_moreButton);
    }];
    
    [_moreButton addTarget:self action:@selector(menuButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:_moreButton];
     [self hidenButton];
}

- (void)hidenButton {
    _companyInforButton.hidden = YES;
    _linkUrlButton.hidden = YES;
    _soundButton.hidden = YES;
    _eyeButton.hidden = YES;
    _mapInforButton.hidden = YES;
    _messageButton.hidden = YES;
    _crabButton.hidden = YES;
    _widthLayoutConstraint.constant = 50;
}

- (void)showButton {
    _companyInforButton.hidden = NO;
    _linkUrlButton.hidden = NO;
    _soundButton.hidden = NO;
    _eyeButton.hidden = NO;
    _mapInforButton.hidden = NO;
    _messageButton.hidden = NO;
    _crabButton.hidden = NO;
}

//计算x坐标
- (double)getXWithTanAngle:(double)tanAngle {
    double x;
    x = circleR*tanAngle;
    return x;
}

- (double)getYWithTanAngle:(double)tanAngle {
    double y;
    y = circleR*tanAngle;
    return y;
}

- (void)menuButtonClick {
    if (_isPerson) {
        double sin1 = sin(M_PI/4.5);
        double sin3 = sin(M_PI_2);
        double x1 = [self getXWithTanAngle:sin1];
        double x3 = [self getXWithTanAngle:sin3];
        
        double cos1 = cos(M_PI/4.5);
        double cos3 = cos(M_PI_2);
        double y1 = [self getYWithTanAngle:cos1];
        double y3 = [self getYWithTanAngle:cos3];
        
        
        if (_isOpen) {
            _isOpen = NO;
            [self.soundButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX, 25) toStartPoint:self.moreButton.center duration:0.15 button:self.soundButton] forKey:nil];
            [self.eyeButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x1, flagCir-y1+5) toStartPoint:self.moreButton.center duration:0.15 button:self.eyeButton] forKey:nil];
            [self.messageButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x3, flagCir-y3) toStartPoint:self.moreButton.center duration:0.15 button:self.messageButton] forKey:nil];
            [self.mapInforButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX, 2*flagCir-25) toStartPoint:self.moreButton.center duration:0.15 button:self.mapInforButton] forKey:nil];
            [self.crabButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX, 2*flagCir-25) toStartPoint:self.moreButton.center duration:0.15 button:self.crabButton] forKey:nil];
            [self performSelector:@selector(hidenButton) withObject:nil afterDelay:0.12];
        }
        else {
            // 要展开
            _widthLayoutConstraint.constant = 200;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showButton];
                self->_isOpen = YES;
                [self.soundButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX, 25) duration:0.3 button:self.soundButton] forKey:nil];
                
                [self.eyeButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x1, self->flagCir-y1+5) duration:0.3 button:self.eyeButton] forKey:nil];
                
                [self.messageButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x3, self->flagCir-y3) duration:0.3 button:self.messageButton] forKey:nil];
                
                [self.mapInforButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x1, self->flagCir+y1-5) duration:0.3 button:self.mapInforButton] forKey:nil]
                ;
                [self.crabButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX, 2*self->flagCir-25) duration:0.3 button:self.crabButton] forKey:nil];
            });
            
        }
    } else {
        double sin1 = sin(M_PI / 6);
        double sin2 = sin(M_PI / 3);
        double sin3 = sin((M_PI_2));
        double sin4 = sin(M_PI_2*4/3);
        double sin5 = sin((M_PI_2*5/3));
        double x1 = [self getXWithTanAngle:sin1];
        double x2 = [self getXWithTanAngle:sin2];
        double x3 = [self getXWithTanAngle:sin3];
        double x4 = [self getXWithTanAngle:sin4];
        double x5 = [self getXWithTanAngle:sin5];
        
        double cos1 = cos(M_PI / 6);
        double cos2 = cos(M_PI / 3);
        double cos3 = cos((M_PI_2));
        double cos4 = cos(M_PI / 3);
        double cos5 = cos((M_PI / 6));
        double y1 = [self getYWithTanAngle:cos1];
        double y2 = [self getYWithTanAngle:cos2];
        double y3 = [self getYWithTanAngle:cos3];
        double y4 = [self getYWithTanAngle:cos4];
        double y5 = [self getYWithTanAngle:cos5];
        
        
        if (_isOpen) {
            _isOpen = NO;
            [self.companyInforButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX, circleR) toStartPoint:self.moreButton.center duration:0.15 button:self.companyInforButton] forKey:nil];
            [self.linkUrlButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x1, circleR-y1) toStartPoint:self.moreButton.center duration:0.15 button:self.linkUrlButton] forKey:nil];
            [self.soundButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x2, circleR-y2) toStartPoint:self.moreButton.center duration:0.15 button:self.soundButton] forKey:nil];
            [self.eyeButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x3, circleR-y3) toStartPoint:self.moreButton.center duration:0.15 button:self.eyeButton] forKey:nil];
            
            [self.mapInforButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x4, flagCir+y4) toStartPoint:self.moreButton.center duration:0.15 button:self.mapInforButton] forKey:nil];
            
            [self.messageButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX-x5, flagCir+y5) toStartPoint:self.moreButton.center duration:0.15 button:self.messageButton] forKey:nil];
            [self.crabButton.layer addAnimation:[VRDetailShowMenuView fromEndPoint:CGPointMake(centerX, 2*flagCir-25) toStartPoint:self.moreButton.center duration:0.15 button:self.crabButton] forKey:nil];
            [self performSelector:@selector(hidenButton) withObject:nil afterDelay:0.12];
        }
        else {
            // 要展开
            _widthLayoutConstraint.constant = 200;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showButton];
                self->_isOpen = YES;
                [self.companyInforButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX, 25) duration:0.3 button:self.companyInforButton] forKey:nil];
                [self.linkUrlButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x1, self->flagCir-y1) duration:0.3 button:self.linkUrlButton] forKey:nil];
                [self.soundButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x2, self->flagCir-y2) duration:0.3 button:self.soundButton] forKey:nil];
                [self.eyeButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x3, self->flagCir-y3) duration:0.3 button:self.eyeButton] forKey:nil];
                [self.mapInforButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x4, y4+self->flagCir) duration:0.3 button:self.mapInforButton] forKey:nil];
                [self.messageButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX-x5, y5+self->flagCir) duration:0.3 button:self.messageButton] forKey:nil];
                [self.crabButton.layer addAnimation:[VRDetailShowMenuView fromPoint:self.moreButton.center toPoint:CGPointMake(self->centerX, 2*self->flagCir-25) duration:0.3 button:self.crabButton] forKey:nil];
            });
        }
    }
    
    
}



//打开菜单
+ (CAAnimationGroup *)fromPoint:(CGPoint)from toPoint:(CGPoint)to duration:(CFTimeInterval)duration button:(UIButton *)button
{
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:from];
    //[movePath addLineToPoint:to];
    [movePath addQuadCurveToPoint:to
                     controlPoint:CGPointMake( to.x - 10, to.y - 10)];
    [movePath addQuadCurveToPoint:to
                     controlPoint:CGPointMake( to.x + 10, to.y + 10)];
    
    //关键帧
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    moveAnim.removedOnCompletion = YES;
    
    CABasicAnimation *TransformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    TransformAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    //沿Z轴旋转
    TransformAnim.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI,0,0,1)];
    TransformAnim.cumulative = YES;
    TransformAnim.duration = duration / 4;
    //旋转1遍，360度
    TransformAnim.repeatCount = 4;
    TransformAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: TransformAnim, moveAnim,nil];
    animGroup.duration = duration;
    button.center = to;
    return animGroup;
}



//收回菜单
+ (CAAnimationGroup *)fromEndPoint:(CGPoint)from toStartPoint:(CGPoint)to duration:(CFTimeInterval)duration button:(UIButton *)button
{
    
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:from];
    [movePath addLineToPoint:to];
    
    //关键帧
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    moveAnim.removedOnCompletion = YES;
    
    CABasicAnimation *TransformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    TransformAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    //沿Z轴旋转
    TransformAnim.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI,0,0,1)];
    TransformAnim.cumulative = YES;
    TransformAnim.duration = duration / 3;
    //旋转1遍，360度
    TransformAnim.repeatCount = 3;
    TransformAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:moveAnim, TransformAnim,nil];
    animGroup.duration = duration;
    button.center = to;
    return animGroup;
}

- (void)dealloc {
    DDLogInfo(@"vr菜单释放");
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
