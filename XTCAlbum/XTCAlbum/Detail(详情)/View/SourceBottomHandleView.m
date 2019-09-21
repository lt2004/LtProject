//
//  SourceBottomHandleView.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/7.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceBottomHandleView.h"

@implementation SourceBottomHandleView

- (UIButton *)inforButton {
    if (!_inforButton) {
        _inforButton = [[UIButton alloc] init];
        [_inforButton setImage:[UIImage imageNamed:@"detail_show_infor"] forState:UIControlStateNormal];
        [self addSubview:_inforButton];
    }
    return _inforButton;
}

- (UIButton *)photoAdjustButton {
    if (!_photoAdjustButton) {
        _photoAdjustButton = [[UIButton alloc] init];
        [_photoAdjustButton setImage:[UIImage imageNamed:@"detal_show_edit_white"] forState:UIControlStateNormal];
        [self addSubview:_photoAdjustButton];
    }
    return _photoAdjustButton;
}

- (UIButton *)filterButton {
    if (!_filterButton) {
        _filterButton = [[UIButton alloc] init];
        [_filterButton setImage:[UIImage imageNamed:@"detail_show_filter"] forState:UIControlStateNormal];
        [self addSubview:_filterButton];
    }
    return _filterButton;
}

- (UIButton *)cropButton {
    if (!_cropButton) {
        _cropButton = [[UIButton alloc] init];
        [_cropButton setImage:[UIImage imageNamed:@"detail_show_tailor"] forState:UIControlStateNormal];
        [self addSubview:_cropButton];
    }
    return _cropButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    _inforButton.frame = CGRectMake(width*0.25-25, 0, 50, 49);
    _filterButton.frame = CGRectMake(width*0.5-25, 0, 50, 49);
    _cropButton.frame = CGRectMake(width*0.75-25, 0, 50, 49);
    /*
    _inforButton.frame = CGRectMake((width-200)*0.2, 0, 50, 49);
    _photoAdjustButton.frame = CGRectMake((width-200)*0.4+50, 0, 50, 49);
    _filterButton.frame = CGRectMake((width-200)*0.6+100, 0, 50, 49);
    _cropButton.frame = CGRectMake((width-200)*0.8+150, 0, 50, 49);
     */
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
