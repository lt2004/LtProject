//
//  PostDetailLoadingCell.m
//  vs
//
//  Created by Xie Shu on 2018/3/20.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "PostDetailLoadingCell.h"

@implementation PostDetailLoadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createPostDetailLoadingCellUI];
    }
    return self;
}

- (void)createPostDetailLoadingCellUI {
    _upView = [[UIView alloc] init];
    _upView.backgroundColor = RGBCOLOR(240, 240, 240);
    [self.contentView addSubview:_upView];
    
    [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self.contentView).with.offset(5);
        make.height.mas_equalTo(140);
    }];
    
    _loadingLeftView = [[UIView alloc] init];
    _loadingLeftView.backgroundColor = RGBCOLOR(240, 240, 240);
    [self.contentView addSubview:_loadingLeftView];
    
    [_loadingLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(80);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self->_upView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(20);
    }];
    
    _loadingUpView = [[UIView alloc] init];
    _loadingUpView.backgroundColor = RGBCOLOR(240, 240, 240);
    [self.contentView addSubview:_loadingUpView];
    
    [_loadingUpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self->_loadingLeftView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(20);
    }];
    
    _loadingDownView = [[UIView alloc] init];
    _loadingDownView.backgroundColor = RGBCOLOR(240, 240, 240);
    [self.contentView addSubview:_loadingDownView];
    
    [_loadingDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self->_loadingUpView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(20);
    }];
    
    _loadingRightView = [[UIView alloc] init];
    _loadingRightView.backgroundColor = RGBCOLOR(240, 240, 240);
    [self.contentView addSubview:_loadingRightView];
    
    [_loadingRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-80);
        make.top.equalTo(self->_loadingDownView.mas_bottom).with.offset(10);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.contentView).with.offset(-5);
    }];
    
    _circleView = [[UIView alloc] init];
    _circleView.backgroundColor = RGBCOLOR(240, 240, 240);
    _circleView.layer.cornerRadius = 15;
    _circleView.layer.masksToBounds = YES;
    [self.contentView addSubview:_circleView];
    
    [_circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self->_loadingLeftView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)startAnimation:(BOOL)fromOpacity {
    [_upView.layer addAnimation:[self opacityForever_AnimationByOpacity:fromOpacity] forKey:@"PostDetailAnimation_1"];
    [_loadingLeftView.layer addAnimation:[self opacityForever_AnimationByOpacity:!fromOpacity] forKey:@"PostDetailAnimation_2"];
    [_loadingUpView.layer addAnimation:[self opacityForever_AnimationByOpacity:fromOpacity] forKey:@"PostDetailAnimation_3"];
    [_loadingDownView.layer addAnimation:[self opacityForever_AnimationByOpacity:!fromOpacity] forKey:@"PostDetailAnimation_4"];
    [_loadingRightView.layer addAnimation:[self opacityForever_AnimationByOpacity:fromOpacity] forKey:@"PostDetailAnimation_5"];
    [_circleView.layer addAnimation:[self opacityForever_AnimationByOpacity:!fromOpacity] forKey:@"PostDetailAnimation_6"];
}

- (CABasicAnimation *)opacityForever_AnimationByOpacity:(BOOL)fromOpacity {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:fromOpacity ? 1.0f : 0.3];
    animation.toValue = [NSNumber numberWithFloat:fromOpacity ? 0.3f : 1.0];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = 0.65;
    animation.repeatCount = MAXFLOAT;
//    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return animation;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc {
    [_upView.layer removeAnimationForKey:@"PostDetailAnimation_1"];
     [_loadingLeftView.layer removeAnimationForKey:@"PostDetailAnimation_2"];
     [_loadingUpView.layer removeAnimationForKey:@"PostDetailAnimation_3"];
     [_loadingDownView.layer removeAnimationForKey:@"PostDetailAnimation_4"];
     [_loadingRightView.layer removeAnimationForKey:@"PostDetailAnimation_5"];
     [_circleView.layer removeAnimationForKey:@"PostDetailAnimation_6"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
